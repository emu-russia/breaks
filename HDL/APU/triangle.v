
module TriangleChan(
	PHI1, n_ACLK,
	RES, DB, W4008, W400A, W400B, W401A, nLFO1, TRI_LC, NOTRI, LOCK,
	TRI_Out);

	input PHI1;
	input n_ACLK;

	input RES;
	inout [7:0] DB;
	input W4008;
	input W400A;
	input W400B;
	input W401A;
	input nLFO1;
	output TRI_LC;
	input NOTRI;
	input LOCK;

	output [3:0] TRI_Out;

	// Internal wires

	wire TCO;
	wire n_FOUT;
	wire LOAD;
	wire STEP;
	wire TSTEP;

	// Instantiate

	TRIANGLE_Control ctrl (.PHI1(PHI1), .n_ACLK(n_ACLK), .W4008(W4008), .W400B(W400B), .n_LFO1(nLFO1), .NOTRI(NOTRI), .LOCK(LOCK), .TCO(TCO), .n_FOUT(n_FOUT),
		.DB(DB), .TRI_LC(TRI_LC), .LOAD(LOAD), .STEP(STEP), .TSTEP(TSTEP) );

	TRIANGLE_LinearCounter lin_cnt (.n_ACLK(n_ACLK), .RES(RES), .W4008(W4008), .LOAD(LOAD), .STEP(STEP), .DB(DB), .TCO(TCO) );

	TRIANGLE_FreqCounter freq_cnt (.PHI1(PHI1), .RES(RES), .W400A(W400A), .W400B(W400B), .DB(DB), .n_FOUT(n_FOUT) );

	TRIANGLE_Output tri_out (.PHI1(PHI1), .RES(RES), .W401A(W401A), .TSTEP(TSTEP), .DB(DB), .TRI_Out(TRI_Out) );

endmodule // TriangleChan

module TRIANGLE_Control (PHI1, n_ACLK, W4008, W400B, n_LFO1, NOTRI, LOCK, TCO, n_FOUT, DB, TRI_LC, LOAD, STEP, TSTEP);

	input PHI1;
	input n_ACLK;
	input W4008;
	input W400B;
	input n_LFO1;
	input NOTRI;
	input LOCK;
	input TCO;
	input n_FOUT;
	inout [7:0] DB;
	output TRI_LC;
	output LOAD;
	output STEP;
	output TSTEP;

endmodule // TRIANGLE_Control

module TRIANGLE_LinearCounter (n_ACLK, RES, W4008, LOAD, STEP, DB, TCO);

	input n_ACLK;
	input RES;
	input W4008;
	input LOAD;
	input STEP;
	inout [7:0] DB;
	output TCO;

endmodule // TRIANGLE_LinearCounter

module TRIANGLE_FreqCounter (PHI1, RES, W400A, W400B, DB, n_FOUT);

	input PHI1;
	input RES;
	input W400A;
	input W400B;
	inout [7:0] DB;
	output n_FOUT;

endmodule // TRIANGLE_FreqCounter

module TRIANGLE_Output (PHI1, RES, W401A, TSTEP, DB, TRI_Out);

	input PHI1;
	input RES;
	input W401A;
	input TSTEP;
	inout [7:0] DB;
	output [3:0] TRI_Out;

endmodule // TRIANGLE_Output
