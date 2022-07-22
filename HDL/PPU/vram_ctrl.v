
module VRAM_Control(
	n_PCLK, PCLK, 
	n_R7, n_W7, n_DBE, H0_D, BLNK, nPA,
	DB_PAR, TSTEP, WR, RD, n_ALE, PD_RB, XRB, TH_MUX);

	input n_PCLK;
	input PCLK;

	input n_R7;
	input n_W7;
	input n_DBE;
	input H0_D;
	input BLNK;
	input [13:0] nPA;

	output DB_PAR;
	output TSTEP;
	output WR;
	output RD;
	output n_ALE;
	output PD_RB;
	output XRB;
	output TH_MUX;

endmodule // VRAM_Control

module ReadBuffer(XRB, RC, PD_RB, PD_in, CPU_DB);

	input XRB;
	input RC;
	input PD_RB;
	input [7:0] PD_in;
	inout [7:0] CPU_DB;

endmodule // ReadBuffer
