
module Bus_Control(
	PHI1, PHI2,
	n_SBXY, AND, STOR, Z_ADL0, BR2, ACRL2, DL_PCH, n_ready, INC_SB, BRK6E, STXY, n_PCH_PCH,
	T0, T1, T6, T7,
	X,
	ZTST, PGX, 
	Z_ADH0, Z_ADH17, SB_AC, ADL_ABL, AC_SB, SB_DB, AC_DB, SB_ADH, DL_ADH, DL_ADL, ADH_ABH, DL_DB);

	input PHI1;
	input PHI2;

	input n_SBXY;
	input AND;
	input STOR;
	input Z_ADL0;
	input BR2;
	input ACRL2;
	input DL_PCH;
	input n_ready;
	input INC_SB;
	input BRK6E;
	input STXY;
	input n_PCH_PCH;

	input T0;
	input T1;
	input T6;
	input T7;

	input [129:0] X;

	output ZTST;
	output PGX;

	output Z_ADH0;
	output Z_ADH17;
	output SB_AC;
	output ADL_ABL;
	output AC_SB;
	output SB_DB;
	output AC_DB;
	output SB_ADH;
	output DL_ADH;
	output DL_ADL;
	output ADH_ABH;
	output DL_DB;

endmodule // Bus_Control
