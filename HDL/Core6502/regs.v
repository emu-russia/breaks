
module Regs(
	PHI2,
	Y_SB, SB_Y, X_SB, SB_X, S_SB, S_ADL, S_S, SB_S, 
	SB, ADL);

	input PHI2;

	input Y_SB;
	input SB_Y;
	input X_SB;
	input SB_X;
	input S_SB;
	input S_ADL;
	input S_S;
	input SB_S;

	inout [7:0] SB;
	inout [7:0] ADL;

endmodule // Regs
