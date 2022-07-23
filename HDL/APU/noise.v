
module NoiseChan(
	n_ACLK, ACLK, 
	RES, DB, LOCK, W400C, W400E, W400F,
	RND_out);

	input n_ACLK;
	input ACLK;

	input RES;
	inout [7:0] DB;
	input LOCK;
	input W400C;
	input W400E;
	input W400F;

	output [3:0] RND_out;

endmodule // NoiseChan
