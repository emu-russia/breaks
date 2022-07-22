
module PAR(
	n_PCLK, PCLK,
	BLNK, DB_PAR, F_AT, SC_CNT, RESCL, E_EV, TSTEP, F_TB, H0_DD, n_H2_D, I_1_32, W6_2_Ena, 
	PAD_in, CPU_DB, TH, TV, NTH, NTV, FV, 
	n_FVO, THO, TVO, n_PA );

	input n_PCLK;
	input PCLK;

	input BLNK;
	input DB_PAR;
	input F_AT;
	input SC_CNT;
	input RESCL;
	input E_EV;
	input TSTEP;
	input F_TB;
	input H0_DD;
	input n_H2_D;
	input I_1_32;
	input W6_2_Ena;

	input [13:0] PAD_in;
	inout [7:0] CPU_DB;
	input [4:0] TH;
	input [4:0] TV;
	input NTH;
	input NTV;
	input [2:0] FV;

	output [2:0] n_FVO;
	output [4:0] THO;
	output [4:0] TVO;
	output [13:0] n_PA;

endmodule // PAR
