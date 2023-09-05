// Top module for MOS 6502 Core

// Top->Bottom Operations

`define Y_SB bop[0]			// Y => SB
`define SB_Y bop[1]			// SB => Y
`define X_SB bop[2]			// X => SB
`define SB_X bop[3]			// SB => X
`define S_ADL bop[4]		// S => ADL
`define S_SB bop[5]			// S => SB
`define SB_S bop[6]			// SB => S
`define S_S bop[7]			// The S/S command is active if the SB/S command is inactive (refresh S)
`define NDB_ADD bop[8]		// ~DB => BI
`define DB_ADD bop[9]		// DB => BI
`define Z_ADD bop[10]		// 0 => AI
`define SB_ADD bop[11]		// SB => AI
`define ADL_ADD bop[12]		// ADL => BI
`define ANDS bop[13]		// AI & BI
`define EORS bop[14]		// AI ^ BI
`define ORS bop[15]			// AI | BI
`define SRS bop[16]			// >>= 1
`define SUMS bop[17]		// AI + BI
`define ADD_SB7 bop[18]		// ADD[7] => SB[7]
`define ADD_SB06 bop[19]	// ADD[0-6] => SB[0-6]
`define ADD_ADL bop[20]		// ADD => ADL
`define SB_AC bop[21]		// SB => AC
`define AC_SB bop[22]		// AC => SB
`define AC_DB bop[23]		// AC => DB
`define ADH_PCH bop[24]		// ADH => PCH
`define PCH_PCH bop[25]		// If ADH/PCH is not performed, this command is performed (refresh PCH)
`define PCH_ADH bop[26]		// PCH => ADH
`define PCH_DB bop[27]		// PCH => DB
`define ADL_PCL bop[28]		// ADL => PCL
`define PCL_PCL bop[29]		// If ADL/PCL is not performed, this command is performed (refresh PCL)
`define PCL_ADL bop[30]		// PCL => ADL
`define PCL_DB bop[31]		// PCL => DB
`define ADH_ABH bop[32]		// ADH => ABH
`define ADL_ABL bop[33]		// ADL => ABL
`define Z_ADL0 bop[34]		// Reset some of the ADL bus bits (0). Used to set the interrupt vector.
`define Z_ADL1 bop[35]		// Reset some of the ADL bus bits (1). Used to set the interrupt vector.
`define Z_ADL2 bop[36]		// Reset some of the ADL bus bits (2). Used to set the interrupt vector.
`define Z_ADH0 bop[37]		// Reset some of the ADH bus bits (0)
`define Z_ADH17 bop[38]		// Reset some of the ADH bus bits (1-7)
`define SB_DB bop[39]		// SB <=> DB, connect the two buses
`define SB_ADH bop[40]		// SB <=> ADH
`define DL_ADL bop[41]		// DL => ADL
`define DL_ADH bop[42]		// DL => ADH
`define DL_DB bop[43]		// DL <=> DB


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
	wire SO_frompad;
	wire WR_topad;
	wire T1_topad;

	wire PHI1_tocore;
	wire PHI2_tocore;

	wire ACR;
	wire AVR;
	wire [7:0] DB;

	wire [43:0] bop;	// Control "Commands"
	wire n_ACIN;		// ALU input carry. The ALU also returns the result of carry (ACR) and overflow (AVR)
	wire n_DAA;			// 0: Perform BCD correction after addition
	wire n_DSA;			// 0: Perform BCD correction after subtraction
	wire n_IPC;			// 0: Increment the program counter	

	// Module instantiation

	ClkGen clk (
		.PHI0(PHI0), 
		.PHI1(PHI1_tocore), 
		.PHI2(PHI2_tocore), 
		.PHI1_topad(PHI1), 
		.PHI2_topad(PHI2) );

	PadsLogic pads (
		.PHI1(PHI1), 
		.PHI2(PHI2),
		.n_NMI(n_NMI), 
		.n_IRQ(n_IRQ), 
		.n_RES(n_RES), 
		.n_NMIP(n_NMIP), 
		.n_IRQP(n_IRQP), 
		.RESP(RESP), 
		.RDY(RDY), 
		.RDY_frompad(RDY_frompad), 
		.n_PRDY(n_PRDY), 
		.T1_topad(T1_topad), 
		.SYNC(SYNC), 
		.SO(SO), 
		.SO_frompad(SO_frompad),
		.WR_topad(WR_topad), 
		.RnW(RnW) );

	Core6502_Top top (
		.PHI1(PHI1_tocore),
		.PHI2(PHI2_tocore), 
		.n_NMIP(n_NMIP),
		.n_IRQP(n_IRQP),
		.RESP(RESP),
		.RDY_frompad(RDY_frompad),
		.n_PRDY(n_PRDY),
		.SO_frompad(SO_frompad),
		.bop(bop),
		.n_ACIN(n_ACIN),
		.n_DAA(n_DAA),
		.n_DSA(n_DSA),
		.n_IPC(n_IPC),
		.WR(WR_topad),
		.T1(T1_topad),
		.ACR(ACR),
		.AVR(AVR),
		.DB(DB),
		.D(D) );

	Core6502_Bot bot (
		.PHI1(PHI1_tocore),
		.PHI2(PHI2_tocore),
		.bop(bop),
		.n_ACIN(n_ACIN),
		.n_DAA(n_DAA),
		.n_DSA(n_DSA),
		.n_IPC(n_IPC),
		.WR(WR_topad),
		.ACR(ACR),
		.AVR(AVR),
		.DB(DB),
		.A(A),
		.D(D) );

