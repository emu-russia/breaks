
module BranchLogic(
	PHI1, PHI2,
	n_IR5, X, n_COUT, n_VOUT, n_NOUT, n_ZOUT, DB, BR2,
	n_BRTAKEN, BRFW);

	input PHI1;
	input PHI2;

	input n_IR5;
	input [129:0] X;
	input n_COUT;
	input n_VOUT;
	input n_NOUT;
	input n_ZOUT;
	inout [7:0] DB;
	input BR2;

	output n_BRTAKEN;
	output BRFW;

	// Branch forward

	wire br2_latch_q;
	wire br2_latch_nq;
	wire brfw_latch1_nq;
	wire brfw_latch2_q;
	wire brfw_latch1_d;

	dlatch br2_latch (.d(BR2), .en(PHI2), .q(br2_latch_q), .nq(br2_latch_nq));
	nor (brfw_latch1_d, br2_latch_q & ~DB[7], br2_latch_nq & brfw_latch2_q);
	dlatch brfw_latch1 (.d(brfw_latch1_d), .en(PHI1), .nq(brfw_latch1_nq));
	dlatch brfw_latch2 (.d(brfw_latch1_nq), .en(PHI2), .q(brfw_latch2_q));
	not (BRFW, brfw_latch1_nq);

	// Branch taken

	wire n_IR6;
	wire IR6;
	wire n_IR7;
	wire IR7;
	assign n_IR6 = X[121];
	assign n_IR7 = X[126];
	not (IR6, n_IR6);
	not (IR7, n_IR7);

	// The flag test logic is a 2-4 multiplexer

	wire ctest;
	wire vtest;
	wire ntest;
	wire ztest;

	nor (ctest, IR6, n_IR7, n_COUT);
	nor (vtest, n_IR6, IR7, n_VOUT);
	nor (ntest, IR6, IR7, n_NOUT);
	nor (ztest, n_IR6, n_IR7, n_ZOUT);

	wire mux_out;
	nor (mux_out, ctest, vtest, ntest, ztest);

	xor (n_BRTAKEN, mux_out, n_IR5);

endmodule // BranchLogic
