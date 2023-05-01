
module APU(AUX_A, AUX_B, n_RES, A, D, CLK, DBG, M2, n_IRQ, n_NMI, RnW, n_IN0, n_IN1, OUT0, OUT1, OUT2);

	output [7:0] AUX_A;
	output [14:0] AUX_B;
	input n_RES;
	output [15:0] A;
	inout [7:0] D;
	input CLK;
	input DBG;
	output M2;
	input n_IRQ;
	input n_NMI;
	output RnW;
	output n_IN0;	
	output n_IN1;
	output OUT0;
	output OUT1;
	output OUT2;	

	// Wires

	wire n_CLK;
	wire PHI0;
	wire PHI1;
	wire PHI2;
	wire nACLK2;
	wire ACLK1;
	wire n_M2;

	wire RES;
	wire DBG_frompad;
	wire n_IRQINT;

	wire RW_fromcore;
	wire RW;
	wire RD;
	wire WR;

	wire n_R4018;
	wire n_R401A;
	wire n_R4015;
	wire W4002;
	wire W4001;
	wire W4005;
	wire W4006;
	wire W4008;
	wire W400A;
	wire W400B;
	wire W400E;
	wire W4013;
	wire W4012;
	wire W4010;
	wire W4014;
	wire n_R4019;
	wire W401A;
	wire W4003;
	wire W4007;
	wire W4004;
	wire W400C;
	wire W4000;
	wire W4015;
	wire W4011;
	wire W400F;
	wire n_R4017;
	wire n_R4016;
	wire W4016;
	wire W4017;

	wire Timer_Int;
	wire nLFO1;
	wire nLFO2;

	wire SQA_LC;
	wire SQB_LC;
	wire TRI_LC;
	wire RND_LC;
	wire NOSQA;
	wire NOSQB;
	wire NOTRI;
	wire NORND;

	wire n_DMCAB;
	wire RUNDMC;
	wire DMCRDY;
	wire DMCINT;
	wire [15:0] DMC_Addr;

	wire SPR_PPU;
	wire RDY_tocore;

	wire [7:0] DB;
	wire [15:0] Addr_fromcore;
	wire [15:0] Addr_topad;

	wire n_DBGRD;
	wire DebugLock;

	wire [3:0] SQA;
	wire [3:0] SQB;
	wire [3:0] RND;
	wire [3:0] TRI;
	wire [6:0] DMC;

	// Module instantiation

	ApuPadsLogic pads(
		.CLKPad(CLK),
		.n_CLK_frompad(n_CLK),
		.n_RESPad(n_RES),
		.RES_frompad(RES),
		.n_IRQPad(n_IRQ),
		.Timer_Int(Timer_Int),
		.n_IRQ_tocore(n_IRQINT),
		.n_M2_topad(n_M2),
		.M2Pad(M2),
		.DBGPad(DBG),
		.DBG_frompad(DBG_frompad),
		.RD(RD),
		.WR(WR),
		.DB(DB),
		.DPads(D),
		.RW_topad(RW),
		.RWPad(RnW),
		.Addr_topad(Addr_topad),
		.APads(A) );

	Core core(
		.core_PHI0(PHI0),
		.core_PHI1(PHI1),
		.core_PHI2(PHI2),
		.core_nNMI(n_NMI),
		.core_nIRQ(n_IRQINT),
		.core_nRES(~RES),
		.core_RDY(RDY_tocore), 
		.core_SO(1'b1),
		.core_RnW(RW_fromcore),
		.core_DPads(DB),
		.core_APads(Addr_fromcore) );

	CLK_Divider div(
		.n_CLK_frompad(n_CLK),
		.PHI0_tocore(PHI0),
		.PHI2_fromcore(PHI2),
		.n_M2_topad(n_M2) );

	ACLKGen aclk(
		.PHI1(PHI1),
		.PHI2(PHI2),
		.nACLK2(nACLK2),
		.ACLK1(ACLK1),
		.RES(RES) );

	SoftTimer softclk (
		.PHI1(PHI1),
		.ACLK1(ACLK1),
		.nACLK2(nACLK2),
		.RES(RES),
		.n_R4015(n_R4015),
		.W4017(W4017),
		.DB(DB),
		.DMCINT(DMCINT),
		.INT_out(Timer_Int),
		.nLFO1(nLFO1),
		.nLFO2(nLFO2) );

	DMABuffer sprdma_buf(
		.PHI2(PHI2),
		.SPR_PPU(SPR_PPU),
		.DB(DB),
		.RnW_fromcore(RW_fromcore),
		.RW_topad(RW),
		.n_R4015(n_R4015),
		.n_DBGRD(n_DBGRD),
		.WR_topad(WR),
		.RD_topad(RD) );

	ApuRegsDecoder regs(
		.PHI1(PHI1), 
		.Addr_fromcore(Addr_fromcore),
		.Addr_frommux(Addr_topad),
		.RnW_fromcore(RW_fromcore),
		.DBG_frompad(DBG_frompad), 
		.n_R4018(n_R4018),
		.n_R401A(n_R401A),
		.n_R4015(n_R4015),
		.W4002(W4002),
		.W4001(W4001),
		.W4005(W4005),
		.W4006(W4006),
		.W4008(W4008),
		.W400A(W400A),
		.W400B(W400B),
		.W400E(W400E),
		.W4013(W4013),
		.W4012(W4012),
		.W4010(W4010),
		.W4014(W4014),
		.n_R4019(n_R4019),
		.W401A(W401A),
		.W4003(W4003),
		.W4007(W4007),
		.W4004(W4004),
		.W400C(W400C),
		.W4000(W4000),
		.W4015(W4015),
		.W4011(W4011),
		.W400F(W400F),
		.n_R4017(n_R4017),
		.n_R4016(n_R4016),
		.W4016(W4016),
		.W4017(W4017),
		.n_DBGRD(n_DBGRD) );

	IOPorts io(
		.nACLK2(nACLK2),
		.ACLK1(ACLK1),
		.W4016(W4016),
		.n_R4016(n_R4016),
		.n_R4017(n_R4017),
		.DB(DB),
		.RES(RES),
		.OUT0_Pad(OUT0),
		.OUT1_Pad(OUT1),
		.OUT2_Pad(OUT2),
		.nIN0_Pad(n_IN0),
		.nIN1_Pad(n_IN1) );

	Sprite_DMA sprdma(
		.ACLK1(ACLK1),
		.nACLK2(nACLK2),
		.PHI1(PHI1),
		.RES(RES),
		.RnW(RW_fromcore),
		.W4014(W4014),
		.DB(DB), 
		.RUNDMC(RUNDMC),
		.n_DMCAB(n_DMCAB),
		.DMCRDY(DMCRDY),
		.DMC_Addr(DMC_Addr),
		.CPU_Addr(Addr_fromcore),
		.Addr(Addr_topad),
		.RDY_tocore(RDY_tocore),
		.SPR_PPU(SPR_PPU) );

	LengthCounters length(
		.nACLK2(nACLK2),
		.ACLK1(ACLK1),
		.RES(RES),
		.DB(DB),
		.n_R4015(n_R4015),
		.W4015(W4015),
		.nLFO2(nLFO2), 
		.W4003(W4003),
		.W4007(W4007),
		.W400B(W400B),
		.W400F(W400F),
		.SQA_LC(SQA_LC),
		.SQB_LC(SQB_LC),
		.TRI_LC(TRI_LC),
		.RND_LC(RND_LC),
		.NOSQA(NOSQA),
		.NOSQB(NOSQB),
		.NOTRI(NOTRI),
		.NORND(NORND) );

	SquareChan sqa(
		.nACLK2(nACLK2),
		.ACLK1(ACLK1), 
		.RES(RES),
		.DB(DB),
		.WR0(W4000),
		.WR1(W4001),
		.WR2(W4002),
		.WR3(W4003),
		.nLFO1(nLFO1),
		.nLFO2(nLFO2),
		.SQ_LC(SQA_LC),
		.NOSQ(NOSQA),
		.LOCK(DebugLock), 
		.AdderCarryMode(1'b1),
		.SQ_Out(SQA) );

	SquareChan sqb(
		.nACLK2(nACLK2),
		.ACLK1(ACLK1),
		.RES(RES),
		.DB(DB),
		.WR0(W4004),
		.WR1(W4005),
		.WR2(W4006),
		.WR3(W4007),
		.nLFO1(nLFO1),
		.nLFO2(nLFO2),
		.SQ_LC(SQB_LC),
		.NOSQ(NOSQB),
		.LOCK(DebugLock), 
		.AdderCarryMode(1'b0),
		.SQ_Out(SQB) );
	
	NoiseChan noise(
		.ACLK1(ACLK1),
		.nACLK2(nACLK2), 
		.RES(RES),
		.DB(DB),
		.W400C(W400C),
		.W400E(W400E),
		.W400F(W400F),
		.nLFO1(nLFO1),
		.RND_LC(RND_LC),
		.NORND(NORND),
		.LOCK(DebugLock),
		.RND_out(RND) );

	TriangleChan triangle (
		.PHI1(PHI1),
		.ACLK1(ACLK1),
		.RES(RES),
		.DB(DB),
		.W4008(W4008),
		.W400A(W400A),
		.W400B(W400B),
		.W401A(W401A),
		.nLFO1(nLFO1),
		.TRI_LC(TRI_LC),
		.NOTRI(NOTRI),
		.LOCK(DebugLock),
		.TRI_Out(TRI) );

	DPCMChan dpcm(
		.PHI1(PHI1),
		.ACLK1(ACLK1),
		.nACLK2(nACLK2), 
		.RES(RES),
		.DB(DB),		
		.RnW(RW_fromcore),
		.LOCK(DebugLock),
		.W4010(W4010),
		.W4011(W4011),
		.W4012(W4012),
		.W4013(W4013),
		.W4015(W4015),
		.n_R4015(n_R4015), 
		.n_DMCAB(n_DMCAB),
		.RUNDMC(RUNDMC),
		.DMCRDY(DMCRDY),
		.DMCINT(DMCINT),
		.DMC_Addr(DMC_Addr),
		.DMC_Out(DMC) );

	DAC_Square auxa(
		.SQA(SQA),
		.SQB(SQB),
		.AUX_A(AUX_A) );

	DAC_Others auxb(
		.TRI(TRI),
		.RND(RND),
		.DMC(DMC),
		.AUX_B(AUX_B) );

	Test dbg(
		.ACLK1(ACLK1),
		.RES(RES),
		.DB(DB),
		.W401A(W401A),
		.n_R4018(n_R4018),
		.n_R4019(n_R4019),
		.n_R401A(n_R401A),
		.SQA_in(SQA),
		.SQB_in(SQB),
		.TRI_in(TRI),
		.RND_in(RND),
		.DMC_in(DMC),
		.LOCK(DebugLock) );

endmodule // APU
