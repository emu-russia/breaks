// Inverting tristate with inverting permission.

module bustris(a, x, n_en);

	input a;
	output x;
	input n_en;

	notif0 (x, a, n_en);

endmodule // bustris
