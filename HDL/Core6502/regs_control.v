
module Regs_Control(
	PHI1, PHI2, 
	STOR, n_ready, 
	X,
	STXY, n_SBXY, STKOP, 
	Y_SB, X_SB, S_SB, SB_X, SB_Y, SB_S, S_S, S_ADL);

	input PHI1;
	input PHI2;

	input STOR;
	input n_ready;

	input [129:0] X;

	output STXY;
	output n_SBXY;
	output STKOP;

	output Y_SB;
	output X_SB;
	output S_SB;
	output SB_X;
	output SB_Y;
	output SB_S;
	output S_S;
	output S_ADL;

	wire nYSB;
	wire nXSB;
	wire nSBX;
	wire nSBY;
	wire nSBS;
	wire nSADL;
	wire tmp1;

	wire nready_latch_q;
	wire nready_latch_nq;
	wire ysb_latch_q;
	wire xsb_latch_q;
	wire sbx_latch_q;
	wire sby_latch_q;
	wire sbs_latch_q;
	wire ss_latch_q;

	assign nYSB = ~(X[1] | X[2] | X[3] | X[4] | X[5] | (X[6]&X[7]) | (X[0]&STOR));
	assign nXSB = ~(X[8] | X[9] | X[10] | X[11] | X[13] | (X[6]&~X[7]) | (X[12]&STOR));
	assign nSBX = ~(X[14] | X[15] | X[16]);
	assign nSBY = ~(X[18] | X[19] | X[20]);
	assign tmp1 = ~(X[21] | X[22] | X[23] | X[24] | X[25] | X[26]);
	assign nSBS = ~(X[13] | ~(~X[48]|n_ready) | STKOP);
	assign nSADL = ~((X[21]&nready_latch_nq) | X[35]);

	assign STXY = ~((X[0]&STOR) | (X[12]&STOR));
	assign n_SBXY = ~(nSBX & nSBY);
	assign STKOP = ~(tmp1|nready_latch_q);

	dlatch nready_latch (.d(n_ready), .en(PHI1), .q(nready_latch_q), .nq(nready_latch_nq));
	dlatch ysb_latch (.d(nYSB), .en(PHI2), .q(ysb_latch_q));
	dlatch xsb_latch (.d(nXSB), .en(PHI2), .q(xsb_latch_q));
	dlatch ssb_latch (.d(~X[17]), .en(PHI2), .nq(S_SB));
	dlatch sbx_latch (.d(nSBX), .en(PHI2), .q(sbx_latch_q));
	dlatch sby_latch (.d(nSBY), .en(PHI2), .q(sby_latch_q));
	dlatch sbs_latch (.d(nSBS), .en(PHI2), .q(sbs_latch_q));
	dlatch ss_latch (.d(~nSBS), .en(PHI2), .q(ss_latch_q));
	dlatch sadl_latch (.d(nSADL), .en(PHI2), .nq(S_ADL));

	assign Y_SB = ~(ysb_latch_q|PHI2);
	assign X_SB = ~(xsb_latch_q|PHI2);
	assign SB_X = ~(sbx_latch_q|PHI2);
	assign SB_Y = ~(sby_latch_q|PHI2);
	assign SB_S = ~(sbs_latch_q|PHI2);
	assign S_S = ~(ss_latch_q|PHI2);

endmodule  // Regs_Control
