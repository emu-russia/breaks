module RegSelect (
  output n_W6_1,
  output n_W6_2,
  output n_W5_1,
  output n_W5_2,
  output n_W56,
  output n_R7,
  output n_W7,
  output n_W4,
  output n_W3,
  output n_R2,
  output n_W1,
  output n_W0,
  output n_R4,
  input RS1,
  input RS2,
  input RnW,
  input First,
  input Scnd,
  input RS0 );
  wire w0;
  wire w1;
  wire w10;
  wire w11;
  wire w12;
  wire w13;
  wire w14;
  wire w15;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = ~RS0;
  assign w1 = ~RS1;
  assign w2 = ~RS2;
  assign w3 = ~RnW;
  assign w4 = ~(RS0 | w2 | w1 | RnW | Scnd);
  assign w5 = ~(RS0 | w2 | w1 | RnW | First);
  assign w6 = ~(w2 | RS1 | w0 | RnW | Scnd);
  assign w7 = ~(w2 | RS1 | w0 | RnW | First);
  assign n_W6_1 = ~w4;
  assign n_W6_2 = ~w5;
  assign n_W5_1 = ~w6;
  assign n_W5_2 = ~w7;
  assign n_W56 = ~(w7 | w6 | w5 | w4);
  assign w8 = ~(w2 | w1 | w0 | w3);
  assign w9 = ~(w2 | w1 | w0 | RnW);
  assign w10 = ~(w2 | RS1 | RS0 | RnW);
  assign w11 = ~(RS2 | w1 | w0 | RnW);
  assign w12 = ~(RS2 | w1 | RS0 | w3);
  assign w13 = ~(RS2 | RS1 | w0 | RnW);
  assign w14 = ~(RS2 | RS1 | RS0 | RnW);
  assign w15 = ~(w2 | RS1 | RS0 | w3);
  assign n_R7 = ~w8;
  assign n_W7 = ~w9;
  assign n_W4 = ~w10;
  assign n_W3 = ~w11;
  assign n_R2 = ~w12;
  assign n_W1 = ~w13;
  assign n_W0 = ~w14;
  assign n_R4 = ~w15;
endmodule

module RegFF (
  input Enable,
  input Val_in,
  input Res,
  output Val_out );
  wire w0;
  wire w1;

  assign w1 = ~w0;
  assign Val_out = ~(Res | w1);
  assign w0 = Enable ? Val_in : Val_out;
endmodule

module RegCTRL0 (
  input n_DBE,
  input RC,
  input n_W0,
  input [7:0] D_in,
  output I_1_32,
  output OBSEL,
  output BGSEL,
  output O_8_16,
  output n_SLAVE,
  output VBL );
  wire w0;
  wire w1;
  wire w10;
  wire w11;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = ~(n_W0 | n_DBE);
  assign w1 = ~w0;
  assign I_1_32 = ~w2;
  assign O_8_16 = ~w3;
  RegFF u0 (.Res(RC), .Enable(w0), .Val_in(D_in[3]), .Val_out(w4));
  RegFF u1 (.Res(RC), .Enable(w0), .Val_in(D_in[4]), .Val_out(w5));
  RegFF u2 (.Res(RC), .Enable(w0), .Val_in(D_in[5]), .Val_out(w6));
  RegFF u3 (.Res(RC), .Enable(w0), .Val_in(D_in[6]), .Val_out(n_SLAVE));
  RegFF u4 (.Res(RC), .Enable(w0), .Val_in(D_in[7]), .Val_out(VBL));
  RegFF u5 (.Res(RC), .Enable(w0), .Val_in(D_in[2]), .Val_out(w7));
  dlatch u6 (.en(w1), .d(w7), .q(w8), .nq(w2));
  dlatch u7 (.en(w1), .d(w4), .q(w9), .nq(OBSEL));
  dlatch u8 (.en(w1), .d(w5), .q(w10), .nq(BGSEL));
  dlatch u9 (.en(w1), .d(w6), .q(w11), .nq(w3));
endmodule

