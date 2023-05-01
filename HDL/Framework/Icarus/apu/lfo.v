// Bogus low-frequency oscillation signal generator.

// It is used to speed up tests, so you don't have to wait half a year for real #LFO1/2 signals to be triggered.

// Wherever artificially accelerated LFO signals are used in tests, there is a special note.

module BogusLFO (CLK, RES, nACLK2, LFO);
	
	input CLK;
	input RES;
	input nACLK2;
	output reg LFO; 		// inverse polarity (0: LFO triggers)
	reg [1:0] cnt;
	wire [1:0] n_cnt;
	wire all_ones;

	initial begin
		cnt <= 0;
	end
	always @ (negedge nACLK2) begin
		cnt <= cnt + 1;
		LFO <= all_ones && ~RES ? 1'b0 : 1'b1;
	end
	always @ (posedge CLK)
		LFO <= 1'b1;

	assign n_cnt = ~cnt;
	nor (all_ones, n_cnt[0], n_cnt[1]);

endmodule // BogusLFO
