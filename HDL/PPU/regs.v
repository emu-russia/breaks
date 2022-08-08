
module PpuRegs(
	RC, n_DBE, RS, RnW, CPU_DB, 
	n_W5_1, n_W5_2, n_W6_1, n_W6_2,
	n_R7, n_W7, n_W4, n_W3, n_R2, n_W1, n_W0, n_R4, 
	I_1_32, OBSEL, BGSEL, O_8_16, n_SLAVE, VBL, 
	BnW, n_BGCLIP, n_OBCLIP, BGE, BLACK, OBE, n_TR, n_TG, n_TB);

	input RC;
	input n_DBE;
	input [2:0] RS;
	input RnW;
	inout [7:0] CPU_DB;

	output n_W5_1;
	output n_W5_2;
	output n_W6_1;
	output n_W6_2;

	output n_R7;
	output n_W7;
	output n_W4;
	output n_W3;
	output n_R2;
	output n_W1;
	output n_W0;
	output n_R4;

	output I_1_32;
	output OBSEL;
	output BGSEL;
	output O_8_16;
	output n_SLAVE;
	output VBL;

	output BnW;
	output n_BGCLIP;
	output n_OBCLIP;
	output BGE;
	output BLACK;
	output OBE;
	output n_TR;
	output n_TG;
	output n_TB;

	wire n_W56;
	wire sccx_first;
	wire sccx_second;

	SCCXFirstSecond fs(
		.RC(RC),
		.n_DBE(n_DBE),
		.n_R2(n_R2),
		.n_W56(n_W56),
		.Frst(sccx_first),
		.Scnd(sccx_second) );

	RegCTRL0 ctrl0(
		.RC(RC),
		.n_W0(n_W0),
		.n_DBE(n_DBE),
		.D_in(CPU_DB),
		.I_1_32(I_1_32),
		.OBSEL(OBSEL),
		.BGSEL(BGSEL),
		.O_8_16(O_8_16),
		.n_SLAVE(n_SLAVE),
		.VBL(VBL) );

	RegCTRL1 ctrl1(
		.RC(RC),
		.n_W1(n_W1),
		.n_DBE(n_DBE),
		.D_in(CPU_DB),
		.BnW(BnW),
		.n_BGCLIP(n_BGCLIP),
		.n_OBCLIP(n_OBCLIP),
		.BGE(BGE),
		.BLACK(BLACK),
		.OBE(OBE),
		.n_TR(n_TR),
		.n_TG(n_TG),
		.n_TB(n_TB) );

endmodule // Regs

module SCCXFirstSecond(RC, n_DBE, n_R2, n_W56, Frst, Scnd);

	input RC;
	input n_DBE;
	input n_R2;
	input n_W56;
	output Frst;
	output Scnd;

	wire q1;
	wire nq1;
	wire q2;
	wire nq2;
	wire W56;
	wire R2;

	assign R2 = n_R2 ~| n_DBE;
	assign W56 = n_W56 ~| n_DBE;

	sdffr2e FF_1 (.d(q2), .en(~W56), .res1(RC), .res2(R2), .phi_keep(W56), .q(q1), .nq(nq1) );
	sdffr2e FF_2 (.d(nq1), .en(W56), .res1(RC), .res2(R2), .phi_keep(~W56), .q(q2), .nq(nq2) );

	assign Frst = q1;
	assign Scnd = nq1;

endmodule // SCCXFirstSecond

module RegCTRL0(RC, n_W0, n_DBE, D_in, I_1_32, OBSEL, BGSEL, O_8_16, n_SLAVE, VBL);

	input RC;
	input n_W0;
	input n_DBE;
	inout [7:0] D_in;

	output I_1_32;
	output OBSEL;
	output BGSEL;
	output O_8_16;
	output n_SLAVE;
	output VBL;

endmodule // RegCTRL0

module RegCTRL1(RC, n_W1, n_DBE, D_in, BnW, n_BGCLIP, n_OBCLIP, BGE, BLACK, OBE, n_TR, n_TG, n_TB);

	input RC;
	input n_W1;
	input n_DBE;
	inout [7:0] D_in;

	output BnW;
	output n_BGCLIP;
	output n_OBCLIP;
	output BGE;
	output BLACK;
	output OBE;
	output n_TR;
	output n_TG;
	output n_TB;

endmodule // RegCTRL1

module Clipper(n_PCLK, n_VIS, CLIP_B, CLIP_O, BGE, OBE, n_CLPB, CLPO);

	input n_PCLK;
	input n_VIS;
	input CLIP_B;
	input CLIP_O;
	input BGE;
	input OBE;

	output n_CLPB;
	output CLPO;

endmodule // Clipper

module RWDecoder(RnW, n_DBE, n_RD, n_WR);

	input RnW;
	input n_DBE;
	output n_RD;
	output n_WR;

	assign n_RD = ~( ~RnW ~| n_DBE );
	assign n_WR = ~( RnW ~| n_DBE );

endmodule // RWDecoder
