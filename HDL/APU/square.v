
module SquareChan (
	ACLK, n_ACLK, 
	RES, DB, WR0, WR1, WR2, WR3, nLFO1, nLFO2, SQ_LC, NOSQ, LOCK, AdderCarryMode,
	SQ_Out);

	input ACLK;
	input n_ACLK;

	input RES;
	inout [7:0] DB;
	input WR0;
	input WR1;
	input WR2;
	input WR3;
	input nLFO1;
	input nLFO2;
	output SQ_LC;
	input NOSQ;
	input LOCK;
	input AdderCarryMode;			// 0: input carry connected to INC, 1: input carry connected to Vdd

	output [3:0] SQ_Out;

endmodule // SquareChan
