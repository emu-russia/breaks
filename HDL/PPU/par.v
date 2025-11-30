module PAR(
	n_PCLK,
	H0_DD, n_FNT, BGSEL, OBSEL, O8_16, OBJ_READ, n_OBJ_RD_ATTR, n_H1D, OB, PD, OV, n_FVO,
	PAddr_out);

	input n_PCLK;

	input H0_DD;
	input n_FNT;
	input BGSEL;
	input OBSEL;
	input O8_16;
	input OBJ_READ;
	input n_OBJ_RD_ATTR;
	input n_H1D;
	input [7:0] OB;
	input [7:0] PD;
	input [3:0] OV;
	input [2:0] n_FVO;

	output [13:0] PAddr_out;

endmodule // PAR