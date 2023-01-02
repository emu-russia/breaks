// Parallel nor.

module pnor (a0, a1, x);
	input a0;
	input a1;
	output x;

	nor (x, a0, a1);
endmodule // pnor
