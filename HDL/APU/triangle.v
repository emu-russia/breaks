
module TriangleChan(
	PHI1, n_ACLK,
	RES, DB, W4008, W400B, W401A, nLFO1, TRI_LC, NOTRI, LOCK,
	TRI_Out);

	input PHI1;
	input n_ACLK;

	input RES;
	inout [7:0] DB;
	input W4008;
	input W400B;
	input W401A;
	input nLFO1;
	output TRI_LC;
	input NOTRI;
	input LOCK;

	output [3:0] TRI_Out;

endmodule // TriangleChan
