
module ALU_Control(
	PHI1, PHI2,
	BRFW, n_ready, BRK6E, STKOP, PGX,
	X,
	T0, T1, T5, T6,
	n_DOUT, n_COUT,
	INC_SB, SR, AND,
	NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD, ADD_SB06, ADD_SB7, ADD_ADL, ANDS, EORS, ORS, SRS, SUMS, n_ACIN, n_DAA, n_DSA);

	input PHI1;
	input PHI2;

	input BRFW;
	input n_ready;
	input BRK6E;
	input STKOP;
	input PGX;
	
	input [129:0] X;
	
	input T0;
	input T1;
	input T5;
	input T6;
	
	input n_DOUT;
	input n_COUT;

	output INC_SB;
	output SR;
	output AND;

	output NDB_ADD;
	output DB_ADD;
	output Z_ADD;
	output SB_ADD;
	output ADL_ADD;
	output ADD_SB06;
	output ADD_SB7;
	output ADD_ADL;
	output ANDS;
	output EORS;
	output ORS;
	output SRS;
	output SUMS;
	output n_ACIN;
	output n_DAA;
	output n_DSA;


endmodule // ALU_Control
