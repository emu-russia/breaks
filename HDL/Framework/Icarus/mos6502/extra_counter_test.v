// Extra counter (T2-T5) self-check.
// The counter is a shift register: after a cycle with T1=1 the outputs
// n_T2..n_T5 go low one machine cycle each (T2, T3, T4, T5), then return
// high. n_ready=1 ('not ready') freezes the counter; TRES2 resets it.
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module extra_counter_test ();

	reg CLK;
	wire PHI1;
	wire PHI2;

	reg TRES2;
	reg n_ready;
	reg T1;

	wire n_T2, n_T3, n_T4, n_T5;

	always #25 CLK = ~CLK;

	ClkGen clk (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2));

	ExtraCounter extra_cnt (
		.PHI1(PHI1), .PHI2(PHI2), .TRES2(TRES2), .n_ready(n_ready), .T1(T1),
		.n_T2(n_T2), .n_T3(n_T3), .n_T4(n_T4), .n_T5(n_T5));

	integer errors = 0;
	integer tests  = 0;
	integer c = 0;

	// expected {nT2,nT3,nT4,nT5} per cycle, matching the stimulus below
	reg [3:0] exp_list [0:30];
	integer n_exp = 0;

	task check_now;
		reg [3:0] got;
		begin
			if (n_exp <= 30 && n_exp >= 0) begin
				tests = tests + 1;
				got = {n_T2, n_T3, n_T4, n_T5};
				if (got !== exp_list[n_exp]) begin
					$display("FAIL cycle %0d: n_T2..5=%b%b%b%b, expected %b%b%b%b",
						c, n_T2, n_T3, n_T4, n_T5, exp_list[n_exp][3], exp_list[n_exp][2], exp_list[n_exp][1], exp_list[n_exp][0]);
					errors = errors + 1;
				end
			end
			n_exp = n_exp + 1;
		end
	endtask

	always @(posedge CLK) begin
		#8;
		check_now();
		c = c + 1;
	end

	initial begin
		$dumpfile("extra_counter_test.vcd");
		$dumpvars(0, extra_counter_test);

		CLK <= 1'b0;
		TRES2 <= 1'b0;
		n_ready <= 1'b0;
		T1 <= 1'b0;

		// expected trace (idle 1111, T1 -> T2..T5, idle, second run,
		// pause on n_ready, resume, all high); bits {nT2,nT3,nT4,nT5}
		exp_list[0]  = 4'b1111; exp_list[1]  = 4'b1111; exp_list[2]  = 4'b1111; exp_list[3]  = 4'b1111;
		exp_list[4]  = 4'b0111; exp_list[5]  = 4'b1011; exp_list[6]  = 4'b1101; exp_list[7]  = 4'b1110;
		exp_list[8]  = 4'b1111; exp_list[9]  = 4'b1111; exp_list[10] = 4'b1111; exp_list[11] = 4'b1111;
		exp_list[12] = 4'b1111; exp_list[13] = 4'b0111; exp_list[14] = 4'b1011;
		exp_list[15] = 4'b1101; exp_list[16] = 4'b1101; exp_list[17] = 4'b1101; exp_list[18] = 4'b1101;
		exp_list[19] = 4'b1101; exp_list[20] = 4'b1110; exp_list[21] = 4'b1111; exp_list[22] = 4'b1111;
		exp_list[23] = 4'b1111; exp_list[24] = 4'b1111; exp_list[25] = 4'b1111;

		repeat (4) @ (posedge CLK);

		// Load T1 and check how it is pushed out through outputs T2-T5
		T1 <= 1'b1;
		repeat (1) @ (posedge CLK);
		T1 <= 1'b0;
		repeat (8) @ (posedge CLK);

		// Load T1, then suddenly do NotReady; then ready
		T1 <= 1'b1;
		repeat (1) @ (posedge CLK);
		T1 <= 1'b0;
		repeat (2) @ (posedge CLK);
		n_ready <= 1'b1;
		repeat (4) @ (posedge CLK);
		n_ready <= 1'b0;
		repeat (4) @ (posedge CLK);

		// TRES2 reset check (no token loaded): all high
		TRES2 <= 1'b1;
		repeat (1) @ (posedge CLK);
		TRES2 <= 1'b0;
		repeat (2) @ (posedge CLK);

		if (errors == 0)
			$display("extra_counter_test: TEST PASS (%0d checks)", tests);
		else
			$display("extra_counter_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // extra_counter_test
