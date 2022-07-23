
module ApuPadsLogic(
	CLKPad, n_CLK_frompad,
	n_RESPad, RES_frompad,
	n_IRQPad, Timer_Int, n_IRQ_tocore,
	n_M2_topad, M2Pad,
	DBGPad, DBG_frompad,
	RD, WR, DB, DPads,
	RW_topad, RWPad);

	input CLKPad;
	output n_CLK_frompad;
	
	input n_RESPad;
	output RES_frompad;

	input n_IRQPad;
	input Timer_Int;
	output n_IRQ_tocore;

	input n_M2_topad;
	output M2Pad;

	input DBGPad;
	output DBG_frompad;

	input RD;
	input WR;
	inout [7:0] DB;
	inout [7:0] DPads;

	input RW_topad;
	output RWPad;

endmodule // PadsLogic