endmodule // Core6502

module Core6502_Top (
	PHI1, PHI2, 
	n_NMIP, n_IRQP, RESP, RDY_frompad, n_PRDY, SO_frompad,
	bop, n_ACIN, n_DAA, n_DSA, n_IPC, WR, T1, ACR, AVR, DB, D);

	input PHI1;
	input PHI2;
	input n_NMIP;
	input n_IRQP;
	input RESP;
	input RDY_frompad;
	input n_PRDY;
	input SO_frompad;
	output [43:0] bop;
	output n_ACIN;
	output n_DAA;
	output n_DSA;
	output n_IPC;
	output WR;
	output T1;
	input ACR;
	input AVR;
	inout [7:0] DB; 	// Internal databus to Flags
	inout [7:0] D; 		// External databus to Predecode

	wire IR5_C;		// Change the value of the flag according to the IR5 bit
	wire ACR_C;		// Change the value of the flag according to the ACR value
	wire DB_C;		// Change the value of the flag according to DB0 bit
	wire DBZ_Z;		// Change the value of the flag according to the /DBZ value
	wire IR5_I;		// Change the value of the flag according to the IR5 bit
	wire IR5_D;		// Change the value of the flag according to the IR5 bit
	wire DB_V;		// Change the value of the flag according to DB6 bit
	wire Z_V;		// Clear flag V
	wire DB_N;		// Change the value of the flag according to DB7 bit
	wire P_DB;		// Place the value of the flags register P on the DB bus
	wire DB_P;		// Place the DB bus value on the flag register P

	wire Z_IR;
	wire [7:0] n_PD;
	wire n_IMPLIED;
	wire n_TWOCYCLE;
	wire n_BRTAKEN;
	wire BRFW;

	wire FETCH;
	wire IR01;
	wire [7:0] IR;
	wire [7:0] n_IR;

	wire TRES2;
	wire n_ready;
	wire T0;
	wire T1;
	wire n_T2;
	wire n_T3;
	wire n_T4;
	wire n_T5;
	wire n_T0;
	wire n_T1X;
	wire T6;
	wire T7;

	wire [129:0] Decoder_out;

	wire BRK5;
	wire BRK5_RDY;
	wire BRK6E;
	wire BRK7;
	wire DORES;
	wire n_DONMI;
	wire B_OUT;	

	wire STXY;
	wire n_SBXY;
	wire STKOP;
	wire STOR;
	wire ACRL2;
	wire DL_PCH;
	wire INC_SB;
	wire n_PCH_PCH;
	wire n_ADL_PCL;
	wire PC_DB;
	wire SR;
	wire AND;
	wire ZTST;
	wire PGX;

	// Flags output

	wire n_ZOUT;
	wire n_NOUT;
	wire n_COUT;
	wire n_DOUT;
	wire n_IOUT;
	wire n_VOUT;

	PreDecode pd (
		.PHI2(PHI2),
		.Z_IR(Z_IR),
		.Data_bus(D),
		.n_PD(n_PD),
		.n_IMPLIED(n_IMPLIED),
		.n_TWOCYCLE(n_TWOCYCLE) );

	IR ir (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.n_PD(n_PD),
		.FETCH(FETCH),
		.IR01(IR01),
		.IR_out(IR),
		.n_IR_out(n_IR) );

	ExtraCounter extcnt (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.TRES2(TRES2),
		.n_ready(n_ready),
		.T1(T1),
		.n_T2(n_T2),
		.n_T3(n_T3),
		.n_T4(n_T4),
		.n_T5(n_T5) );

	Decoder dec (
		.n_T0(n_T0),
		.n_T1X(n_T1X),
		.n_T2(n_T2),
		.n_T3(n_T3),
		.n_T4(n_T4),
		.n_T5(n_T5), 
		.IR01(IR01),
		.IR(IR),
		.n_IR(n_IR),
		.X(Decoder_out) );

	BRKProcessing brk (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.BRK5(Decoder_out[22]),
		.n_ready(n_ready),
		.RESP(RESP),
		.n_NMIP(n_NMIP),
		.BR2(Decoder_out[80]),
		.T0(T0),
		.n_IRQP(n_IRQP),
		.n_IOUT(n_IOUT),
		.BRK6E(BRK6E),
		.BRK7(BRK7),
		.BRK5_RDY(BRK5_RDY),
		.DORES(DORES),
		.n_DONMI(n_DONMI),
		.B_OUT(B_OUT) );

	IntVector int (
		.PHI2(PHI2),
		.BRK5_RDY(BRK5_RDY),
		.BRK7(BRK7),
		.DORES(DORES),
		.n_DONMI(n_DONMI),
		.Z_ADL0(`Z_ADL0),
		.Z_ADL1(`Z_ADL1),
		.Z_ADL2(`Z_ADL2) );

	Regs_Control regctl (
		.PHI1(PHI1),
		.PHI2(PHI2), 
		.STOR(STOR),
		.n_ready(n_ready), 
		.X(Decoder_out),
		.STXY(STXY),
		.n_SBXY(n_SBXY),
		.STKOP(STKOP), 
		.Y_SB(`Y_SB),
		.X_SB(`X_SB),
		.S_SB(`S_SB),
		.SB_X(`SB_X),
		.SB_Y(`SB_Y),
		.SB_S(`SB_S),
		.S_S(`S_S),
		.S_ADL(`S_ADL) );

	ALU_Control aluctl (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.BRFW(BRFW),
		.n_ready(n_ready),
		.BRK6E(BRK6E),
		.STKOP(STKOP),
		.PGX(PGX),
		.X(Decoder_out),
		.T0(T0),
		.T1(T1),
		.T6(T6),
		.T7(T7),
		.n_DOUT(n_DOUT),
		.n_COUT(n_COUT),
		.INC_SB(INC_SB),
		.SR(SR),
		.AND(AND),
		.NDB_ADD(`NDB_ADD),
		.DB_ADD(`DB_ADD),
		.Z_ADD(`Z_ADD),
		.SB_ADD(`SB_ADD),
		.ADL_ADD(`ADL_ADD),
		.ADD_SB06(`ADD_SB06),
		.ADD_SB7(`ADD_SB7),
		.ADD_ADL(`ADD_ADL),
		.ANDS(`ANDS),
		.EORS(`EORS),
		.ORS(`ORS),
		.SRS(`SRS),
		.SUMS(`SUMS),
		.n_ACIN(n_ACIN),
		.n_DAA(n_DAA),
		.n_DSA(n_DSA) );

	Bus_Control busctl (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.n_SBXY(n_SBXY),
		.AND(AND),
		.STOR(STOR),
		.Z_ADL0(`Z_ADL0),
		.BR2(Decoder_out[80]),
		.ACRL2(ACRL2),
		.DL_PCH(DL_PCH),
		.n_ready(n_ready),
		.INC_SB(INC_SB),
		.BRK6E(BRK6E),
		.STXY(STXY),
		.n_PCH_PCH(n_PCH_PCH),
		.T0(T0),
		.T1(T1),
		.T6(T6),
		.T7(T7),
		.X(Decoder_out),
		.ZTST(ZTST),
		.PGX(PGX), 
		.Z_ADH0(`Z_ADH0),
		.Z_ADH17(`Z_ADH17),
		.SB_AC(`SB_AC),
		.ADL_ABL(`ADL_ABL),
		.AC_SB(`AC_SB),
		.SB_DB(`SB_DB),
		.AC_DB(`AC_DB),
		.SB_ADH(`SB_ADH),
		.DL_ADH(`DL_ADH),
		.DL_ADL(`DL_ADL),
		.ADH_ABH(`ADH_ABH),
		.DL_DB(`DL_DB) );

	PC_Control pcctl (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.n_ready(n_ready),
		.T0(T0),
		.T1(T1), 
		.X(Decoder_out),
		.PCL_DB(`PCL_DB),
		.PCH_DB(`PCH_DB),
		.PC_DB(PC_DB),
		.PCL_ADL(`PCL_ADL),
		.PCH_ADH(`PCH_ADH),
		.PCL_PCL(`PCL_PCL),
		.ADL_PCL(`ADL_PCL),
		.n_ADL_PCL(n_ADL_PCL),
		.DL_PCH(DL_PCH),
		.ADH_PCH(`ADH_PCH),
		.PCH_PCH(`PCH_PCH),
		.n_PCH_PCH(n_PCH_PCH) );

	Flags_Control fctl (
		.PHI2(PHI2),
		.X(Decoder_out),
		.T7(T7),
		.ZTST(ZTST),
		.n_ready(n_ready),
		.SR(SR),
		.P_DB(P_DB),
		.IR5_I(IR5_I),
		.IR5_C(IR5_C),
		.IR5_D(IR5_D),
		.Z_V(Z_V),
		.ACR_C(ACR_C),
		.DBZ_Z(DBZ_Z),
		.DB_N(DB_N),
		.DB_P(DB_P),
		.DB_C(DB_C),
		.DB_V(DB_V) );

	Dispatch disp (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.BRK6E(BRK6E),
		.RESP(RESP),
		.ACR(ACR),
		.DORES(DORES),
		.PC_DB(PC_DB),
		.RDY(RDY_frompad),
		.B_OUT(B_OUT),
		.BRFW(BRFW),
		.n_BRTAKEN(n_BRTAKEN),
		.n_TWOCYCLE(n_TWOCYCLE),
		.n_IMPLIED(n_IMPLIED),
		.n_ADL_PCL(n_ADL_PCL), 
		.X(Decoder_out), 
		.ACRL2(ACRL2),
		.T6(T6),
		.T7(T7),
		.TRES2(TRES2),
		.STOR(STOR),
		.Z_IR(Z_IR),
		.FETCH(FETCH),
		.n_ready(n_ready),
		.WR(WR),
		.T1(T1),
		.n_T0(n_T0),
		.T0(T0),
		.n_T1X(n_T1X),
		.n_IPC(n_IPC) );

	BranchLogic branch (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.n_IR5(n_IR[5]),
		.X(Decoder_out),
		.n_COUT(n_COUT),
		.n_VOUT(n_VOUT),
		.n_NOUT(n_NOUT),
		.n_ZOUT(n_ZOUT),
		.DB(DB),
		.BR2(Decoder_out[80]),
		.n_BRTAKEN(n_BRTAKEN),
		.BRFW(BRFW) );

	Flags flags (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.P_DB(P_DB),
		.DB_P(DB_P),
		.DBZ_Z(DBZ_Z),
		.DB_N(DB_N),
		.IR5_C(IR5_C),
		.DB_C(DB_C),
		.ACR_C(ACR_C),
		.IR5_D(IR5_D),
		.DB_V(DB_V),
		.Z_V(Z_V),
		.ACR(ACR),
		.AVR(AVR),
		.B_OUT(B_OUT),
		.n_IR5(n_IR[5]),
		.BRK6E(BRK6E),
		.Dec112(Decoder_out[112]),
		.SO_frompad(SO_frompad), 
		.DB(DB),
		.n_ZOUT(n_ZOUT),
		.n_NOUT(n_NOUT),
		.n_COUT(n_COUT),
		.n_DOUT(n_DOUT),
		.n_IOUT(n_IOUT),
		.n_VOUT(n_VOUT) );

endmodule // Core6502_Top

module Core6502_Bot (PHI1, PHI2, bop, n_ACIN, n_DAA, n_DSA, n_IPC, WR, ACR, AVR, DB, A, D);

	input PHI1;
	input PHI2;
	input [43:0] bop;
	input n_ACIN;
	input n_DAA;
	input n_DSA;
	input n_IPC;
	input WR;
	output ACR;
	output AVR;
	output [15:0] A;
	inout [7:0] DB; 	// Internal data bus
	inout [7:0] D;

	wire [7:0] SB; 		// Side bus
	wire [7:0] ADL;		// Address bus low
	wire [7:0] ADH;		// Address bus high

	wire RD_to_db;

	Regs regs (
		.PHI2(PHI2),
		.Y_SB(`Y_SB),
		.SB_Y(`SB_Y),
		.X_SB(`X_SB),
		.SB_X(`SB_X),
		.S_SB(`S_SB),
		.S_ADL(`S_ADL),
		.S_S(`S_S),
		.SB_S(`SB_S), 
		.SB(SB),
		.ADL(ADL) );

	ALU alu (
		.PHI2(PHI2),
		.NDB_ADD(`NDB_ADD),
		.DB_ADD(`DB_ADD),
		.Z_ADD(`Z_ADD),
		.SB_ADD(`SB_ADD),
		.ADL_ADD(`ADL_ADD),
		.ADD_SB06(`ADD_SB06),
		.ADD_SB7(`ADD_SB7),
		.ADD_ADL(`ADD_ADL),
		.ANDS(`ANDS),
		.EORS(`EORS),
		.ORS(`ORS),
		.SRS(`SRS),
		.SUMS(`SUMS), 
		.SB_AC(`SB_AC),
		.AC_SB(`AC_SB),
		.AC_DB(`AC_DB),
		.SB_DB(`SB_DB),
		.SB_ADH(`SB_ADH),
		.Z_ADH0(`Z_ADH0),
		.Z_ADH17(`Z_ADH17),
		.n_ACIN(n_ACIN),
		.n_DAA(n_DAA),
		.n_DSA(n_DSA),
		.SB(SB),
		.DB(DB),
		.ADL(ADL),
		.ADH(ADH),
		.ACR(ACR),
		.AVR(AVR) );

	PC pc (
		.PHI2(PHI2),
		.n_IPC(n_IPC),
		.ADL_PCL(`ADL_PCL),
		.PCL_PCL(`PCL_PCL),
		.PCL_ADL(`PCL_ADL),
		.PCL_DB(`PCL_DB),
		.ADH_PCH(`ADH_PCH),
		.PCH_PCH(`PCH_PCH),
		.PCH_ADH(`PCH_ADH),
		.PCH_DB(`PCH_DB),
		.ADL(ADL),
		.ADH(ADH),
		.DB(DB) );

	AddrBusBitLow abl02 [2:0] (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.ADX(ADL[2:0]),
		.Z_ADX({Z_ADL2,Z_ADL1,Z_ADL0}),
		.ADX_ABX(`ADL_ABL),
		.ABus_out(A[2:0]) );

	AddrBusBit abl [7:3] (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.ADX(ADL[7:3]),
		.ADX_ABX(`ADL_ABL),
		.ABus_out(A[7:3]) );

	AddrBusBit abh [7:0] (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.ADX(ADH),
		.ADX_ABX(`ADH_ABH),
		.ABus_out(A[7:0]) );

	WRLatch wrl (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.WR(WR),
		.RD(RD_to_db) );

	DataBusBit db [7:0] (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.ADL(ADL),
		.ADH(ADH),
		.DB(DB),
		.DB_Ext(D),
		.DL_ADL(`DL_ADL),
		.DL_ADH(`DL_ADH),
		.DL_DB(`DL_DB),
		.RD(RD_to_db) );

	BusPrecharge precharge (
		.PHI2(PHI2),
		.SB(SB),
		.DB(DB),
		.ADL(ADL),
		.ADH(ADH) );

endmodule // Core6502_Bot

module BusPrecharge ( PHI2, SB, DB, ADL, ADH );

	input PHI2;
	inout [7:0] SB;
	inout [7:0] DB;
	inout [7:0] ADL;
	inout [7:0] ADH;

	assign SB = PHI2 ? 8'b11111111 : 8'bzzzzzzzz;
	assign DB = PHI2 ? 8'b11111111 : 8'bzzzzzzzz;
	assign ADL = PHI2 ? 8'b11111111 : 8'bzzzzzzzz;
	assign ADH = PHI2 ? 8'b11111111 : 8'bzzzzzzzz;

endmodule // BusPrecharge
