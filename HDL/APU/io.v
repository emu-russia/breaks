
module IOPorts(
	n_ACLK, W4016, n_R4016, n_R4017, DB,
	OUT0_Pad, OUT1_Pad, OUT2_Pad, nIN0_Pad, nIN1_Pad);

	input n_ACLK;
	input W4016;
	input n_R4016;
	input n_R4017;
	inout [7:0] DB;

	output OUT0_Pad;
	output OUT1_Pad;
	output OUT2_Pad;
	output nIN0_Pad;
	output nIN1_Pad;

endmodule // IOPorts
