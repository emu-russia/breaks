
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

	// Logic

	wire [7:0] DB_temp;
	pnor DB_out [7:0] (CPU_DB, {8{n_CpuRD}}, DB_temp);
	bustris DB_out_tris [7:0] (.a(DB_temp), .n_x(DPads), .n_en(n_CpuRD) );
	bustris DB_in_tris [7:0] (.a(~DPads), .n_x(CPU_DB), .n_en(n_CpuWR) );

	assign ALE = ~n_ALE_topad;
	assign PD_out = ADPads;
	bustris AD_out_tris [7:0] (.a(n_PA[7:0] | {8{RD_topad}}), .n_x(ADPads), .n_en(RD_topad) );
	assign PAPads = ~n_PA[13:8];
	assign n_RDPad = ~RD_topad;
	assign n_WRPad = ~WR_topad;

	wire [3:0] ext_latch_out;
	pnor EXT_in_nors [3:0] (~EXTPads, {4{n_SLAVE}}, EXT_in);
	dlatch EXT_out_latch [3:0] (.d(n_EXT_out), .en(n_PCLK), .q(ext_latch_out) );
	bustris EXT_out_tris [3:0] (.a(ext_latch_out | {4{~n_SLAVE}}), .n_x(EXTPads), .n_en(~n_SLAVE) );

	assign n_CLK_frompad = ~CLKPad;
	assign CLK_frompad = CLKPad;

	assign RES = ~n_RESPad;
	wire Reset_FF_out;
	rsff Reset_FF (.r(RESCL), .s(RES), .q(Reset_FF_out) );
	assign RC = ~Reset_FF_out;

	notif1 (n_INTPad, Int_topad, Int_topad);

endmodule // PadsLogic
