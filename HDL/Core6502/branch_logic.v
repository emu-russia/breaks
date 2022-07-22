
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

endmodule // BranchLogic
