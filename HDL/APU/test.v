
module Test(
	n_ACLK,
	RES, DB, W401A, n_R4018, n_R4019, n_R401A,
	SQA_in, SQB_in, TRI_in, RND_in, DMC_in,
	LOCK);

	input n_ACLK;

	input RES;
	inout [7:0] DB;
	input W401A;
	input n_R4018;
	input n_R4019;
	input n_R401A;

	input [3:0] SQA_in;
	input [3:0] SQB_in;
	input [3:0] TRI_in;
	input [3:0] RND_in;
	input [5:0] DMC_in;

	output LOCK;

endmodule // Test
