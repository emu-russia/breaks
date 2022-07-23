// Flop with a single CLK phase used to keep and load at the same time.

module sdffe(d, en, phi_keep, q, nq);

	input d;				// Input value for write
	input en;				// 1: Enables Write
	input phi_keep; 		// 1: Keep the current value, 0: You can write, the old value is "cut off"
	output q;				// Current value
	output nq;				// Current value (inverse logic)

	(* keep = "true" *) wire dval;
	bufif1 (dval, d, en);

	(* keep = "true" *) wire muxout;
	assign muxout = phi_keep ? oldval : dval;

	(* keep = "true" *) wire n_oldval;
	assign n_oldval = ~muxout;

	(* keep = "true" *) wire oldval;
	assign oldval = ~n_oldval;

	assign q = oldval;
	assign nq = n_oldval;

endmodule // sdffe
