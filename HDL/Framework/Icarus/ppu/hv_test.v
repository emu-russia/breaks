// HVCounters self-check (HDL/PPU/hv.v, with HVCounterBit stages).
// The H/V counters are tested standalone (no FSM), driven by a free-running
// 50% pixel clock, per BreakingNESWiki/PPU/hv.md:
//   - carry_in of H bit 0 is tied high: H increments by 1 on every PCLK
//     cycle while HC = 0 (and overflows naturally 511 -> 0);
//   - HC = 1 clears the whole H counter to 0 (level-sensitive);
//   - the V counter advances by 1 only while V_IN = 1, otherwise it holds;
//   - VC = 1 clears V;  RES = 1 clears both counters.
//
// The counters are two-phase transparent-latch logic: values only change
// on/near PCLK edges and control inputs only take effect at certain phases.
// Therefore every sample is taken a few ns after the PCLK rising edge (when
// the latches have settled), and control inputs are changed only during the
// PCLK-low (n_PCLK-high) phase, exactly like the FSM does in the real PPU.
//
// Test sections:
//   A. RESET: while RES=1 both counters read 0.
//   B. Free run: after reset H counts 0..600 by exact step checks
//      (including the natural 511->0 overflow); V holds 0 (V_IN=0).
//   C. HC clear: HC=1 forces H to 0; counting resumes 1,2,.. exactly.
//   D. V gating: one V_IN cycle -> exactly +1; then V holds; five V_IN
//      cycles -> +5; VC=1 clears V while H keeps counting.
//   E. Long line sweep: emulate the FSM cadence - HC pulse + V_IN pulse at
//      the end of each 341-pixel "line" - over 300 lines; verify every
//      pixel step (H: 0..340 per line) and that V counts exactly one
//      scanline per line.  Then a mid-sweep VC clears V and the count
//      resumes from zero.
//   F. RES mid-count: RES=1 -> both counters immediately 0; after RES=0
//      the counters count again (H resumes 1,2,.. from an HC-aligned zero).
//
// Prints TEST PASS / TEST FAIL with a check count.  A VCD is written only
// for the first ~2 emulated lines ($dumpoff keeps it small).

