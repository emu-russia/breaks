
module NoiseChan(
	n_ACLK, ACLK, 
	RES, DB, W400A, W400B, W400C, W400E, W400F, nLFO1, RND_LC, NORND, LOCK, 
	RND_out);

	input n_ACLK;
	input ACLK;

	input RES;
	inout [7:0] DB;
	input W400A;
	input W400B;
	input W400C;
	input W400E;
	input W400F;
	input nLFO1;
	output RND_LC;
	input NORND;
	input LOCK;	

	output [3:0] RND_out;

endmodule // NoiseChan
