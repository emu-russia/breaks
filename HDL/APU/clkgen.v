
module CLK_Divider(n_CLK_frompad, PHI0_tocore, PHI2_fromcore, n_M2_topad);

	input n_CLK_frompad;
	output PHI0_tocore;
	input PHI2_fromcore;
	output n_M2_topad;

	wire [5:0] sout;
	wire rst;
	wire q;
	wire nq;
	wire nval_4;

	DivPhaseSpiltter phase_split (
		.n_clk(n_CLK_frompad),
		.q(q),
		.nq(nq) );

	assign PHI0_tocore = ~sout[5];
	nor (rst, PHI0_tocore, sout[4]);

	DivSRBit sr0 (.q(q), .nq(nq), .rst(rst), .sin(PHI0_tocore), .sout(sout[0]));
	DivSRBit sr1 (.q(q), .nq(nq), .rst(rst), .sin(sout[0]), .sout(sout[1]));
	DivSRBit sr2 (.q(q), .nq(nq), .rst(rst), .sin(sout[1]), .sout(sout[2]));
	DivSRBit sr3 (.q(q), .nq(nq), .rst(rst), .sin(sout[2]), .sout(sout[3]));
	DivSRBit sr4 (.q(q), .nq(nq), .rst(1'b0), .sin(sout[3]), .sout(sout[4]), .n_val(nval_4));
	DivSRBit sr5 (.q(q), .nq(nq), .rst(1'b0), .sin(sout[4]), .sout(sout[5]));

	nor (n_M2_topad, nval_4, PHI2_fromcore);

endmodule // CLK_Divider

module DivSRBit(q, nq, rst, sin, n_val, sout);

	input q;
	input nq;
	input rst;
	input sin;
	output n_val;
	output sout;

	wire out_val;

	dlatch in_latch (
		.d(sin),
		.en(q),
		.nq(n_val) );

	dlatch out_latch (
		.d(n_val),
		.en(nq),
		.q(out_val) );

	nor (sout, out_val, rst);

endmodule // DivSRBit

module DivPhaseSpiltter(n_clk, q, nq);

	input n_clk;
	output q;
	output nq;

	(* keep = "true" *) wire not1_out;
	(* keep = "true" *) wire not2_out;

	assign not1_out = ~n_clk;
	assign not2_out = ~not1_out;

	nor (nq, not1_out, q);
	nor (q, nq, not2_out);

endmodule // DivPhaseSpiltter

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
