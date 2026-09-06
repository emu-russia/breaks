module DLatch_x4 (
  input [3:0] val,
  input enable,
  output [3:0] n_val_out,
  output [3:0] val_out );

  dlatch u0 (.en(enable), .d(val[1]), .q(val_out[1]), .nq(n_val_out[1]));
  dlatch u1 (.en(enable), .d(val[2]), .q(val_out[2]), .nq(n_val_out[2]));
  dlatch u2 (.en(enable), .d(val[3]), .q(val_out[3]), .nq(n_val_out[3]));
  dlatch u3 (.en(enable), .d(val[0]), .q(val_out[0]), .nq(n_val_out[0]));
endmodule

module MUX_Control (
  output n_PAL4,
  output OCOL,
  output EXT,
  input n_ZPRIO,
  input n_PCLK,
  input PCLK,
  input [3:0] BGC,
  input [3:0] OBJC );
  wire w0;
  wire w1;
  wire w10;
  wire w11;
  wire w12;
  wire w13;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = ~(BGC[0] | BGC[1]);
  assign w1 = ~(OBJC[0] | OBJC[1]);
  assign w2 = ~n_ZPRIO;
  assign w3 = ~w0;
  assign w5 = ~(w3 & w4);
  assign w6 = ~w1;
  assign OCOL = w5 & w6;
  assign w7 = ~w1;
  assign EXT = ~(w8 | w9);
  dlatch u0 (.en(n_PCLK), .d(OCOL), .q(w10), .nq(n_PAL4));
  dlatch u1 (.en(PCLK), .d(w2), .q(w11), .nq(w4));
  dlatch u2 (.en(n_PCLK), .d(w3), .q(w8), .nq(w12));
  dlatch u3 (.en(n_PCLK), .d(w7), .q(w9), .nq(w13));
endmodule

module PictureMUX (
  output [4:0] CGA_out,
  output [3:0] n_EXT_out,
  input n_ZPRIO,
  input n_PCLK,
  input PCLK,
  input [3:0] BGC,
  input n_ZCOL0,
  input n_ZCOL1,
  input ZCOL2,
  input ZCOL3,
  input [3:0] EXT_in,
  input [4:0] THO,
  input TH_MUX );
  wire [3:0] bus1060_440;
  wire [3:0] bus1060_460;
  wire [3:0] bus1130_450;
  wire [3:0] bus1130_470;
  wire [3:0] bus1190_460;
  wire [3:0] bus170_460;
  wire [3:0] bus170_620;
  wire [3:0] bus330_280;
  wire [3:0] bus330_300;
  wire [3:0] bus390_440;
  wire [3:0] bus390_460;
  wire [3:0] bus390_600;
  wire [3:0] bus390_620;
  wire [3:0] bus600_450;
  wire [3:0] bus610_450;
  wire [3:0] bus650_440;
  wire [3:0] bus830_430;
  wire [3:0] bus830_450;
  wire [3:0] bus840_460;
  wire [3:0] bus890_440;
  wire [3:0] bus950_450;
  wire [3:0] bus1230_460;
  wire [3:0] bus280_610;
  wire [3:0] bus280_450;
  wire w0;
  wire w1;
  wire w10;
  wire w11;
  wire w12;
  wire w13;
  wire w14;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign {CGA_out[0], CGA_out[1], CGA_out[2], CGA_out[3]} = ~bus1190_460;
  assign bus280_450[0] = n_ZCOL0;
  assign bus280_450[1] = n_ZCOL1;
  assign bus280_450[2] = ~ZCOL2;
  assign bus280_450[3] = ~ZCOL3;
  assign n_EXT_out = ~bus650_440;
  assign bus1190_460 = TH_MUX ? bus1130_470 : bus1130_450;
  assign w2 = TH_MUX ? w1 : w0;
  assign bus650_440 = w3 ? bus600_450 : BGC;
  assign bus950_450 = w4 ? EXT_in : bus890_440;
  // color-mux / latch interconnections (from PPU_Evo.circ MUX_All wiring)
  assign bus1130_450 = bus1060_440; // step3_latch -> final mux D0
  assign bus1130_470 = bus390_600;  // dir_color_latch -> final mux D1
  assign bus600_450  = bus390_440;  // step1_latch -> color mux D1
  assign bus890_440  = bus830_430;  // step2_latch -> ext mux D0
  assign bus840_460  = bus950_450;  // ext mux -> step3_latch val
  assign bus170_460  = bus280_450;  // OBJ color -> step1_latch val
  assign bus170_620  = THO[3:0];    // THO[3:0] -> dir_color_latch val
  assign bus610_450  = ~bus650_440; // color mux (inv) -> step2_latch val
  assign bus330_280  = BGC;         // MUX_Control BGC
  assign bus330_300  = bus600_450;  // MUX_Control OBJC (step1 color)
  assign w5  = PCLK;    // step3_latch enable
  assign w8  = PCLK;    // step1_latch enable
  assign w9  = PCLK;    // dir_color_latch enable
  assign w14 = n_PCLK;  // step2_latch enable
  assign w10 = PCLK;    // MUX_Control PCLK
  assign w11 = n_PCLK;  // MUX_Control n_PCLK
  assign w12 = n_ZPRIO; // MUX_Control n_ZPRIO
  DLatch_x4 u0 (.enable(w5), .val(bus840_460), .val_out(bus1060_440), .n_val_out(bus1060_460));
  dlatch u1 (.en(PCLK), .d(w2), .q(w6), .nq(CGA_out[4]));
  dlatch u2 (.en(PCLK), .d(THO[4]), .q(w7), .nq(w1));
  DLatch_x4 u3 (.enable(w8), .val(bus170_460), .val_out(bus390_440), .n_val_out(bus390_460));
  DLatch_x4 u4 (.enable(w9), .val(bus170_620), .val_out(bus390_600), .n_val_out(bus390_620));
  MUX_Control u5 (.PCLK(w10), .n_PCLK(w11), .n_ZPRIO(w12), .BGC(bus330_280), .OBJC(bus330_300), .n_PAL4(w0), .OCOL(w3), .EXT(w4));
  DLatch_x4 u6 (.enable(w14), .val(bus610_450), .val_out(bus830_430), .n_val_out(bus830_450));
endmodule

module Spr0Hit(
	PCLK,
	BGC, n_SPR0HIT, n_SPR0_EV, n_VIS, n_R2, n_DBE, RESCL,
	DB6);

	input PCLK;

	input [3:0] BGC;
	input n_SPR0HIT;
	input n_SPR0_EV;
	input n_VIS;
	input n_R2;
	input n_DBE;
	input RESCL;
	inout DB6;

	wire bg;
	nor (bg, BGC[0], BGC[1]);  

	wire Strike;
	nor (Strike, PCLK, bg, n_SPR0HIT, n_SPR0_EV, n_VIS);	

	wire Strike_out;
	rsff STRIKE_FF (
		.r(RESCL),
		.s(Strike),
		.q(Strike_out) );

	wire R2_Ena;
	nor (R2_Ena, n_R2, n_DBE);
	bufif1 (DB6, Strike_out, R2_Ena);

endmodule // Spr0Hit