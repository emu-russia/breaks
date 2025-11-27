module TileCnt (
	n_PCLK, PCLK,
	W6_2_Ena, SC_CNT, RESCL, E_EV, TSTEP, F_TB, H0_DD, BLNK, I_1_32, 
	TH, TV, NTH, NTV, FV, 
	n_FVO, THO, TVO, FAT, PAR );

	input n_PCLK;
	input PCLK;

	input W6_2_Ena;
	input SC_CNT;
	input RESCL;
	input E_EV;
	input TSTEP;
	input F_TB;
	input H0_DD;
	input BLNK;
	input I_1_32;

	input [4:0] TH;
	input [4:0] TV;
	input NTH;
	input NTV;
	input [2:0] FV;

	output [2:0] n_FVO;
	output [4:0] THO;
	output [4:0] TVO;

	output [13:0] FAT;
	output [13:0] PAR;

endmodule // TileCnt