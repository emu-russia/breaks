
module CLK_Divider(n_CLK_frompad, PHI0_tocore, PHI2_fromcore, n_M2_topad);

	input n_CLK_frompad;
	output PHI0_tocore;
	input PHI2_fromcore;
	output n_M2_topad;

endmodule // CLK_Divider

module ACLKGen(PHI1, PHI2, ACLK, n_ACLK);

	input PHI1;
	input PHI2;
	output ACLK;
	output n_ACLK;

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
