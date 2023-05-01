
// Debugging mechanisms of the 2A03G APU revision (so called "Test Mode").

module Test(
	ACLK1,
	RES, DB, W401A, n_R4018, n_R4019, n_R401A,
	SQA_in, SQB_in, TRI_in, RND_in, DMC_in,
	LOCK);

	input ACLK1;

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
	input [6:0] DMC_in;

	output LOCK;

	sdffre LOCK_FF(
		.d(DB[7]),
		.en(W401A),
		.res(RES),
		.phi_keep(ACLK1),
		.q(LOCK) );

	bustris sqa_tris [3:0] (
		.a(~SQA_in),
		.n_x(DB[3:0]),
		.n_en(n_R4018) );

	bustris sqb_tris [3:0] (
		.a(~SQB_in),
		.n_x(DB[7:4]),
		.n_en(n_R4018) );

	bustris tria_tris [3:0] (
		.a(~TRI_in),
		.n_x(DB[3:0]),
		.n_en(n_R4019) );

	bustris rnd_tris [3:0] (
		.a(~RND_in),
		.n_x(DB[7:4]),
		.n_en(n_R4019) );

	bustris dmc_tris [6:0] (
		.a(~DMC_in),
		.n_x(DB[6:0]),
		.n_en(n_R401A) );

endmodule // Test
