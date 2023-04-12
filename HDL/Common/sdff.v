
module sdff (d, phi_keep, q, nq);

	input d;				// Input value for write
	input phi_keep; 		// 1: Keep the current value, 0: You can write, the old value is "cut off"
	output q;				// Current value
	output nq;				// Current value (complement)

`ifdef ICARUS

	reg val;

	always @(*) begin
		if (!phi_keep)
			val <= d;
	end

	assign q = val;
	assign nq = ~val;

	initial val <= 1'b0;

`else

	(* keep = "true" *) wire muxout;
	assign muxout = phi_keep ? oldval : d;

	(* keep = "true" *) wire n_oldval;
	assign n_oldval = ~muxout;

	(* keep = "true" *) wire oldval;
	assign oldval = ~n_oldval;

	assign q = oldval;
	assign nq = n_oldval;

`endif

endmodule // sdff
