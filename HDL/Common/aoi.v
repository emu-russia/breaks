
// Ordinary 2-and to or inverted (AOI-21)
module aoi (a0, a1, b, x);

	input a0;
	input a1;
	input b;
	output x;

	nor (x, a0 & a1, b);

endmodule // aoi

// 2-and to 3-or inverted (AOI-211)
module aoi211 (a0, a1, b, c, x);

	input a0;
	input a1;
	input b;
	input c;
	output x;

	nor (x, a0 & a1, b, c);

endmodule // aoi
