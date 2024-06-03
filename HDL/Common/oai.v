// Ordinary 2-or to and inverted (OAI-21)

module oai (a0, a1, b, x);

	input a0;
	input a1;
	input b;
	output x;

	nand (x, a0 | a1, b);

endmodule // oai
