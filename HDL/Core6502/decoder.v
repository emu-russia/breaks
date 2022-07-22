
module Decoder(
	n_T0, n_T1X,
	n_T2, n_T3, n_T4, n_T5, 
	IR01,
	IR, n_IR,
	X);

	input n_T0;
	input n_T1X;
	input n_T2;
	input n_T3;
	input n_T4;
	input n_T5; 
	input IR01;
	input [7:0] IR;
	input [7:0] n_IR;

	output [129:0] X;

endmodule // Decoder
