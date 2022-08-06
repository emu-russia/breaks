
module PpuPadsLogic(
	n_PCLK,
	n_CpuRD, n_CpuWR, CPU_DB, DPads,
	n_ALE_topad, ALE, 	
	PD_out, n_PA, PAPads, ADPads, RD_topad, WR_topad, n_RDPad, n_WRPad, 
	EXTPads, n_SLAVE, EXT_in, n_EXT_out, 
	CLKPad, n_CLK_frompad, CLK_frompad,
	n_RESPad, RES, RESCL, RC,
	Int_topad, n_INTPad);

	input n_PCLK;

	input n_CpuRD;
	input n_CpuWR;
	inout [7:0] CPU_DB;
	inout [7:0] DPads;

	input n_ALE_topad;
	output ALE;

	output [7:0] PD_out;
	input [13:0] n_PA;
	output [5:0] PAPads;
	inout [7:0] ADPads;
	input RD_topad;
	input WR_topad;
	output n_RDPad;
	output n_WRPad; 

	inout [3:0] EXTPads;
	input n_SLAVE;
	output [3:0] EXT_in;
	input [3:0] n_EXT_out;

	input CLKPad;
	output n_CLK_frompad;
	output CLK_frompad;

	input n_RESPad;
	output RES;
	input RESCL;
	output RC;

	input Int_topad;
	output n_INTPad;

endmodule // PadsLogic
