
module ExtraCounter (
	PHI1, PHI2, TRES2, n_ready, T1,
	n_T2, n_T3, n_T4, n_T5);

	input PHI1;
	input PHI2;
	input TRES2;
	input n_ready;
	input T1;

	output n_T2;
	output n_T3;
	output n_T4;
	output n_T5;

	wire t1_latch_nq;
	wire [3:0] nq;

	dlatch t1_latch (.d(T1), .en(PHI2), .nq(t1_latch_nq));

	ExtraCounter_SRBit sr [3:0] (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.nd({nq[2:0],t1_latch_nq}),
		.n_EN(n_ready),
		.RES(TRES2),
		.nq(nq),
		.nsout({n_T5,n_T4,n_T3,n_T2}));

endmodule // ExtraCounter

module ExtraCounter_SRBit (PHI1, PHI2, nd, n_EN, RES, nq, nsout);

	input PHI1;
	input PHI2;
	input nd;
	input n_EN;
	input RES;
	output nq;
	output nsout;

	wire latch1_q;
	wire latch2_d;

	nor (latch2_d, latch1_q, RES);
	dlatch latch1 (.d(n_EN ? nq : nd), .en(PHI1), .q(latch1_q));
	dlatch latch2 (.d(latch2_d), .en(PHI2), .nq(nq));
	assign nsout = ~latch2_d;

endmodule // ExtraCounter_SRBit
