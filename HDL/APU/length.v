
module LengthCounters(
	n_ACLK,
	RES, DB, n_R4015, W4015, nLFO2, 
	W4003, W4007, W400B, W400F,
	SQA_LC, SQB_LC, TRI_LC, RND_LC,
	NOSQA, NOSQB, NOTRI, NORND);

	input n_ACLK;

	input RES;
	inout [7:0] DB;
	input n_R4015;
	input W4015;
	input nLFO2;

	input W4003;
	input W4007;
	input W400B;
	input W400F;

	input SQA_LC;
	input SQB_LC;
	input TRI_LC;
	input RND_LC;

	output NOSQA;
	output NOSQB;
	output NOTRI;
	output NORND;

endmodule // LengthCounters
