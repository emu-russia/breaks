
module DAC_Square(SQA, SQB, AUX_A);

	input [3:0] SQA;
	input [3:0] SQB;
	output AUX_A;

endmodule // DAC_Square

module DAC_Others(RND, TRI, DMC, AUX_B);

	input [3:0] RND;
	input [3:0] TRI;
	input [6:0] DMC;
	output AUX_B;

endmodule // DAC_Others
