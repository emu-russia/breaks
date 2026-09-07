`timescale 1ns/1ns

module Bus_Control (
	PHI1, PHI2,
	n_SBXY, AND, STOR, Z_ADL0, ACRL2, DL_PCH, n_ready, INC_SB, BRK6E, STXY, n_PCH_PCH,
	T0, T1, T2, T6, T7, BR0, BR2, BR3,
	X,
	ZTST, PGX,
	Z_ADH0, Z_ADH17, SB_AC, ADL_ABL, AC_SB, SB_DB, AC_DB, SB_ADH, DL_ADH, DL_ADL, ADH_ABH, DL_DB);

	input PHI1;
	input PHI2;

	input n_SBXY;
	input AND;
	input STOR;
	input Z_ADL0;
	input ACRL2;
	input DL_PCH;
	input n_ready;
	input INC_SB;
	input BRK6E;
	input STXY;
	input n_PCH_PCH;

	input T0;
	input T1;
	input T2;			// 2nd cycle (derived from the extra counter, T2 = ~n_T2)
	input T6;
	input T7;
	input BR0;
	input BR2;			// Decoder_out[80]
	input BR3;			// Decoder_out[93]

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

	// ---- internal wires ----

	wire nready_latch_nq;
	wire sb_ac_latch_q;
	wire ac_sb_latch_q;
	wire ac_db_latch_q;

	wire nDLADL;		// ~(DL/ADL) term
	wire nSBAC;			// ~(SB/AC) term
	wire nSBDB;			// ~(SB/DB) term
	wire nZADH17;		// ~(Z/ADH17) term
	wire nABS2_T0;		// ABS & ~T0
	wire temp11;		// ~(ABS/T0 | IMPLIED)
	wire nDLDB;			// ~(DL/DB) term
	wire temp5;			// ~(INC/SB...) term
	wire nSBADH;		// ~(SB/ADH) term
	wire nADHABH;		// ~(ADH/ABH) term
	wire nDLADH;		// ~(DL/ADH) term
	wire nACDB;			// ~(AC/DB) term
	wire nACSB;			// ~(AC/SB) term
	wire nADLABL;		// ~(ADL/ABL) term
	wire nRMW;			// ~(RMW cycles)
	wire temp1, temp2, temp3, temp4, temp6, temp7, temp8, temp9;
	wire nZTST;
	wire nr;			// /ready & ACRL2
	wire SBA;			// SB/ADH term

	wire JSXY;
	wire JSR2;			// X[48]
	wire JMP4;			// X[101]
	wire JSR5;			// X[56]
	wire IND;			// X[89]..X[91], RTS5 (indirect)
	wire RTS5;			// X[84]
	wire pp;			// X[129]
	wire ABS2;			// X[83] & ~pp
	wire IMPLIED;		// X[128] & ~pp
	wire STA;			// X[79]

	// ---- combinational logic ----

	nor (nDLADL, X[81], X[82]);
	nor (nSBAC, X[58], X[59], X[60], X[61], X[62], X[63], X[64]);
	nand (temp1, T6, X[55]);
	nor (temp2, nZTST, AND);

	assign JSR2 = X[48];
	nand (JSXY, ~JSR2, STXY);
	assign JMP4 = X[101];
	assign JSR5 = X[56];

	nor (nZADH17, X[57], ~nDLADL);

	assign RTS5 = X[84];
	assign pp = X[129];
	// IND: indirect (JMP (abs), (d,X), (d),Y etc.) memory-cycle term.
	// On the schematic the net IND is the inverted output of a 4-input NOR,
	// i.e. IND = X89 | (X90 & ~pp) | X91 | RTS5
	assign IND = X[89] | (X[90] & ~pp) | X[91] | RTS5;
	assign ABS2 = X[83] & ~pp;
	nor (nABS2_T0, ABS2, T0);
	assign IMPLIED = X[128] & ~pp;
	nor (temp11, nABS2_T0, IMPLIED);
	nor (temp5, INC_SB, X[45], BRK6E, X[46], X[47], JSR2);
	nor (nDLDB, BR2, temp11, ~temp5, JMP4, T6);

	nor (nSBADH, PGX, BR3);
	nand (nr, ACRL2, nready_latch_nq);
	nor (SBA, nSBADH, nr);
	nor (temp3, IND, T2, n_PCH_PCH, JSR5);
	nor (temp4, n_ready, temp3);
	or (temp6, SBA, temp5);
	assign temp7 = temp6 & ~BR3;
	nor (nADHABH, Z_ADL0, temp7);
	nor (nDLADH, DL_PCH, IND);

	assign STA = X[79];
	nor (nACDB, X[74], STA & STOR);
	nor (nACSB, X[65] & ~X[64], X[66], X[67], X[68], AND);
	nor (temp8, X[71], X[72]);
	nand (PGX, temp8, ~BR0);
	nor (temp9, ~temp8, n_ready);
	nor (nRMW, T6, T7);
	nand (nADLABL, nRMW, temp9);
	nor (nZTST, n_SBXY, ~nSBAC, T7, AND);

	// nSBDB uses BR2 and JSXY
	nor (nSBDB, ~temp1, temp2, X[67], T1, BR2, JSXY);

	// ---- latches ----

	dlatch nready_latch (.d(n_ready), .en(PHI1), .nq(nready_latch_nq) );

	dlatch z_adh0_latch (.d(nDLADL), .en(PHI2), .nq(Z_ADH0) );
	dlatch z_adh17_latch (.d(nZADH17), .en(PHI2), .nq(Z_ADH17) );
	dlatch sb_ac_latch (.d(nSBAC), .en(PHI2), .q(sb_ac_latch_q) );
	dlatch adl_abl_latch (.d(nADLABL), .en(PHI2), .nq(ADL_ABL) );
	dlatch ac_sb_latch (.d(nACSB), .en(PHI2), .q(ac_sb_latch_q) );
	dlatch sb_db_latch (.d(nSBDB), .en(PHI2), .nq(SB_DB) );
	dlatch ac_db_latch (.d(nACDB), .en(PHI2), .q(ac_db_latch_q) );
	dlatch sb_adh_latch (.d(nSBADH), .en(PHI2), .nq(SB_ADH) );
	dlatch dl_adh_latch (.d(nDLADH), .en(PHI2), .nq(DL_ADH) );
	dlatch dl_adl_latch (.d(nDLADL), .en(PHI2), .nq(DL_ADL) );
	dlatch adh_abh_latch (.d(nADHABH), .en(PHI2), .nq(ADH_ABH) );
	dlatch dl_db_latch (.d(nDLDB), .en(PHI2), .nq(DL_DB) );

	nor (SB_AC, sb_ac_latch_q, PHI2);
	nor (AC_SB, ac_sb_latch_q, PHI2);
	nor (AC_DB, ac_db_latch_q, PHI2);
	assign ZTST = ~nZTST;

endmodule // Bus_Control
