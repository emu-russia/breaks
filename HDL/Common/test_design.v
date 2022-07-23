// Used to check the design of basic elements.

module TestNmosDesign(
	compdffe_phi_load, compdffe_phi_keep, compdffe_en, compdffe_val, compdffe_q, compdffe_nq,
	dlatch_d, dlatch_en, dlatch_q, dlatch_nq,
	sddfe_d, sddfe_en, sddfe_phi_keep, sddfe_q, sddfe_nq
	);

	input compdffe_phi_load;
	input compdffe_phi_keep;
	input compdffe_en;
	input compdffe_val;
	output compdffe_q;
	output compdffe_nq;

	input dlatch_d;
	input dlatch_en;
	output dlatch_q;
	output dlatch_nq;

	input sddfe_d;
	input sddfe_en;
	input sddfe_phi_keep;
	output sddfe_q;
	output sddfe_nq;

	comp_dffe_inv (
		.phi_load(compdffe_phi_load),
		.phi_keep(compdffe_phi_keep),
		.en(compdffe_en),
		.val(compdffe_val),
		.q(compdffe_q),
		.nq(compdffe_nq) );

	dlatch (
		.d(dlatch_d),
		.en(dlatch_en),
		.q(dlatch_q),
		.nq(dlatch_nq) );

	sddfe(
		.d(sddfe_d),
		.en(sddfe_en),
		.phi_keep(sddfe_phi_keep),
		.q(sddfe_q),
		.nq(sddfe_nq) );

endmodule 	// TestNmosDesign
