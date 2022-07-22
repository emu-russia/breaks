
module OAMBlock(
	n_PCLK, PCLK,
	n_OAM, OAM8, BLNK, SPR_OV, OAMCTR2, H0_DD, n_VIS, I_OAM2, n_W4, n_R4, n_DBE, 
	CPU_DB,
	OB_Out, OFETCH);

	input n_PCLK;
	input PCLK;

	input [7:0] n_OAM;
	input OAM8;
	input BLNK;
	input SPR_OV;
	input OAMCTR2;
	input H0_DD;
	input n_VIS;
	input I_OAM2;
	input n_W4;
	input n_R4;
	input n_DBE;

	inout [7:0] CPU_DB;

	output [7:0] OB_Out;
	output OFETCH;

endmodule // OAMBlock
