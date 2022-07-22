
module OAMEval(
	n_PCLK, PCLK,
	BLNK, I_OAM2, n_VIS, PAR_O, n_EVAL, RESCL, H0_DD, H0_D, n_H2_D, OFETCH, n_FNT, S_EV,
	n_W3, n_DBE,
	DB5, 
	n_OAM, OAM8, OAMCTR2, SPR_OV, OV, PD_FIFO, n_SPR0_EV);

	input n_PCLK;
	input PCLK;

	input BLNK;
	input I_OAM2;
	input n_VIS;
	input PAR_O;
	input n_EVAL;
	input RESCL;
	input H0_DD;
	input H0_D;
	input n_H2_D;
	input OFETCH;
	input n_FNT;
	input S_EV;

	input n_W3;
	input n_DBE;
	inout DB5;

	output [7:0] n_OAM;
	output OAM8;
	output OAMCTR2;
	output SPR_OV;
	output [7:0] OV;
	output PD_FIFO;
	output n_SPR0_EV;

endmodule // OAMEval
