
module CLK_Divider(n_CLK_frompad, PHI0_tocore, PHI2_fromcore, n_M2_topad);

	input n_CLK_frompad;
	output PHI0_tocore;
	input PHI2_fromcore;
	output n_M2_topad;

endmodule // CLK_Divider

module ACLKGen(PHI1, PHI2, ACLK, n_ACLK, RES);

	input PHI1;
	input PHI2;
	output ACLK;
	output n_ACLK;
	input RES;

	wire n_latch1_out;
	wire n_latch2_out;
	wire latch1_in;

	dlatch latch1 (
		.d(latch1_in),
		.en(PHI1),
		.nq(n_latch1_out) );

	dlatch latch2 (
		.d(n_latch1_out),
		.en(PHI2),
		.nq(n_latch2_out) );

	nor (latch1_in, RES, n_latch2_out);

	wire n1;
	nor (n1, ~PHI1, latch1_in);
	nor (n_ACLK, ~PHI1, n_latch2_out);
	not (ACLK, n1);
	assign ACLK = ~n1;

endmodule // ACLKGen

module SoftTimer(
	PHI1, n_ACLK, ACLK,
	RES, n_R4015, W4017, DB, DMCINT, INT_out, nLFO1, nLFO2);

	input PHI1;
	input n_ACLK;
	input ACLK;

	input RES;
	input n_R4015;
	input W4017;
	inout [7:0] DB;
	input DMCINT;
	output INT_out;
	output nLFO1;
	output nLFO2;

endmodule // SoftTimer
