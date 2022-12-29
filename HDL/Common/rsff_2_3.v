// Typical asynchronous Reset-Set FF based on two looped nor elements.	(nor-3 to reset)

module rsff_2_3 (res1, res2, s, q, nq);

	input res1; 	// 1: Reset1 value (0)
	input res2; 	// 1: Reset2 value (0)
	input s;		// 1: Set value (1)
	output q; 		// Current value
	output nq;		// Current value (complement)

`ifdef ICARUS

	reg val;

	always @(*) begin
		if (res1 | res2)
			val <= 1'b0;
		else if (s)
			val <= 1'b1;
	end

	assign q = val;
	assign nq = ~val;

	initial val <= 1'b0;

`else

	wire nor1_out;
	wire nor2_out;
	
	nor (nor1_out, res1, res2, nor2_out);
	nor (nor2_out, s, nor1_out);  

	assign q = nor1_out;
	assign nq = nor2_out;

`endif

endmodule // rsff_2_3
