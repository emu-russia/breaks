
module AddrBusBitLow (
	PHI1, PHI2,
	ADX, Z_ADX, ADX_ABX,
	ABus_out);

	input PHI1;
	input PHI2;
	input ADX;
	input Z_ADX;
	input ADX_ABX;
	output ABus_out;

	wire n_adx = ~(ADX & ~Z_ADX);
	wire abff_out;

	comp_dffe_inv abff (
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

	comp_dffe_inv abff (
		.phi_load(PHI1),
		.phi_keep(PHI2),
		.en(ADX_ABX),
		.val(n_adx),
		.q(abff_out));

	assign ABus_out = ~abff_out;

endmodule // AddrBusBit
