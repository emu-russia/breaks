// Complementary FF with additional Enable input. Uses both half clocks (PHI1/PHI2).

module dffe (phi_load, phi_keep, en, val, q, nq);

	input phi_load;		// PHI phase during which the FF value can be modified
	input phi_keep;		// PHI phase during which the current value is "holding".
	input en;			// 1: Writing a value is enabled
	input val;			// New value
	output q;			// Current value
	output nq;			// Current value (inverted)

	reg ff_val;

	always @(phi_keep)
		begin
			ff_val <= ff_val;
		end

	always @(phi_load)
		if (en)
		begin
			ff_val <= val;
		end

	assign q = ff_val;
	assign nq = ~ff_val;

endmodule // dffe
