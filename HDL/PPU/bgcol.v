
module BGCol(
	n_PCLK, PCLK,
	H0_DD, F_TA, F_TB, n_FO, F_AT, THO, TVO, FH, PD, n_CLPB,
	BGC);

	input n_PCLK;
	input PCLK;

	input H0_DD;
	input F_TA;
	input F_TB;
	input n_FO;
	input F_AT;
	input [4:0] THO;
	input [4:0] TVO;
	input [2:0] FH;
	input [7:0] PD;
	input n_CLPB;

	output [3:0] BGC;

endmodule // BGCol