`timescale 1ns/1ns

module hv_test ();

	reg PCLK;
	reg RES;
	reg HC;
	reg VC;
	reg V_IN;

	wire [8:0] H_out;
	wire [8:0] V_out;
	wire n_PCLK;

	// Free-running complementary 50% pixel clock, period 100 ns
	initial begin
		PCLK = 1'b0;
		forever #50 PCLK = ~PCLK;
	end
	assign n_PCLK = ~PCLK;

	HVCounters uut (
		.n_PCLK(n_PCLK), .PCLK(PCLK),
		.RES(RES), .HC(HC), .VC(VC), .V_IN(V_IN),
		.H_out(H_out), .V_out(V_out) );

	integer errors = 0;
	integer checks = 0;
	integer px;

	// Wait for the next PCLK rise and sample the settled counter values.
	task sample_px;
		begin
			@(posedge PCLK);
			#20;			// settle: values stable ~few ns after the edge
			px = px + 1;
		end
	endtask

	task check_h;
		input [8:0] expected;
		input [255:0] why;
		begin
			checks = checks + 1;
			if (H_out !== expected) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL t=%0t px=%0d H=%0d expected %0d (%0s)", $time, px, H_out, expected, why);
			end
		end
	endtask

	task check_v;
		input [8:0] expected;
		input [255:0] why;
		begin
			checks = checks + 1;
			if (V_out !== expected) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL t=%0t px=%0d V=%0d expected %0d (%0s)", $time, px, V_out, expected, why);
			end
		end
	endtask

	// One full line sweep = 341 settled samples
	integer line;
	integer ev;

	initial begin
		integer k;

		$dumpfile("hv_test.vcd");
		$dumpvars(0, hv_test);

		RES = 1'b1;
		HC = 1'b0;
		VC = 1'b0;
		V_IN = 1'b0;
		px = 0;

		// ---------- A. RESET ----------
		// While RES=1 the counters must read 0 (after they had time to settle)
		repeat (3) begin
			sample_px;
			check_h(9'd0, "A: RESET holds H at 0");
			check_v(9'd0, "A: RESET holds V at 0");
		end

		// release the reset; align both counters with an explicit clear
		@(negedge PCLK);
		RES = 1'b0;
		@(negedge PCLK);
		HC = 1'b1;
		VC = 1'b1;
		sample_px;
		check_h(9'd0, "align: HC clears H to 0");
		check_v(9'd0, "align: VC clears V to 0");
		@(negedge PCLK);
		HC = 1'b0;
		VC = 1'b0;

		// ---------- B. H free run with exact step checks ----------
		// from the aligned zero, H must be k at the k-th sample for k=1..600,
		// i.e. +1 per PCLK cycle, including the natural 511 -> 0 overflow;
		// V holds 0 while V_IN = 0.
		for (k = 1; k <= 600; k = k + 1) begin
			sample_px;
			check_h(k[8:0], "B: H free run +1 per cycle");
			check_v(9'd0, "B: V holds while V_IN=0");
		end

		// ---------- C. HC clears H mid-count ----------
		@(negedge PCLK);
		HC = 1'b1;
		sample_px;
		check_h(9'd0, "C: HC pulse clears H to 0");
		@(negedge PCLK);
		HC = 1'b0;
		for (k = 1; k <= 300; k = k + 1) begin
			sample_px;
			check_h(k[8:0], "C: H resumes 1,2,.. after HC");
		end

		// ---------- D. V gating and VC ----------
		// one V_IN cycle (asserted during the low phase like the FSM's
		// V_IN=HPLA_23 pulse) -> V advances by exactly 1
		@(negedge PCLK);
		V_IN = 1'b1;
		sample_px;
		check_v(9'd1, "D: single V_IN cycle advances V to 1");
		@(negedge PCLK);
		V_IN = 1'b0;
		for (k = 1; k <= 200; k = k + 1) begin
			sample_px;
			check_v(9'd1, "D: V holds without V_IN");
		end
		// five V_IN cycles -> V advances by exactly 5 (V_IN stays high
		// through five PCLK low phases -> one increment per cycle)
		@(negedge PCLK);
		V_IN = 1'b1;
		repeat (4) sample_px;
		@(negedge PCLK);		// V_IN still high for this low phase
		sample_px;				// 5th increment
		@(negedge PCLK);
		V_IN = 1'b0;
		check_v(9'd6, "D: five V_IN cycles advance V to 6");
		// VC clears V only; H keeps counting
		@(negedge PCLK);
		VC = 1'b1;
		sample_px;
		check_v(9'd0, "D: VC clears V to 0");
		@(negedge PCLK);
		VC = 1'b0;

		// ---------- E. long emulated "line" sweep ----------
		// from now on stop dumping most of the VCD (keep the file small)
		$dumpoff;

		// align both counters to zero (start of emulated line 0)
		@(negedge PCLK);
		HC = 1'b1;
		VC = 1'b1;
		sample_px;
		check_h(9'd0, "E: line0 pixel0 H=0");
		check_v(9'd0, "E: line0 pixel0 V=0");
		@(negedge PCLK);
		HC = 1'b0;
		VC = 1'b0;

		for (line = 0; line < 300; line = line + 1) begin
			// pixels 1..340 of this line: H counts, V stays = line
			for (k = 1; k <= 340; k = k + 1) begin
				sample_px;
				check_h(k[8:0], "E: H pixel step within the line");
				check_v(line[8:0], "E: V is the line number");
			end
			// end of the line: clear H and step V, FSM-style (HC/V_IN
			// active through the whole "pixel 0" high phase of next line)
			@(negedge PCLK);
			HC = 1'b1;
			V_IN = 1'b1;
			sample_px;			// pixel 0 of line+1: H cleared to 0, V stepped
			check_h(9'd0, "E: line boundary H wraps to 0");
			begin ev = line + 1; check_v(ev[8:0], "E: V advanced by one per line"); end
			@(negedge PCLK);
			HC = 1'b0;
			V_IN = 1'b0;
		end
		// after 300 emulated lines V == 300
		check_v(9'd300, "E: V counted 300 lines");

		// mid-sweep VC clear: V resets to 0 and keeps counting lines
		@(negedge PCLK);
		VC = 1'b1;
		sample_px;
		check_v(9'd0, "E: mid-sweep VC clears V");
		@(negedge PCLK);
		VC = 1'b0;
		// align H to a fresh line start (V already 0): pixel 0 of line 0
		@(negedge PCLK);
		HC = 1'b1;
		sample_px;
		check_h(9'd0, "E2: align H to 0 after mid-sweep VC");
		check_v(9'd0, "E2: V stays 0 after mid-sweep VC");
		@(negedge PCLK);
		HC = 1'b0;
		for (line = 0; line < 20; line = line + 1) begin
			for (k = 1; k <= 340; k = k + 1) begin
				sample_px;
				check_h(k[8:0], "E2: H pixel step");
				check_v(line[8:0], "E2: V resumes from 0");
			end
			@(negedge PCLK);
			HC = 1'b1;
			V_IN = 1'b1;
			sample_px;
			check_h(9'd0, "E2: H wraps");
			begin ev = line + 1; check_v(ev[8:0], "E2: V advanced"); end
			@(negedge PCLK);
			HC = 1'b0;
			V_IN = 1'b0;
		end

		// ---------- F. RES clears both counters mid-count ----------
		@(negedge PCLK);
		RES = 1'b1;
		sample_px;
		check_h(9'd0, "F: RES clears H mid-count");
		check_v(9'd0, "F: RES clears V mid-count");
		@(negedge PCLK);
		RES = 1'b0;
		// counting resumes: align via HC and verify exact steps again
		@(negedge PCLK);
		HC = 1'b1;
		VC = 1'b1;
		sample_px;
		check_h(9'd0, "F: align after RES");
		@(negedge PCLK);
		HC = 1'b0;
		VC = 1'b0;
		for (k = 1; k <= 10; k = k + 1) begin
			sample_px;
			check_h(k[8:0], "F: H counts again after RES");
		end

		// ---------- summary ----------
		if (errors == 0)
			$display("hv_test: TEST PASS (%0d checks)", checks);
		else
			$display("hv_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // hv_test
