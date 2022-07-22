
module Regs_Control(
	PHI1, PHI2, 
	STOR, n_ready, 
	X,
	STXY, SBXY, STKOP, 
	Y_SB, X_SB, S_SB, SB_X, SB_Y, SB_S, S_S, S_ADL);

	input PHI1;
	input PHI2;

	input STOR;
	input n_ready;

	input [129:0] X;

	output STXY;
	output SBXY;
	output STKOP;

	output Y_SB;
	output X_SB;
	output S_SB;
	output SB_X;
	output SB_Y;
	output SB_S;
	output S_S;
	output S_ADL;

endmodule  // Regs_Control
