// Pixel clock (PixelClock) self-check: divider ratio, phase shape, reset.
//
// Reference: BreakingNESWiki/PPU/pclk.md.  The pixel clock is derived by
// slowing the master CLK down: NTSC (RP2C02) divides CLK by 4
// (PCLK = CLK/4, table: 5369318 Hz from 21477272 Hz), PAL (RP2C07)
// divides CLK by 5 (PCLK = CLK/5, 5320342.4 Hz from 26601712 Hz).
// Below the divider a single FF splits the single phase into two
// complementary phases (/PCLK, PCLK); both are used symmetrically by the
// PPU ("left"/"right" half of a pixel).
//
// The divider is built from level-sensitive static latches clocked by the
// two halves of CLK.  During /RES the divider is forced to a defined state
// (after a short settling) and holds it while RES stays asserted; after
// RES is released the divider resumes counting.  (See the "Состояние при
// сбросе (RES)" section of the wiki.)
//
// CLK is run at a 10 ns period (half period 5 ns), so the expected PCLK
// period is exactly 40 ns (NTSC) / 50 ns (PAL), half period 20 / 25 ns.
// All timings are measured with $realtime on PCLK edges; several hundred
// CLK cycles are sampled.
// Compiled with -D RP2C02 (NTSC) or -D RP2C07 (PAL); both must pass.

`timescale 1ns/1ns

module pclk_test ();

	reg CLK;
	reg RES;
	wire n_PCLK;
	wire PCLK;

	always #5 CLK = ~CLK;

	PixelClock uut (.n_CLK(~CLK), .CLK(CLK), .RES(RES), .n_PCLK(n_PCLK), .PCLK(PCLK));

`ifdef RP2C02
	integer DIV = 4;		// PCLK = CLK / 4
`elsif RP2C07
	integer DIV = 5;		// PCLK = CLK / 5
`else
	integer DIV = 0;
`endif

	integer errors = 0;
	integer checks = 0;
	integer cyc;
	integer edge_count = 0;

	real t0, t1, tf, tr;
	real period_ns;			// expected PCLK period in ns
	real half_ns;			// expected PCLK half period in ns

	// count PCLK rising edges (used as an independent aggregate ratio check)
	always @(posedge PCLK) edge_count = edge_count + 1;

	// ---------------------------------------------------------------------
	// Sample PCLK / n_PCLK in the middle of a CLK half (just after an edge)
	// and check that they are defined and complementary.
	task sample_ok;
		input [63:0] where;
		begin
			checks = checks + 1;
			if (PCLK !== 1'b0 && PCLK !== 1'b1) begin
				errors = errors + 1;
				$display("FAIL %0s: PCLK=%b (not defined) t=%0t", where, PCLK, $time);
			end
			if (n_PCLK !== ~PCLK) begin
				errors = errors + 1;
				$display("FAIL %0s: n_PCLK=%b not complementary to PCLK=%b t=%0t", where, n_PCLK, PCLK, $time);
			end
		end
	endtask

	// ---------------------------------------------------------------------
	// Check that with RES asserted and settled, PCLK is forced to 1, n_PCLK
	// to 0 and the outputs no longer toggle while RES is held.
	task check_res_state(input integer cycles);
		integer k;
		reg prev;
		begin
			prev = PCLK;
			checks = checks + 1;
			if (PCLK !== 1'b1 || n_PCLK !== 1'b0) begin
				errors = errors + 1;
				$display("FAIL res-state: PCLK/n_PCLK = %b/%b, expected 1/0 (t=%0t)", PCLK, n_PCLK, $time);
			end
			for (k = 0; k < cycles; k = k + 1) begin
				@(posedge CLK); #1;
				sample_ok("res");
				checks = checks + 1;
				if (PCLK !== 1'b1) begin
					errors = errors + 1;
					$display("FAIL res-state: PCLK toggled to %b during RES (t=%0t)", PCLK, $time);
				end
			end
		end
	endtask

	// ---------------------------------------------------------------------
	// Measure `periods` full PCLK periods starting from a rising edge, plus
	// the two half-periods of the first one.  Returns errors via a flag.
	task measure_ratio(input integer periods, output bit ok);
		integer k;
		real th, tl;
		begin
			ok = 1'b1;
			// skip the transient right after RES release
			repeat (3) @(posedge PCLK);
			t0 = $realtime;				// rising edge of PCLK
			@(negedge PCLK); tf = $realtime;	// falling edge
			@(posedge PCLK); tr = $realtime;	// next rising edge

			th = tf - t0;				// high phase length
			tl = tr - tf;				// low phase length

			checks = checks + 1;
			if (th > half_ns + 1.0 || th < half_ns - 1.0) begin
				ok = 1'b0; errors = errors + 1;
				$display("FAIL ratio: PCLK high phase %0.1f ns, expected %0.1f ns", th, half_ns);
			end
			checks = checks + 1;
			if (tl > half_ns + 1.0 || tl < half_ns - 1.0) begin
				ok = 1'b0; errors = errors + 1;
				$display("FAIL ratio: PCLK low phase %0.1f ns, expected %0.1f ns", tl, half_ns);
			end
			checks = checks + 1;
			if (th != tl) begin
				ok = 1'b0; errors = errors + 1;
				$display("FAIL ratio: PCLK phases unequal: high %0.1f low %0.1f", th, tl);
			end

			// total span of `periods` full periods, measured from the first
			// rising edge (t0)
			for (k = 1; k < periods; k = k + 1) @(posedge PCLK);
			t1 = $realtime - t0;
			checks = checks + 1;
			if (t1 > periods * period_ns + 2.0 || t1 < periods * period_ns - 2.0) begin
				ok = 1'b0; errors = errors + 1;
				$display("FAIL ratio: %0d PCLK periods took %0.1f ns, expected %0.1f ns (divide by %0d)",
					periods, t1, periods * period_ns, DIV);
			end
		end
	endtask

	bit ok;

	initial begin
`ifdef RP2C02
		$dumpfile("pclk_test_ntsc.vcd");
