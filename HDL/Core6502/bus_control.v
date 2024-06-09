`timescale 1ns/1ns

module Bus_Control (
	PHI1, PHI2,
	n_SBXY, AND, STOR, Z_ADL0, ACRL2, DL_PCH, n_ready, INC_SB, BRK6E, STXY, n_PCH_PCH,
	T0, T1, T6, T7, BR0, 
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
	input T6;
	input T7;
	input BR0;

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

	wire nready_latch_nq;
	wire sb_ac_latch_q;
	wire ac_sb_latch_q;
	wire ac_db_latch_q;

	wire nDLADL;
	nor (nDLADL, X[81], X[82]);
	wire nSBAC;
	nor (nSBAC, X[58], X[59], X[60], X[61], X[62], X[63], X[64]);
	wire temp1;
	nand (temp1, T6, X[55]);
	wire temp2;
	nor (temp2, nZTST, AND);
	wire nSBDB;
	nor (nSBDB, ~temp1, temp2, X[67], T1, BR2, JSXY);
	wire JSXY;
	wire JSR2;
	assign JSR2 = X[48];
	nand (JSXY, ~JSR2, STXY);
	wire JMP4;
	assign JMP4 = X[101];
	wire JSR5;
	assign JSR5 = X[56];
	wire nZADH17;
	nor (nZADH17, X[57], ~nDLADL);
	wire nIND;
	wire RTS5;
	assign RTS5 = X[84];
	wire pp;
	assign pp = X[129];
	nor (nIND, X[89], (X[90] & ~pp), X[91], RTS5);
	wire ABS2;
	assign ABS2 = X[83] & ~pp;
	wire nABS2_T0;
	nor (nABS2_T0, ABS2, T0);
	wire temp11;
	wire IMPLIED;
	assign IMPLIED = X[128] & ~pp;
	nor (temp11, nABS2_T0, IMPLIED);
	wire nDLDB;
	nor (nDLDB, BR2, temp11, ~temp5, JMP4, T6);
	wire temp5;
	nor (temp5, INC_SB, X[45], BRK6E, X[46], X[47], JSR2);
	wire nSBADH;
	nor (nSBADH, PGX, BR3);
	wire nr;
	nand (nr, ACRL2, nready_latch_nq);
	wire SBA;
	nor (SBA, nSBADH, nr);
	wire temp3;
	nor (temp3, IND, T2, n_PCH_PCH, JSR5);
	wire temp4;
	nor (temp4, n_ready, temp3);
	wire temp6;
	or (temp6, SBA, temp5);
	wire temp7;
	assign temp7 = temp6 & ~BR3;
	wire nADHABH;
	nor (nADHABH, Z_ADL0, temp7);
	wire nDLADH;
	nor (nDLADH, DL_PCH, IND);
	wire nACDB;
	wire STA;
	assign STA = X[79];
	nor (nACDB, X[74], STA & STOR);
	wire nACSB;
	nor (nACSB, X[65] & ~X[64], X[66], X[67], X[68], AND);
	wire temp8;
	nor (temp8, X[71], X[72]);
	nand (PGX, temp8, ~BR0);
	wire temp9;
	nor (temp9, ~temp8, n_ready);
	wire nRMW;
	nor (nRMW, T6, T7);
	wire nADLABL;
	nand (nADLABL, nRMW, temp9);
	nor (nZTST, n_SBXY, ~nSBAC, T7, AND);

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
