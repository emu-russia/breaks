
module Core(
	core_PHI0, core_PHI1, core_PHI2,
	core_nNMI, core_nIRQ, core_nRES, core_RDY, 
	core_SO, core_RnW, core_SYNC, core_DPads, core_APads);

	input core_PHI0;
	output core_PHI1;
	output core_PHI2;

	input core_nNMI;
	input core_nIRQ;
	input core_nRES;
	input core_RDY;

	input core_SO;
	output core_RnW;
	output core_SYNC;
	inout [7:0] core_DPads;
	output [15:0] core_APads;

	Core6502 embedded_6502 (
		.n_NMI(core_nNMI),
		.n_IRQ(core_nIRQ),
		.n_RES(core_nRES),
		.PHI0(core_PHI0),
		.PHI1(core_PHI1),
		.PHI2(core_PHI2),
		.RDY(core_RDY),
		.SO(core_SO),
		.RnW(core_RnW),
		.SYNC(core_SYNC),
		.A(core_APads),
		.D(core_DPads) );

endmodule // Core

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

	DivPhaseSplitter phase_split (
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

module DivPhaseSplitter(n_clk, q, nq);

	input n_clk;
	output q;
	output nq;

	(* keep = "true" *) wire not1_out;
	(* keep = "true" *) wire not2_out;

	assign not1_out = ~n_clk;
	assign not2_out = ~not1_out;

	nor (nq, not1_out, q);
	nor (q, nq, not2_out);

endmodule // DivPhaseSplitter
