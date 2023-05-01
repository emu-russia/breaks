
module TriangleChan(
	PHI1, ACLK1,
	RES, DB, W4008, W400A, W400B, W401A, nLFO1, TRI_LC, NOTRI, LOCK,
	TRI_Out);

	input PHI1;
	input ACLK1;

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

	TRIANGLE_Control ctrl (.PHI1(PHI1), .ACLK1(ACLK1), .W4008(W4008), .W400B(W400B), .n_LFO1(nLFO1), .NOTRI(NOTRI), .LOCK(LOCK), .TCO(TCO), .n_FOUT(n_FOUT),
		.DB(DB), .TRI_LC(TRI_LC), .LOAD(LOAD), .STEP(STEP), .TSTEP(TSTEP) );

	TRIANGLE_LinearCounter lin_cnt (.ACLK1(ACLK1), .RES(RES), .W4008(W4008), .LOAD(LOAD), .STEP(STEP), .DB(DB), .TCO(TCO) );

	TRIANGLE_FreqCounter freq_cnt (.PHI1(PHI1), .RES(RES), .W400A(W400A), .W400B(W400B), .DB(DB), .n_FOUT(n_FOUT) );

	TRIANGLE_Output tri_out (.PHI1(PHI1), .RES(RES), .W401A(W401A), .TSTEP(TSTEP), .DB(DB), .TRI_Out(TRI_Out) );

endmodule // TriangleChan

module TRIANGLE_Control (PHI1, ACLK1, W4008, W400B, n_LFO1, NOTRI, LOCK, TCO, n_FOUT, DB, TRI_LC, LOAD, STEP, TSTEP);

	input PHI1;
	input ACLK1;
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

	wire TRELOAD;
	wire lc_reg_q;
	wire Reload_FF_q;
	wire reload_latch1_q;
	wire reload_latch2_q;
	wire reload_latch2_nq;
	wire tco_latch_q;

	RegisterBit lc_reg (.ACLK1(ACLK1), .ena(W4008), .d(DB[7]), .q(lc_reg_q), .nq(TRI_LC) );

	rsff Reload_FF (.r(W400B), .s(~(reload_latch1_q | lc_reg_q | n_LFO1)), .q(Reload_FF_q), .nq(TRELOAD) );

	dlatch reload_latch1 (.d(Reload_FF_q), .en(ACLK1), .q(reload_latch1_q) );
	dlatch reload_latch2 (.d(TRELOAD), .en(ACLK1), .q(reload_latch2_q), .nq(reload_latch2_nq) );
	dlatch tco_latch (.d(TCO), .en(ACLK1), .q(tco_latch_q) );

	nor (LOAD, n_LFO1, reload_latch2_nq);
	nor (STEP, n_LFO1, reload_latch2_q, tco_latch_q);
	nor (TSTEP, TCO, LOCK, PHI1, NOTRI, n_FOUT);

endmodule // TRIANGLE_Control

module TRIANGLE_LinearCounter (ACLK1, RES, W4008, LOAD, STEP, DB, TCO);

	input ACLK1;
	input RES;
	input W4008;
	input LOAD;
	input STEP;
	inout [7:0] DB;
	output TCO;

	wire [6:0] lq;
	wire [6:0] cout;

	RegisterBit lin_reg [6:0] (.ACLK1(ACLK1), .ena(W4008), .d(DB[6:0]), .q(lq) );
	DownCounterBit lin_cnt [6:0] (.ACLK1(ACLK1), .d(lq), .load(LOAD), .clear(RES), .step(STEP), .cin({cout[5:0],1'b1}), .cout(cout) );
	assign TCO = cout[6];

endmodule // TRIANGLE_LinearCounter

module TRIANGLE_FreqCounter (PHI1, RES, W400A, W400B, DB, n_FOUT);

	input PHI1;
	input RES;
	input W400A;
	input W400B;
	inout [7:0] DB;
	output n_FOUT;

	wire FLOAD;
	wire FSTEP;
	wire FOUT;
	wire [10:0] fq;
	wire [10:0] cout;

	RegisterBit freq_reg [10:0] (.ACLK1(PHI1), .ena({ {3{W400B}}, {8{W400A}} }), .d({DB[2:0],DB[7:0]}), .q(fq) );
	DownCounterBit freq_cnt [10:0] (.ACLK1(PHI1), .d(fq), .load(FLOAD), .clear(RES), .step(FSTEP), .cin({cout[9:0],1'b1}), .cout(cout) );
	assign FOUT = cout[10];

	dlatch fout_latch (.d(FOUT), .en(PHI1), .nq(n_FOUT) );

	nor (FLOAD, PHI1, n_FOUT);
	nor (FSTEP, PHI1, ~n_FOUT);

endmodule // TRIANGLE_FreqCounter

module TRIANGLE_Output (PHI1, RES, W401A, TSTEP, DB, TRI_Out);

	input PHI1;
	input RES;
	input W401A;
	input TSTEP;
	inout [7:0] DB;
	output [3:0] TRI_Out;

	wire [4:0] cout;
	wire [4:0] T;
	wire [4:0] nT;

	// The developers decided to use PHI1 for the triangle channel instead of ACLK to smooth out the "stepped" signal.
	CounterBit out_cnt [4:0] (.ACLK1(PHI1), .d(DB[4:0]), .load(W401A), .clear(RES), .step(TSTEP), .cin({cout[3:0],1'b1}), .q(T), .nq(nT), .cout(cout) );
	assign TRI_Out = ~(T[4] ? nT[3:0] : T[3:0]);

endmodule // TRIANGLE_Output
