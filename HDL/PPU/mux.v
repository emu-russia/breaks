
module PictureMUX(
	n_PCLK, PCLK, 
	BGC, n_ZPRIO, n_ZCOL0, n_ZCOL1, ZCOL2, ZCOL3, EXT_in, THO, TH_MUX,
	PAL_out, n_EXT_out);

	input n_PCLK;
	input PCLK;

	input [3:0] BGC;
	input n_ZPRIO;
	input n_ZCOL0;
	input n_ZCOL1;
	input ZCOL2;
	input ZCOL3;
	input [3:0] EXT_in;
	input [4:0] THO;
	input TH_MUX;

	output [4:0] PAL_out;
	output [3:0] n_EXT_out;

endmodule // PictureMUX

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
