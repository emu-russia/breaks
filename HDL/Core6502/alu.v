
module ALU(
	PHI2,
	NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD, ADD_SB06, ADD_SB7, ADD_ADL,
	ANDS, EORS, ORS, SRS, SUMS, 
	SB_AC, AC_SB, AC_DB, SB_DB, SB_ADH, Z_ADH0, Z_ADH17,
	n_ACIN, n_DAA, n_DSA,
	SB, DB, ADL, ADH,
	ACR, AVR);

	input PHI2;
	
	input NDB_ADD;
	input DB_ADD;
	input Z_ADD;
	input SB_ADD;
	input ADL_ADD;
	input ADD_SB06;
	input ADD_SB7;
	input ADD_ADL;

	input ANDS;
	input EORS;
	input ORS;
	input SRS;
	input SUMS;

	input SB_AC;
	input AC_SB;
	input AC_DB;
	input SB_DB;
	input SB_ADH;
	input Z_ADH0;
	input Z_ADH17;

	input n_ACIN;
	input n_DAA;
	input n_DSA;

	inout [7:0] SB;
	inout [7:0] DB;
	inout [7:0] ADL;
	inout [7:0] ADH;

	output ACR;
	output AVR;

endmodule // ALU
