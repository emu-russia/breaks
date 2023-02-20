// 6502, which can only simulate reading and writing APU registers from the register dump history

// https://github.com/emu-russia/breaknes/blob/main/BreaksAPU/NSFPlayerInterop/Fake6502.cpp

module Core6502 (n_NMI, n_IRQ, n_RES, PHI0, PHI1, PHI2, RDY, SO, RnW, SYNC, A, D);

	input n_NMI;		// Non-maskable interrupt signal, active low
	input n_IRQ;		// Maskable interrupt signal, active low
	input n_RES;		// Reset signal, active low
	input PHI0;			// Reference clock signal
	output PHI1;		// First half-cycle, processor in `Set RW / Address` mode
	output PHI2;		// Second half-cycle, processor in `Read/Write Data` mode
	input RDY;			// Processor Ready (1: ready)
	input SO;			// Forced setting of the overflow flag (V)
	output RnW;			// Data bus direction (R/W=1: processor reads data, R/W=0: processor writes)
	output SYNC;		// The processor is on cycle T1 (opcode fetch)
	output [15:0] A;	// Address bus
	inout [7:0] D; 		// Data bus (bidirectional)

	assign PHI1 = ~PHI0;
	assign PHI2 = PHI0;
	assign SYNC = 1'b0;

	reg [31:0] regdump_rom [0:32767];
	wire [23:0] regdump_addr;

	initial begin
		$readmemh("regdump.mem", regdump_rom);
	end

	RegDumpProcessor rp (
		.PHI0(PHI0), 
		.n_RES(n_RES),
		.RnW(RnW), 
		.addr_bus(A), 
		.data_bus(D),
		.regdump_data(regdump_rom[regdump_addr]), 
		.regdump_addr(regdump_addr) );

endmodule // Core6502

module RegDumpProcessor (PHI0, n_RES, RnW, addr_bus, data_bus, regdump_data, regdump_addr);

	input PHI0; 						// Core PHI0
	input n_RES; 						// Core #RES
	output RnW; 						// Core R/W
	output [15:0] addr_bus; 			// Core address bus
	inout [7:0] data_bus; 				// Core data bus
	input [31:0] regdump_data; 			// Data bus for external asynchronous memory where registers dump is stored (`APULogEntry` entries)
	output [23:0] regdump_addr; 		// Address bus for external asynchronous memory

	reg [31:0] phi_dec_cnt; 			// PHI delta down-counter
	reg [31:0] delta_phi_word; 			// word[0] from regdump
	reg [31:0] regop_word; 				// word[1] from regdump
	reg cnt_ovf_reg;
	reg [31:0] addr_cnt; 		// negedge
	wire cntz; 				// 1: Counter is zero
	wire deltanz; 			// 1: Delta PHI is NOT zero
	wire inc_address; 		// 1: Increment addr_cnt

	wire DoRegOp; 			// 1: Issue register operation
	wire LoadPhiCounter;	// 1: Reload PHI decrement counter
	wire [15:0] RegAddress;
	wire [7:0] RegValue; 	// if write
	wire ReadMode; 			// 1: read register

	initial begin
		phi_dec_cnt <= 0;
		delta_phi_word <= 0;
		regop_word <= 0;
		cnt_ovf_reg <= 0;
		addr_cnt <= 0;
	end

	// Counter + control words

	always @(posedge PHI0) begin
		delta_phi_word <= regdump_data;
		if (LoadPhiCounter) regop_word <= 0;
		if (LoadPhiCounter) phi_dec_cnt <= regdump_data >= 2 ? regdump_data - 2 : 0; 	// Take into account 2 cycles on the RegDump logic
		else if (n_RES) phi_dec_cnt <= phi_dec_cnt - 1;
		cnt_ovf_reg <= cntz;
	end

	assign cntz = phi_dec_cnt == 0;
	assign LoadPhiCounter = cnt_ovf_reg & n_RES;
	assign deltanz = delta_phi_word != 0;
	assign DoRegOp = (PHI0 & deltanz & cntz & ~LoadPhiCounter & n_RES);
	assign inc_address = DoRegOp | LoadPhiCounter;

	always @(posedge DoRegOp) begin
		regop_word <= regdump_data;
	end

	always @(negedge inc_address) begin
		if (n_RES) addr_cnt <= addr_cnt + 1;
	end

	// RegOp

	assign RegAddress = 'h4000 | ({11'b0, regop_word[4:0]});
	assign RegValue = regop_word[15:8];
	assign ReadMode = regop_word[7];

	// Default core mode: read address 0

	assign RnW = DoRegOp ? ReadMode : 1'b1;
	assign addr_bus = DoRegOp ? RegAddress : 16'b0;
	assign data_bus = (DoRegOp & ~ReadMode) ? RegValue : 8'bz;
	
	assign regdump_addr = addr_cnt;

endmodule // RegDumpProcessor


//	struct APULogEntry
//	{
//		uint32_t	phiDelta;	// Delta of previous PHI0 counter (CPU Core clock cycles) value at the time of accessing to the register
//		uint8_t 	reg; 		// APU register index (0-0x1f) + Flag (msb - 0: write, 1: read)
//		uint8_t 	value;		// Written value. Not used for reading.
//		uint16_t	padding;	// Not used (yet?)
//	};
