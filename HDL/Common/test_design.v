// Used to check the design of basic elements.

module TestNmosDesign(
	compdffe_phi_load, compdffe_phi_keep, compdffe_en, compdffe_val, compdffe_q, compdffe_nq,
	dlatch_d, dlatch_en, dlatch_q, dlatch_nq,
	sdffe_d, sdffe_en, sdffe_phi_keep, sdffe_q, sdffe_nq,
	sdffre_d, sdffre_en, sdffre_res, sdffre_phi_keep, sdffre_q, sdffre_nq,
	bustris_a, bustris_n_x, bustris_n_en,
	rsff_r, rsff_s, rsff_q, rsff_nq	);

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

	input sdffre_d;
	input sdffre_en;
	input sdffre_res;
	input sdffre_phi_keep;
	output sdffre_q;
	output sdffre_nq;

	input bustris_a;
	output bustris_n_x;
	input bustris_n_en;

	input rsff_r;
	input rsff_s;
	output rsff_q;
	output rsff_nq;

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

	sdffre(
		.d(sdffre_d),
		.en(sdffre_en),
		.res(sdffre_res),
		.phi_keep(sdffre_phi_keep),
		.q(sdffre_q),
		.nq(sdffre_nq) );

	bustris(
		.a(bustris_a),
		.n_x(bustris_n_x),
		.n_en(bustris_n_en) );

	rsff(
		.r(rsff_r),
		.s(rsff_s),
		.q(rsff_q),
		.nq(rsff_nq) );

endmodule 	// TestNmosDesign
