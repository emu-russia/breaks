// Contains the implementation of the address bus output terminals and the ABH/ABL registers where the actual address value is stored.
// Memo: The 6502 processor sets the address for the next operation during the PHI1 phase (together with R/W mode).

// This variation is used for ADL[2:0], to allow them to be additionally zeroed with the 0/ADLn signal
module AddrBusBitLow (
	PHI1, PHI2,
	ADX, Z_ADX, ADX_ABX,
	ABus_out);

	input PHI1;
	input PHI2;
	input ADX; 				// Address bus bit
	input Z_ADX; 			// Bit zeroing command
	input ADX_ABX;
	output ABus_out;		// Output value of the address bus terminal

	wire n_adx = ~(ADX & ~Z_ADX);
	wire abff_out;

	AddrBusFF abff (
		.phi_load(PHI1),
		.phi_keep(PHI2),
		.en(ADX_ABX),
		.val(n_adx),
		.q(abff_out));

	assign ABus_out = ~abff_out;

endmodule // AddrBusBitLow

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

endmodule // AddrBusFF
