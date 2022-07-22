
module HVCounters(
	n_PCLK, PCLK,
	RES, HC, VC, V_IN,
	H_out, V_out);

	input n_PCLK;
	input PCLK;

	input RES;
	input HC;
	input VC;
	input V_IN;

	output [8:0] H_out;
	output [8:0] V_out;

endmodule // HVCounters
