// Top module for MOS 6502 Core

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

// Wires

	wire n_NMIP;
	wire n_IRQP;
	wire RESP;
	wire RDY_frompad;
	wire n_PRDY;
	wire T1_topad;
	wire SO_frompad;
	wire WR_topad;

// Module instantiation

	PadsLogic pads();

	ClkGen clk();

	ALU alu();

	ALU_Control aluctl();

	BranchLogic branch();

	BRKProcessing brk();

	IntVector int();

	Decoder dec();

	Bus_Control busctl();

	AddrBusBitLow [2:0] abl03;

	AddrBusBit [7:3] abl;

	AddrBusBit [7:0] abh;

	DataBusBit [7:0] db();

	Dispatch disp();

	ExtraCounter extcnt();

	Flags flags();

	Flags_Control fctl();

	IR ir();

	PC pc();

	PC_Control pcctl();

	PreDecode pd();

	Regs regs();

	Regs_Control regctl();

endmodule // Core6502
