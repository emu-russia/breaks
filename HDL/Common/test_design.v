// Used to check the design of basic elements.

module TestNmosDesign(
	compdffe_phi_load, compdffe_phi_keep, compdffe_en, compdffe_val, compdffe_q, compdffe_nq,
	dlatch_d, dlatch_en, dlatch_q, dlatch_nq,
	sdffe_d, sdffe_en, sdffe_phi_keep, sdffe_q, sdffe_nq
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

	input sdffe_d;
	input sdffe_en;
	input sdffe_phi_keep;
	output sdffe_q;
	output sdffe_nq;

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

	sdffe(
		.d(sdffe_d),
		.en(sdffe_en),
		.phi_keep(sdffe_phi_keep),
		.q(sdffe_q),
		.nq(sdffe_nq) );

endmodule 	// TestNmosDesign
