// Typical asynchronous Reset-Set FF based on two looped nor elements.

module rsff(r, s, q, nq);

	input r; 		// 1: Reset value (0)
	input s;		// 1: Set value (1)
	output q; 		// Current value
	output nq;		// Current value (inverted)

	wire nor1_out;
	wire nor2_out;
	
	nor (nor1_out, r, nor2_out);
	nor (nor2_out, s, nor1_out);  

	assign q = nor1_out;
	assign nq = nor2_out;

endmodule // rsff
