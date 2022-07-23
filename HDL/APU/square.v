
module SquareChan_0(
	n_ACLK, 
	RES, DB, W4000, W4001, W4002, W4003, nLFO1, nLFO2, SQA_LC, NOSQA, LOCK, 
	SQA_Out);

	input n_ACLK;

	input RES;
	inout [7:0] DB;
	input W4000;
	input W4001;
	input W4002;
	input W4003;
	input nLFO1;
	input nLFO2;
	output SQA_LC;
	input NOSQA;
	input LOCK;

	output [3:0] SQA_Out;

endmodule // SquareChan_0

module SquareChan_1(
	n_ACLK, 
	RES, DB, W4004, W4005, W4006, W4007, nLFO1, nLFO2, SQB_LC, NOSQB, LOCK, 
	SQB_Out);

	input n_ACLK;

	input RES;
	inout [7:0] DB;
	input W4004;
	input W4005;
	input W4006;
	input W4007;
	input nLFO1;
	input nLFO2;
	output SQB_LC;
	input NOSQB;
	input LOCK;

	output [3:0] SQB_Out;

endmodule // SquareChan_1
