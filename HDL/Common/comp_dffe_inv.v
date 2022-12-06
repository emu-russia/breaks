// Complementary FF with additional Enable input and inverted IO. Uses both half clocks (PHI1/PHI2).

module comp_dffe_inv (phi_load, phi_keep, en, val, q, nq);

	input phi_load;		// PHI phase during which the FF value can be modified
	input phi_keep;		// PHI phase during which the current value is "holding".
	input en;			// 1: Writing a value is enabled
	input val;			// New value
	output q;			// Current value
	output nq;			// Current value (complement)

	(* keep = "true" *) wire inp;
	not (inp, val);

	(* keep = "true" *) wire not1out;
	not(not1out, floater);

	(* keep = "true" *) wire not2out;
	not(not2out, not1out);

	(* keep = "true" *) wire floater;
	bufif1(floater, not2out, phi_keep);
	(* keep = "true" *) wire mid;
	bufif1(mid, inp, phi_load);
	bufif1(floater, mid, en);

	assign q = ~not2out;
	assign nq = not2out;

endmodule // comp_dffe_inv
