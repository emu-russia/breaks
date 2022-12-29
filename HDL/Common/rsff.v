// Typical asynchronous Reset-Set FF based on two looped nor elements.

module rsff (r, s, q, nq);

	input r; 		// 1: Reset value (0)
	input s;		// 1: Set value (1)
	output q; 		// Current value
	output nq;		// Current value (complement)

`ifdef ICARUS

	reg val;

	always @(r or s) begin
		if (r)
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
	
	nor (nor1_out, r, nor2_out);
	nor (nor2_out, s, nor1_out);  

	assign q = nor1_out;
	assign nq = nor2_out;

`endif

endmodule // rsff
