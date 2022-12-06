// Flop with a single CLK phase used to keep and load at the same time.  (+RESET x2)

module sdffr2e(d, en, res1, res2, phi_keep, q, nq);

	input d;				// Input value for write
	input en;				// 1: Enables Write
	input res1;				// 1: Reset 1
	input res2;				// 1: Reset 2
	input phi_keep; 		// 1: Keep the current value, 0: You can write, the old value is "cut off"
	output q;				// Current value
	output nq;				// Current value (complement)

`ifdef ICARUS

	reg val;

	always @(*) begin
		if (en & !phi_keep)
			val <= d;
		if (res1 || res2)
			val <= 1'b0;
	end

	assign q = val;
	assign nq = ~val;

	initial val <= 1'b0;

`else

	(* keep = "true" *) wire dval;
	bufif1 (dval, d, en);

	(* keep = "true" *) wire muxout;
	assign muxout = phi_keep ? oldval : dval;

	(* keep = "true" *) wire n_oldval;
	assign n_oldval = ~muxout;

	(* keep = "true" *) wire oldval;
	nor (oldval, n_oldval, res1, res2);

	assign q = oldval;
	assign nq = n_oldval;

`endif

endmodule // sdffr2e
