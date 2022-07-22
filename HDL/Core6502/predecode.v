
module PreDecode(
	PHI2,
	Z_IR,
	Data_bus, n_PD,
	n_IMPLIED, n_TWOCYCLE);

	input PHI2;

	input Z_IR;

	inout [7:0] Data_bus;
	output [7:0] n_PD;

	output n_IMPLIED;
	output n_TWOCYCLE;

endmodule // PreDecode