`elsif RP2C07
		$dumpfile("pclk_test_pal.vcd");
`else
		$dumpfile("pclk_test.vcd");
`endif
		$dumpvars(0, pclk_test);

		period_ns = DIV * 10.0;		// 40 ns NTSC / 50 ns PAL
		half_ns   = DIV * 5.0;		// 20 ns NTSC / 25 ns PAL

		CLK = 1'b0;
		RES = 1'b1;

		// --- reset state: after settling, PCLK is forced defined -----------
		repeat (30) @(posedge CLK);		// >10 CLK cycles with RES asserted
		#1;
		check_res_state(10);			// stable 1/0, no toggling while RES

		// --- free run: ratio, 50% duty, complementary phases ---------------
		RES = 1'b0;
		// long run while sampling every CLK cycle
		for (cyc = 0; cyc < 300; cyc = cyc + 1) begin
			@(posedge CLK); #1;
			sample_ok("run");
		end

		measure_ratio(128, ok);			// 128 full periods measured

		// independent aggregate check: rising edges seen in 250 CLK cycles
		edge_count = 0;
		@(posedge CLK);
		repeat (250) @(posedge CLK);
		#1;
		checks = checks + 1;
		if (edge_count < (250 / DIV) - 4 || edge_count > (250 / DIV) + 4) begin
			errors = errors + 1;
			$display("FAIL ratio: %0d PCLK rising edges in 250 CLK cycles, expected ~%0d", edge_count, 250 / DIV);
		end

		// --- mid-run reset: freeze, then resume at the same ratio ----------
		RES = 1'b1;
		repeat (20) @(posedge CLK);		// hold RES > 10 cycles
		#1;
		check_res_state(8);

		RES = 1'b0;
		measure_ratio(64, ok);			// resumes with the same division

		// --- a short reset pulse must not leave the divider stuck ----------
		RES = 1'b1;
		#2;								// very short glitch on RES
		RES = 1'b0;
		measure_ratio(16, ok);

		if (errors == 0)
			$display("pclk_test: TEST PASS (%0d checks)", checks);
		else
			$display("pclk_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // pclk_test
