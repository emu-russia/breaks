`timescale 1ns/1ns

// Contains the implementation of the address bus output terminals and the ABH/ABL registers where the actual address value is stored.
// Memo: The 6502 processor sets the address for the next operation during the PHI1 phase (together with R/W mode).

module AddrBusBit (
	PHI1, PHI2,
	ADX, ADX_ABX,
	ABus_out);

	input PHI1;
	input PHI2;
	input ADX;
	input ADX_ABX;
	output ABus_out;

	wire n_adx = ~(ADX);
	wire abff_out;

	AddrBusFF abff (
		.phi_load(PHI1),
		.phi_keep(PHI2),
		.en(ADX_ABX),
		.val(n_adx),
		.q(abff_out));

	assign ABus_out = ~abff_out;

endmodule // AddrBusBit

// Complementary FF with additional Enable input and inverted IO. Uses both half clocks (PHI1/PHI2).
// TODO: Remake it into a simpler version, without the explicit tristates
module AddrBusFF (phi_load, phi_keep, en, val, q, nq);

	input phi_load;		// PHI phase during which the FF value can be modified
	input phi_keep;		// PHI phase during which the current value is "holding".
	input en;			// 1: Writing a value is enabled
	input val;			// New value
	output q;			// Current value
	output nq;			// Current value (complement)

`ifdef ICARUS
	// Behavioral equivalent of the dynamic NMOS FF: while (en & phi_load)
	// the FF is transparent (q follows ~val), otherwise it holds its value
	// (the phi_keep feedback refresh of the real chip is implied by the
	// reg holding its value). Icarus cannot simulate the bufif1 feedback
	// loop below: an enabled bufif1 whose data input is z resolves to x,
	// which poisons the feedback node and wipes the stored bit in PHI2.
	reg state;
	always @(en or phi_load or val)
		if (en == 1'b1 && phi_load == 1'b1)
			state <= val;		// q follows val while transparent

	initial state <= 1'b0;
	assign q = state;
	assign nq = ~state;

`else

	(* keep = "true" *) wire inp;
	(* keep = "true" *) wire floater;
	(* keep = "true" *) wire mid;
	(* keep = "true" *) wire not1out;
	(* keep = "true" *) wire not2out;

	not (inp, val);

	not(not1out, floater);

	not(not2out, not1out);

	bufif1(floater, not2out, phi_keep);
	bufif1(mid, inp, phi_load);
	bufif1(floater, mid, en);

	assign q = ~not2out;
	assign nq = not2out;

`endif

endmodule // AddrBusFF