module RegCTRL1 (
  input n_DBE,
  input RC,
  input n_W1,
  input [7:0] D_in,
  output n_BGCLIP,
  output n_OBCLIP,
  output BGE,
  output BLACK,
  output OBE,
  output n_TR,
  output n_TG,
  output n_TB,
  output BnW );
  wire w0;
  wire w1;
  wire w10;
  wire w11;
  wire w12;
  wire w13;
  wire w14;
  wire w15;
  wire w16;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = ~(n_W1 | n_DBE);
  assign w1 = ~w0;
  assign n_TB = ~w2;
  assign n_BGCLIP = ~w3;
  assign n_OBCLIP = ~w4;
  assign BLACK = ~(BGE | OBE);
  RegFF u0 (.Res(RC), .Enable(w0), .Val_in(D_in[1]), .Val_out(w5));
  RegFF u1 (.Res(RC), .Enable(w0), .Val_in(D_in[2]), .Val_out(w6));
  RegFF u2 (.Res(RC), .Enable(w0), .Val_in(D_in[3]), .Val_out(w7));
  RegFF u3 (.Res(RC), .Enable(w0), .Val_in(D_in[4]), .Val_out(w8));
  RegFF u4 (.Res(RC), .Enable(w0), .Val_in(D_in[5]), .Val_out(w9));
  RegFF u5 (.Res(RC), .Enable(w0), .Val_in(D_in[6]), .Val_out(w10));
  RegFF u6 (.Res(RC), .Enable(w0), .Val_in(D_in[7]), .Val_out(w2));
  RegFF u7 (.Res(RC), .Enable(w0), .Val_in(D_in[0]), .Val_out(BnW));
  dlatch u8 (.en(w1), .d(w5), .q(w11), .nq(w3));
  dlatch u9 (.en(w1), .d(w6), .q(w12), .nq(w4));
  dlatch u10 (.en(w1), .d(w7), .q(BGE), .nq(w13));
  dlatch u11 (.en(w1), .d(w8), .q(OBE), .nq(w14));
  dlatch u12 (.en(w1), .d(w9), .q(w15), .nq(n_TR));
  dlatch u13 (.en(w1), .d(w10), .q(w16), .nq(n_TG));
endmodule

module Clipper (
  input n_VIS,
  input CLIP_B,
  input CLIP_O,
  input BGE,
  input OBE,
  input n_PCLK,
  output n_CLPB,
  output CLPO );
  wire w0;
  wire w1;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;

  assign w0 = ~BGE;
  assign w1 = ~OBE;
  assign n_CLPB = ~(w2 | w3 | w0);
  assign w4 = ~(w2 | CLIP_O | w1);
  dlatch u0 (.en(n_PCLK), .d(CLIP_B), .q(w3), .nq(w5));
  dlatch u1 (.en(n_PCLK), .d(n_VIS), .q(w2), .nq(w6));
  dlatch u2 (.en(n_PCLK), .d(w4), .q(w7), .nq(CLPO));
endmodule

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
	wire First;
	wire Scnd;

	SCCXFirstSecond fs(
		.n_DBE(n_DBE), .n_R2(n_R2), .n_W56(n_W56), .RC(RC),
		.Frst(First), .Scnd(Scnd) );

	RegSelect sel(
		.RS0(RS[0]), .RS1(RS[1]), .RS2(RS[2]), .RnW(RnW),
		.First(First), .Scnd(Scnd),
		.n_W6_1(n_W6_1), .n_W6_2(n_W6_2), .n_W5_1(n_W5_1), .n_W5_2(n_W5_2),
		.n_W56(n_W56), .n_R7(n_R7), .n_W7(n_W7), .n_W4(n_W4), .n_W3(n_W3),
		.n_R2(n_R2), .n_W1(n_W1), .n_W0(n_W0), .n_R4(n_R4) );

	RegCTRL0 ctrl0(
		.RC(RC), .n_W0(n_W0), .n_DBE(n_DBE), .D_in(CPU_DB),
		.I_1_32(I_1_32), .OBSEL(OBSEL), .BGSEL(BGSEL), .O_8_16(O_8_16),
		.n_SLAVE(n_SLAVE), .VBL(VBL) );

	RegCTRL1 ctrl1(
		.RC(RC), .n_W1(n_W1), .n_DBE(n_DBE), .D_in(CPU_DB),
		.BnW(BnW), .n_BGCLIP(n_BGCLIP), .n_OBCLIP(n_OBCLIP), .BGE(BGE),
		.BLACK(BLACK), .OBE(OBE), .n_TR(n_TR), .n_TG(n_TG), .n_TB(n_TB) );

endmodule // PpuRegs
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

	nor (R2, n_R2, n_DBE);
	nor (W56, n_W56, n_DBE);

	sdffr2e FF_1 (.d(q2), .en(~W56), .res1(RC), .res2(R2), .phi_keep(W56), .q(q1), .nq(nq1) );
	sdffr2e FF_2 (.d(nq1), .en(W56), .res1(RC), .res2(R2), .phi_keep(~W56), .q(q2), .nq(nq2) );

	assign Frst = q1;
	assign Scnd = nq1;

endmodule // SCCXFirstSecond

module RWDecoder(RnW, n_DBE, n_RD, n_WR);

	input RnW;
	input n_DBE;
	output n_RD;
	output n_WR;

	wire RD;
	wire WR;

	nor (RD, ~RnW, n_DBE);
	nor (WR, RnW, n_DBE);
	not (n_RD, RD);
	not (n_WR, WR);

endmodule // RWDecoder
