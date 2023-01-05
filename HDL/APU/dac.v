
// This module simply outputs the digital values of the corresponding channels. You have to decide what to do with them next.

module DAC_Square(SQA, SQB, AUX_A);

	input [3:0] SQA;
	input [3:0] SQB;
	output [7:0] AUX_A;

	assign AUX_A = {SQB,SQA};

endmodule // DAC_Square

module DAC_Others(TRI, RND, DMC, AUX_B);

	input [3:0] TRI;
	input [3:0] RND;
	input [6:0] DMC;
	output [14:0] AUX_B;

	assign AUX_B = {DMC,RND,TRI};

endmodule // DAC_Others
