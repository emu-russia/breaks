
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

	XYRegBit yreg[7:0] (.PHI2(PHI2), .Reg_SB(Y_SB), .SB_Reg(SB_Y), .SB_bit(SB));
	XYRegBit xreg[7:0] (.PHI2(PHI2), .Reg_SB(X_SB), .SB_Reg(SB_X), .SB_bit(SB));
	SRegBit sreg[7:0] (.PHI2(PHI2), .S_SB(S_SB), .S_ADL(S_ADL), .SB_S(SB_S), .S_S(S_S), .SB_bit(SB), .ADL_bit(ADL));

endmodule // Regs

module XYRegBit (PHI2, Reg_SB, SB_Reg, SB_bit);

	input PHI2;
	input Reg_SB;
	input SB_Reg;
	inout SB_bit;

	wire d;
	assign d = SB_Reg ? SB_bit : (PHI2 ? not_nq : 1'bz);

	wire hold_latch_nq;
	wire not_nq;
	dlatch hold_latch (.d(d), .en(1'b1), .nq(hold_latch_nq));
	not (not_nq, hold_latch_nq);

	assign SB_bit = Reg_SB ? not_nq : 1'bz;

endmodule // XYRegBit

module SRegBit (PHI2, S_SB, S_ADL, SB_S, S_S, SB_bit, ADL_bit);

	input PHI2;
	input S_SB;
	input S_ADL;
	input SB_S;
	input S_S;
	inout SB_bit;
	inout ADL_bit;

	wire d;
	assign d = SB_S ? SB_bit : (S_S ? out_latch_nq : 1'bz);

	wire in_latch_nq;
	wire out_latch_nq;
	dlatch in_latch (.d(d), .en(1'b1), .nq(in_latch_nq));
	dlatch out_latch (.d(in_latch_nq), .en(PHI2), .nq(out_latch_nq));

	assign SB_bit = S_SB ? out_latch_nq : 1'bz;
	assign ADL_bit = S_ADL ? out_latch_nq : 1'bz;

endmodule // SRegBit
