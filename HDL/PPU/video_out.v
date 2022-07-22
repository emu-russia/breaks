
module VideoGen(
	n_CLK, CLK, n_PCLK, PCLK, 
	RES, n_CC, n_LL, BURST, SYNC, n_PICTURE, n_TR, n_TG, n_TB, 
	VOut);

	input n_CLK;
	input CLK;
	input n_PCLK;
	input PCLK;

	input RES;
	input [3:0] n_CC;
	input [1:0] n_LL;
	input BURST;
	input SYNC;
	input n_PICTURE;
	input n_TR;
	input n_TG;
	input n_TB;

	output VOut;

endmodule // VideoGen
