
module PPU_FSM(
	n_PCLK, PCLK,
	H_in, V_in, HPLA_in, VPLA_in, RES, VBL_EN, n_R2, n_DBE, n_OBCLIP, n_BGCLIP, BLACK,
	H0_DD, H0_D, H1_DD, nH1_D, H2_DD, nH2_D, H3_DD, H4_DD, H5_DD,
	S_EV, CLIP_O, CLIP_B, Z_HPOS, n_EVAL, E_EV, I_OAM2, PAR_O, n_VIS, n_FNT, F_TB, F_TA, n_FO, F_AT, SC_CNT, BURST, SYNC,
	n_PICTURE, RESCL, VB, BLNK,
	Int, DB7, V_IN, HC, VC);

	input n_PCLK;
	input PCLK;

	input [8:0] H_in;
	input [8:0] V_in;
	input [23:0] HPLA_in;
	input [8:0] VPLA_in;
	input RES;
	input VBL_EN;
	input n_R2;
	input n_DBE;
	input n_OBCLIP;
	input n_BGCLIP;
	input BLACK;

	output H0_DD;
	output H0_D;
	output H1_DD;
	output nH1_D;
	output H2_DD;
	output nH2_D;
	output H3_DD;
	output H4_DD;
	output H5_DD;

	output S_EV;
	output CLIP_O;
	output CLIP_B;
	output Z_HPOS;
	output n_EVAL;
	output E_EV;
	output I_OAM2;
	output PAR_O;
	output n_VIS;
	output n_FNT;
	output F_TB;
	output F_TA;
	output n_FO;
	output F_AT;
	output SC_CNT;
	output BURST;
	output SYNC;

	output n_PICTURE;
	output RESCL;
	output VB;
	output BLNK;

	output Int;
	inout DB7;
	output V_IN;
	output HC;
	output VC;

endmodule // PPU_FSM
