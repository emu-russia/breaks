
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

	wire n_mode;
	wire mode;
	wire [5:0] PLA_out;
	wire Z2;
	wire F1;
	wire F2;
	wire sin;
	wire [14:0] sout;
	wire [14:0] n_sout;

	FrameCnt_Control fcnt_ctl (
		.PHI1(PHI1),
		.n_ACLK(n_ACLK),
		.RES(RES),
		.DB(DB),
		.DMCINT(DMCINT),
		.n_R4015(n_R4015),
		.W4017(W4017),
		.PLA_in(PLA_out),
		.n_mdout(n_mode),
		.mdout(mode),
		.Timer_Int(INT_out) );

	FrameCnt_LFSR_Control lfsr_ctl(
		.n_ACLK(n_ACLK),
		.ACLK(ACLK),
		.RES(RES),
		.W4017(W4017),
		.n_mode(n_mode),
		.mode(mode),
		.PLA_in(PLA_out),
		.C13(sout[13]),
		.C14(sout[14]),
		.Z2(Z2),
		.F1(F1),
		.F2(F2),
		.sin_toLFSR(sin) );

	FrameCnt_LFSR lfsr (
		.n_ACLK(n_ACLK),
		.F1(F1),
		.F2(F2),
		.sin(sin),
		.sout(sout),
		.n_sout(n_sout) );

	FrameCnt_PLA pla (
		.s(sout),
		.ns(n_sout),
		.md(mode),
		.PLA_out(PLA_out) );

	// LFO Output

	wire tmp1;
	nor (tmp1, PLA_out[0], PLA_out[1], PLA_out[2], PLA_out[3], PLA_out[4], Z2);
	wire tmp2;
	nor (tmp2, tmp1, ACLK);
	assign nLFO1 = ~tmp2;

	wire tmp3;
	nor (tmp3, PLA_out[1], PLA_out[3], PLA_out[4], Z2);
	wire tmp4;
	nor (tmp4, tmp3, ACLK);
	assign nLFO2 = ~tmp4;

endmodule // SoftTimer

module FrameCnt_Control(
	PHI1, n_ACLK,
	RES, DB, DMCINT, n_R4015, W4017, PLA_in,
	n_mdout, mdout, Timer_Int);

	input PHI1;
	input n_ACLK;

	input RES;
	inout [7:0] DB;
	input DMCINT;
	input n_R4015;
	input W4017;
	input [5:0] PLA_in;

	output n_mdout;
	output mdout;
	output Timer_Int;

	wire R4015_clear;
	wire mask_clear;
	wire intff_out;
	wire n_intff_out;
	wire int_sum;
	wire int_latch_out;

	nor (R4015_clear, n_R4015, PHI1);

	sdffe mode (.d(DB[7]), .en(W4017), .phi_keep(n_ACLK), .nq(n_mdout) );
	sdffe mask (.d(DB[6]), .en(W4017), .phi_keep(n_ACLK), .q(mask_clear) );
	rsff_2_4 int_ff (.res1(RES), .res2(R4015_clear), .res3(mask_clear), .s(n_mdout & PLA_in[3]), .q(intff_out), .nq(n_intff_out) );
	dlatch md_latch (.d(n_mdout), .en(n_ACLK), .nq(mdout) );
	dlatch int_latch (.d(n_intff_out), .en(n_ACLK), .q(int_latch_out) );
	bustris int_status (.a(int_latch_out), .n_x(DB[6]), .n_en(n_R4015) );

	nor (int_sum, intff_out, DMCINT);
	assign Timer_Int = ~int_sum;

endmodule // FrameCnt_Control

module FrameCnt_LFSR_Control(
	n_ACLK, ACLK,
	RES, W4017, n_mode, mode, PLA_in, C13, C14,
	Z2, F1, F2, sin_toLFSR);

	input n_ACLK;
	input ACLK;

	input RES;
	input W4017;
	input n_mode;
	input mode;
	input [5:0] PLA_in;
	input C13;
	input C14;

	output Z2;
	output F1;
	output F2;
	output sin_toLFSR;

	wire Z1;

	// LFSR control

	wire t1;
	nor (t1, PLA_in[3], PLA_in[4], Z1);
	nor (F1, t1, ACLK);
	nor (F2, ~t1, ACLK);

	// LFO control

	wire z1_out;
	wire z2_out;
	wire zff_out;
	wire zff_set;
	nor (zff_set, z1_out, ACLK);
	dlatch z1 (.d(zff_out), .en(n_ACLK), .q(z1_out), .nq(Z1) );
	dlatch z2 (.d(n_mode), .en(n_ACLK), .q(z2_out) );
	rsff_2_3 z_ff (.res1(RES), .res2(W4017), .s(zff_set), .q(zff_out) );
	nor (Z2, z1_out, z2_out);

	// LFSR shift in

	wire tmp1;
	nor (tmp1, C13, C14, PLA_in[5]);
	nor (sin_toLFSR, C13 & C14, tmp1);

endmodule // FrameCnt_LFSR_Control

module FrameCnt_LFSR_Bit(
	n_ACLK,
	sin, F1, F2,
	sout, n_sout);

	input n_ACLK;

	input sin;
	input F1;
	input F2;

	output sout;
	output n_sout;

	wire inlatch_out;
	dlatch in_latch (
		.d(F2 ? sin : (F1 ? 1'b1 : 1'bz)),
		.en(1'b1), .nq(inlatch_out));
	dlatch out_latch (.d(inlatch_out), .en(n_ACLK), .q(n_sout), .nq(sout));

endmodule // FrameCnt_LFSR_Bit

module FrameCnt_LFSR(
	n_ACLK, F1, F2, sin,
	sout, n_sout);

	input n_ACLK;
	input F1;
	input F2;
	input sin;

	output [14:0] sout;
	output [14:0] n_sout;

	FrameCnt_LFSR_Bit bits [14:0] (
		.n_ACLK(n_ACLK),
		.sin(sin),
		.F1(F1),
		.F2(F2),
		.sout(sout),
		.n_sout(n_sout) );

endmodule // FrameCnt_LFSR

module FrameCnt_PLA(s, ns, md, PLA_out);

	input [14:0] s;
	input [14:0] ns;
	input md; 			// For PLA[3]
	output [5:0] PLA_out;

	nor (PLA_out[0], ns[0], s[1], s[2], s[3], s[4], ns[5], ns[6], s[7], s[8], s[9], s[10], s[11], ns[12], s[13], s[14]);
	nor (PLA_out[1], ns[0], ns[1], s[2], s[3], s[4], s[5], s[6], s[7], s[8], ns[9], ns[10], s[11], ns[12], ns[13], s[14]);
	nor (PLA_out[2], ns[0], ns[1], s[2], s[3], ns[4], s[5], ns[6], ns[7], s[8], s[9], ns[10], ns[11], s[12], ns[13], s[14]);
	nor (PLA_out[3], ns[0], ns[1], ns[2], ns[3], ns[4], s[5], s[6], s[7], s[8], ns[9], s[10], ns[11], s[12], s[13], s[14], md);	// ⚠️
	nor (PLA_out[4], ns[0], s[1], ns[2], s[3], s[4], s[5], s[6], ns[7], ns[8], s[9], s[10], s[11], ns[12], ns[13], ns[14]);
	nor (PLA_out[5], s[0], s[1], s[2], s[3], s[4], s[5], s[6], s[7], s[8], s[9], s[10], s[11], s[12], s[13], s[14]);

endmodule // FrameCnt_PLA
