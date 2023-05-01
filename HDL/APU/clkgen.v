
module ACLKGen(PHI1, PHI2, ACLK1, nACLK2, RES);

	input PHI1;
	input PHI2;
	output ACLK1;
	output nACLK2;
	input RES;

	wire n_latch1_out;
	wire n_latch2_out;
	wire latch1_in;

	dlatch phi1_latch (
		.d(latch1_in),
		.en(PHI1),
		.nq(n_latch1_out) );

	dlatch phi2_latch (
		.d(n_latch1_out),
		.en(PHI2),
		.nq(n_latch2_out) );

	nor (latch1_in, RES, n_latch2_out);

	wire n1;
	nor (n1, ~PHI1, latch1_in);
	nor (ACLK1, ~PHI1, n_latch2_out);
	not (nACLK2, n1);

endmodule // ACLKGen

module SoftTimer(
	PHI1, ACLK1, nACLK2,
	RES, n_R4015, W4017, DB, DMCINT, INT_out, nLFO1, nLFO2);

	input PHI1;
	input ACLK1;
	input nACLK2;

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
	wire F1;				// 1: Reset LFSR
	wire F2;				// 1: Perform the LFSR step
	wire sin;
	wire [14:0] sout;
	wire [14:0] n_sout;

	// SoftCLK control circuits have a very conventional division, because they are "scattered" in an even layer on the chip and it is difficult to determine their boundaries

	SoftCLK_Control ctrl (
		.PHI1(PHI1),
		.ACLK1(ACLK1),
		.RES(RES),
		.DB(DB),
		.DMCINT(DMCINT),
		.n_R4015(n_R4015),
		.W4017(W4017),
		.PLA_in(PLA_out),
		.n_mdout(n_mode),
		.mdout(mode),
		.Timer_Int(INT_out) );

	SoftCLK_LFSR_Control lfsr_ctrl (
		.ACLK1(ACLK1),
		.nACLK2(nACLK2),
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

	SoftCLK_LFSR lfsr (
		.ACLK1(ACLK1),
		.F1_Reset(F1),
		.F2_Step(F2),
		.sin(sin),
		.sout(sout),
		.n_sout(n_sout) );

	SoftCLK_PLA pla (
		.s(sout),
		.ns(n_sout),
		.md(mode),
		.PLA_out(PLA_out) );

	// LFO Output

	wire tmp1;
	nor (tmp1, PLA_out[0], PLA_out[1], PLA_out[2], PLA_out[3], PLA_out[4], Z2);
	wire tmp2;
	nor (tmp2, tmp1, nACLK2);
	assign nLFO1 = ~tmp2;

	wire tmp3;
	nor (tmp3, PLA_out[1], PLA_out[3], PLA_out[4], Z2);
	wire tmp4;
	nor (tmp4, tmp3, nACLK2);
	assign nLFO2 = ~tmp4;

endmodule // SoftTimer

module SoftCLK_Control(
	PHI1, ACLK1,
	RES, DB, DMCINT, n_R4015, W4017, PLA_in,
	n_mdout, mdout, Timer_Int);

	input PHI1;
	input ACLK1;

	input RES;
	inout [7:0] DB;
	input DMCINT;
	input n_R4015;
	input W4017;
	input [5:0] PLA_in;

	inout n_mdout;
	output mdout;
	output Timer_Int;

	wire R4015_clear;
	wire mask_clear;
	wire intff_out;
	wire n_intff_out;
	wire int_sum;
	wire int_latch_out;

	nor (R4015_clear, n_R4015, PHI1);

	RegisterBit mode (.d(DB[7]), .ena(W4017), .ACLK1(ACLK1), .nq(n_mdout) );
	RegisterBit mask (.d(DB[6]), .ena(W4017), .ACLK1(ACLK1), .q(mask_clear) );
	rsff_2_4 int_ff (.res1(RES), .res2(R4015_clear), .res3(mask_clear), .s(n_mdout & PLA_in[3]), .q(intff_out), .nq(n_intff_out) );
	dlatch md_latch (.d(n_mdout), .en(ACLK1), .nq(mdout) );
	dlatch int_latch (.d(n_intff_out), .en(ACLK1), .q(int_latch_out) );
	bustris int_status (.a(int_latch_out), .n_x(DB[6]), .n_en(n_R4015) );

	nor (int_sum, intff_out, DMCINT);
	assign Timer_Int = ~int_sum;

endmodule // SoftCLK_Control

module SoftCLK_LFSR_Control(
	ACLK1, nACLK2,
	RES, W4017, n_mode, mode, PLA_in, C13, C14,
	Z2, F1, F2, sin_toLFSR);

	input ACLK1;
	input nACLK2;

	input RES;
	input W4017;
	inout n_mode;
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
	nor (F1, t1, nACLK2);
	nor (F2, ~t1, nACLK2);

	// LFO control

	wire z1_out;
	wire z2_out;
	wire zff_out;
	wire zff_set;
	nor (zff_set, z1_out, nACLK2);
	dlatch z1 (.d(zff_out), .en(ACLK1), .q(z1_out), .nq(Z1) );
	dlatch z2 (.d(n_mode), .en(ACLK1), .q(z2_out) );
	rsff_2_3 z_ff (.res1(RES), .res2(W4017), .s(zff_set), .q(zff_out) );
	nor (Z2, z1_out, z2_out);

	// LFSR shift in

	wire tmp1;
	nor (tmp1, C13, C14, PLA_in[5]);
	nor (sin_toLFSR, C13 & C14, tmp1);

endmodule // SoftCLK_LFSR_Control

module SoftCLK_LFSR_Bit(
	ACLK1,
	sin, F1, F2,
	sout, n_sout);

	input ACLK1;

	input sin;
	input F1;
	input F2;

	output sout;
	output n_sout;

	wire inlatch_out;
	dlatch in_latch (
		.d(F2 ? sin : (F1 ? 1'b1 : 1'bz)),
		.en(1'b1), .nq(inlatch_out));
	dlatch out_latch (.d(inlatch_out), .en(ACLK1), .q(n_sout), .nq(sout));

endmodule // SoftCLK_LFSR_Bit

module SoftCLK_LFSR(
	ACLK1, F1_Reset, F2_Step, sin,
	sout, n_sout);

	input ACLK1;
	input F1_Reset;
	input F2_Step;
	input sin;

	output [14:0] sout;
	output [14:0] n_sout;

	SoftCLK_LFSR_Bit bits [14:0] (
		.ACLK1(ACLK1),
		.sin({sout[13:0],sin}),
		.F1(F1_Reset),
		.F2(F2_Step),
		.sout(sout),
		.n_sout(n_sout) );

endmodule // SoftCLK_LFSR

module SoftCLK_PLA(s, ns, md, PLA_out);

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

endmodule // SoftCLK_PLA
