
module ObjectFIFO(
	n_PCLK, PCLK,
	OBJ_READ, H0_DD, H1_DD, H2_DD, H3_DD, H4_DD, H5_DD, Z_HPOS, n_VIS, PD_FIFO, PD, CLPO,
	n_SPR0HIT, n_ZCOL0, n_ZCOL1, ZCOL2, ZCOL3, n_ZPRIO, n_OBJ_RD_ATTR);

	input n_PCLK;
	input PCLK;

	input OBJ_READ;
	input H0_DD;
	input H1_DD;
	input H2_DD;
	input H3_DD;
	input H4_DD;
	input H5_DD;
	input Z_HPOS;
	input n_VIS;
	input PD_FIFO;
	input [7:0] PD;
	input CLPO;

	output n_SPR0HIT;
	output n_ZCOL0;
	output n_ZCOL1;
	output ZCOL2;
	output ZCOL3;
	output n_ZPRIO;
	output n_OBJ_RD_ATTR;



endmodule // ObjectFIFO