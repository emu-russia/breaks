// Sprite 0 Hit (Spr0Hit) self-check.
// Reference: BreakingNESWiki/PPU/mux.md ("Sprite 0 Hit" section):
//   the STRIKE condition is 1 only when a background pixel is present
//   (BGC0=1 or BGC1=1) while PCLK=0, n_SPR0HIT=0 (sprite 0 is passing
//   through the object FIFO on this pixel), n_SPR0_EV=0 (sprite 0 is on
//   this scanline) and n_VIS=0 (visible region).
// The event latches into $2002 bit 6 (DB6) and is cleared by RESCL.
// DB6 is only driven while the CPU reads $2002 (n_R2=0) with the data
// bus enabled (n_DBE=0); otherwise the pad is tri-state.

`timescale 1ns/1ns

module spr0hit_test ();

	reg PCLK;
	reg [3:0] BGC;
	reg n_SPR0HIT;
	reg n_SPR0_EV;
	reg n_VIS;
	reg n_R2;
	reg n_DBE;
	reg RESCL;
	wire DB6;

	Spr0Hit uut (
		.PCLK(PCLK),
		.BGC(BGC),
		.n_SPR0HIT(n_SPR0HIT),
		.n_SPR0_EV(n_SPR0_EV),
		.n_VIS(n_VIS),
		.n_R2(n_R2),
		.n_DBE(n_DBE),
		.RESCL(RESCL),
		.DB6(DB6) );

	integer errors = 0;
	integer checks = 0;

	// put every input into the non-strike state
	task benign();
		begin
			PCLK = 1'b1;
			BGC = 4'b0000;
			n_SPR0HIT = 1'b1;
			n_SPR0_EV = 1'b1;
			n_VIS = 1'b1;
		end
	endtask

	// clear the latch (inputs must be non-strike, otherwise it instantly re-sets)
	task clear_flag();
		begin
			benign();
			#2;
			RESCL = 1'b1; #2; RESCL = 1'b0; #2;
		end
	endtask

	// read $2002 and compare DB6
	task check_db6(input [159:0] what, input exp);
		begin
			benign();
			#1;
			n_R2 = 1'b0; n_DBE = 1'b0;   // read $2002
			#1;
			checks = checks + 1;
			if (DB6 !== exp) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL: %s exp=%b got=%b (t=%0t)", what, exp, DB6, $time);
			end
			n_R2 = 1'b1; n_DBE = 1'b1;
		end
	endtask

	// assert the strike inputs for one pulse
	task strike_pulse();
		begin
			PCLK = 1'b0;
			BGC = 4'b0001;
			n_SPR0HIT = 1'b0;
			n_SPR0_EV = 1'b0;
			n_VIS = 1'b0;
			#5;
			benign();
			#5;
		end
	endtask

	initial begin
		$dumpfile("spr0hit_test.vcd");
		$dumpvars(0, spr0hit_test);

		benign(); RESCL = 1; #3; RESCL = 0; #3;
		check_db6("after RESCL flag=0", 1'b0);

		// a real strike sets the flag and it holds
		strike_pulse();
		check_db6("strike sets flag", 1'b1);

		clear_flag();
		check_db6("RESCL clears flag", 1'b0);

		// no strike when the bg pixel is transparent (BGC0=BGC1=0)
		PCLK = 0; BGC = 0; n_SPR0HIT = 0; n_SPR0_EV = 0; n_VIS = 0;
		#5;
		check_db6("transparent bg -> no set", 1'b0);
		clear_flag();

		// no strike while PCLK=1
		PCLK = 1; BGC = 4'b0011; n_SPR0HIT = 0; n_SPR0_EV = 0; n_VIS = 0;
		#5;
		check_db6("PCLK=1 -> no set", 1'b0);
		clear_flag();

		// no strike when n_VIS=1 (outside the visible region)
		PCLK = 0; BGC = 4'b0011; n_SPR0HIT = 0; n_SPR0_EV = 0; n_VIS = 1;
		#5;
		check_db6("n_VIS=1 -> no set", 1'b0);
		clear_flag();

		// no strike when n_SPR0HIT=1 (sprite 0 not passing through the FIFO now)
		PCLK = 0; BGC = 4'b0011; n_SPR0HIT = 1; n_SPR0_EV = 0; n_VIS = 0;
		#5;
		check_db6("n_SPR0HIT=1 -> no set", 1'b0);
		clear_flag();

		// no strike when n_SPR0_EV=1 (sprite 0 is not on this scanline)
		PCLK = 0; BGC = 4'b0011; n_SPR0HIT = 0; n_SPR0_EV = 1; n_VIS = 0;
		#5;
		check_db6("n_SPR0_EV=1 -> no set", 1'b0);
		clear_flag();

		// strike again: set then read
		strike_pulse();
		check_db6("second strike sets flag", 1'b1);

		// DB6 is tri-state unless $2002 is being read
		clear_flag();
		n_R2 = 1'b1; n_DBE = 1'b0; #1;
		checks = checks + 1;
		if (DB6 !== 1'bz) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL: DB6 not z when not reading $2002 (got %b)", DB6);
		end
		n_R2 = 1'b0; n_DBE = 1'b1; #1;
		checks = checks + 1;
		if (DB6 !== 1'bz) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL: DB6 not z when n_DBE=1 (got %b)", DB6);
		end

		if (errors == 0)
			$display("spr0hit_test: TEST PASS (%0d checks)", checks);
		else
			$display("spr0hit_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // spr0hit_test
