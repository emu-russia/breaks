
module HVDecoder(
	H_in, V_in, VB, BLNK,
	HPLA_out, VPLA_out);

	input [8:0] H_in;
	input [8:0] V_in;
	input VB;
	input BLNK;

	output [23:0] HPLA_out;
	output [8:0] VPLA_out;

endmodule // HVDecoder
