
module IR(
	PHI1, PHI2,
	n_PD, FETCH,
	IR01, IR_out, n_IR_out);

	input PHI1;
	input PHI2;

	input [7:0] n_PD;
	input FETCH;

	output IR01;
	output [7:0] IR_out;
	output [7:0] n_IR_out;

endmodule // IR
