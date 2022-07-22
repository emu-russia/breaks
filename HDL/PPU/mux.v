
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
