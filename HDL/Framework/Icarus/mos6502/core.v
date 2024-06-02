// Checking the core under simple conditions.
// We organize a minimal computing system, the so called BogusSystem. This system has only 6502 and 64 Kbytes of memory with a loaded dump.
// The core runs for N cycles and we see how alive it is.

`timescale 1ns/1ns

module Core_Run ();

	reg CLK;
	reg n_RES;
	reg n_IRQ;
	reg n_NMI;
	reg SO;
	reg RDY;

	wire [15:0] addr_bus;
	wire [7:0] data_bus;

	wire PHI1;
	wire PHI2;
	wire SYNC;
	wire RnW;

	always #25 CLK = ~CLK;

	Core6502 core (
		.n_NMI(n_NMI),
		.n_IRQ(n_IRQ),
		.n_RES(n_RES),
		.PHI0(CLK),
		.PHI1(PHI1),
		.PHI2(PHI2),
		.RDY(RDY),
		.SO(SO),
		.RnW(RnW),
		.SYNC(SYNC),
		.A(addr_bus),
		.D(data_bus) );

	ExtMem mem (
		.M2(PHI2), 
		.WE(~RnW),
		.OE(RnW), 
		.Addr(addr_bus), 
		.Data(data_bus) );

	initial begin

		$display("Check that MOS6502 Core is moving.");

		RDY <= 1'b1; 		// Always ready
		SO <= 1'b1; 			// SO is enough to set to 1 to prevent the falling edge detector from triggering

		CLK <= 1'b0;
		n_IRQ <= 1'b1;
		n_NMI <= 1'b1;

		$dumpfile("core.vcd");
		$dumpvars(0, Core_Run);

		// Perform reset
		n_RES <= 1'b0;
		repeat (8) @ (posedge CLK);
		n_RES <= 1'b1;

		repeat (256) @ (posedge CLK);
		$finish;
	end	

endmodule // Core_Run

module ExtMem (M2, WE, OE, Addr, Data);

	input M2;
	input WE;
	input OE;
	input [15:0] Addr;
	inout [7:0] Data;

	reg [7:0] mem [0:65535];
	reg [7:0] temp;

	// You need to pre-fill the memory with some value so you don't run into `xx`
	integer j;
	initial 
	for(j = 0; j < 65536; j = j+1) 
		mem[j] = 0;

	initial $readmemh("core.mem", mem);

	always @(M2) begin
		if (OE)
			temp <= mem[Addr];
		else if (WE)
			mem[Addr] <= Data;
	end

	assign Data = (M2 & OE) ? temp : 'bz;

endmodule // ExtMem
