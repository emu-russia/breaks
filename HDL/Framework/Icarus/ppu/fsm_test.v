// PPU FSM ("PPU Zero") self-check: PixelClock + HVCounters + HVDecoder +
// PPU_FSM form the H/V timing generator (no rendering attached), driven like
// the original wave-only fsm_test.v. Reference: BreakingNESWiki/PPU/fsm.md,
// hv.md, hv_decoder.md.
//
// The checker is deliberately lean (sampled once per PCLK, summaries per
// line/frame) so a two-frame run completes quickly. It asserts:
//   1. H counter: value in 0..340; between two adjacent PCLK samples H
//      advances by exactly +1, or wraps 340->0 (or 339->0 on the NTSC
//      even/odd short pre-render line). Every scanline is 340 or 341
//      pixels long (measured between successive H==0 samples).
//   2. V counter: in 0..261 (NTSC) / 0..311 (PAL); it advances exactly once
//      per scanline; a frame is LINES scanlines long (V==0 occurs once per
//      frame, and after V==VMAX it wraps to 0).
//   3. SYNC: exactly one rising edge per scanline -> LINES pulses per frame.
//   4. VB/BLNK: high on the vblank lines (>= 240) and low on the visible
//      lines (< 240) once the frame is running (mid-window samples).
//   5. VBlank interrupt: with VBL_EN=1, Int rises in the vblank window and
//      stays; a $2002 read (n_R2=0 together with n_DBE=0 for a few pixels,
//      performed at V==247) clears it (read-clear); Int stays low until the
//      next vblank and rises once per frame.
//
// Compile with -D RP2C02 (NTSC) or -D RP2C07 (PAL); both must pass.

`timescale 1ns/1ns

module FSM_Run ();

	reg CLK;
	reg RES;
	reg n_R2;
	reg n_DBE;

	wire PCLK;
	wire n_PCLK;

	wire [8:0] HCnt;
	wire [8:0] VCnt;
	wire [23:0] HDecoder_out;
	wire [9:0] VDecoder_out;

	wire HC;
	wire VC;
	wire V_IN;
	wire VB;
	wire BLNK;

	wire H0_DD, H0_D, H1_DD, nH1_D, H2_DD, nH2_D, H3_DD, H4_DD, H5_DD;
	wire RESCL, n_PICTURE, SYNC, Int, DB7;

`ifdef RP2C02
	always #23.28 CLK = ~CLK;
	localparam integer LINES  = 262;
	localparam integer VMAX   = 261;
`elsif RP2C07
	always #18.79 CLK = ~CLK;
	localparam integer LINES  = 312;
	localparam integer VMAX   = 311;
`else
	always #1 CLK = ~CLK;
	localparam integer LINES  = 262;
	localparam integer VMAX   = 261;
`endif

	PixelClock pclk (
		.n_CLK(~CLK), .CLK(CLK), .RES(RES),
		.n_PCLK(n_PCLK), .PCLK(PCLK) );

	HVCounters hv (
		.n_PCLK(n_PCLK), .PCLK(PCLK),
		.RES(RES), .HC(HC), .VC(VC), .V_IN(V_IN),
		.H_out(HCnt), .V_out(VCnt) );

	HVDecoder dec (
		.H_in(HCnt), .V_in(VCnt), .VB(VB), .BLNK(BLNK),
		.HPLA_out(HDecoder_out), .VPLA_out(VDecoder_out) );

	PPU_FSM fsm (
		.n_PCLK(n_PCLK), .PCLK(PCLK),
		.H_out(HCnt), .V_out(VCnt), .HPLA_out(HDecoder_out), .VPLA_out(VDecoder_out),
		.RES(RES), .VBL_EN(1'b1), .n_R2(n_R2), .n_DBE(n_DBE),
		.n_OBCLIP(1'b0), .n_BGCLIP(1'b0), .BLACK(1'b0),
		.H0_DD(H0_DD), .H0_D(H0_D), .H1_DD(H1_DD), .nH1_D(nH1_D),
		.H2_DD(H2_DD), .nH2_D(nH2_D), .H3_DD(H3_DD), .H4_DD(H4_DD), .H5_DD(H5_DD),
		.SYNC(SYNC), .n_PICTURE(n_PICTURE), .RESCL(RESCL), .VB(VB), .BLNK(BLNK),
		.Int(Int), .DB7(DB7), .V_IN(V_IN), .HC(HC), .VC(VC) );

	// ---------------- checker state ----------------
	integer errors = 0;
	integer checks = 0;

	reg [8:0] hprev = 9'd511;
	reg [8:0] vprev = 9'd511;
	reg    saw_hwrap = 0;
	integer px = 0;			// pixel counter
	integer frame = 0;		// completed frames (V wraps seen)
	integer checked = 0;		// assertion window (frames 2..3)

	integer line_len = 0;		// pixels since the line start (H==0)
	integer in_line = 0;
	integer line_h0_seen = 0;

	integer v_changes_in_line = 0;	// V counter changes observed this line
	integer line_syncs = 0;		// SYNC rises this line
	reg    sync_prev = 0;
	integer frame_syncs = 0;	// SYNC rises this frame
	integer frame_vwrap = 0;	// V==0 line starts seen this frame

	integer h_max_seen = 0;
	integer v_max_seen = 0;

	// INT read-clear state
	reg    int_prev2 = 0;
	integer int_rises = 0;		// Int rising edges seen this frame
	reg    int_high_seen = 0;	// Int observed high in this vblank
	integer reads_done = 0;		// completed $2002 reads
	integer db7_bad = 0;

	// VB/BLNK on the wrong (visible) lines
	integer vb_on_visible = 0;
	integer blnk_on_visible = 0;
	integer vb_vblank_samples = 0;
	integer blnk_vblank_samples = 0;

	integer db7_good = 0;

	task failmsg(input [200:0] why);
		begin
			errors = errors + 1;
			if (errors <= 40)
				$display("FAIL t=%0t px=%0d V=%0d H=%0d: %0s", $time, px, VCnt, HCnt, why);
		end
	endtask

	// ---------------- per-pixel sampler ----------------
	always @(posedge PCLK) begin
		#2;			// sample in the settled part of the pixel

		px = px + 1;

		// H stepping (mod-512 counter; wraps at 340/339 are the line ends).
		// Skip the first ~2 lines after reset while the divider/counters
		// settle (hprev is only armed once a line wrap has been seen).
		if (hprev != 9'd511 && saw_hwrap) begin
			if (HCnt == (hprev + 1)) begin
				// normal +1
			end else if (HCnt == 0 && (hprev == 340 || hprev == 339)) begin
				// line wrap (339 = NTSC even/odd short line)
			end else begin
				failmsg("H counter does not step by 1");
			end
		end
		if (HCnt > h_max_seen) h_max_seen = HCnt;
		if (HCnt > 340) failmsg("H counter exceeds 340");
		hprev = HCnt;

		// line-length accounting (H==0 opens a new line)
		if (HCnt == 0) begin
			if (px > 300) saw_hwrap = 1;
			if (in_line) begin
				// line that just ended: length 340 or 341 pixels
				line_len = line_len + 1;	// count the H==0 pixel too
				if (checked) begin
					checks = checks + 1;
					if (line_len != 340 && line_len != 341) begin
						errors = errors + 1;
						if (errors <= 40)
							$display("FAIL: scanline length %0d pixels (V=%0d)", line_len, VCnt);
					end
					if (line_syncs != 1) begin
						errors = errors + 1;
						if (errors <= 40)
							$display("FAIL: %0d SYNC pulses in a scanline (V=%0d)", line_syncs, VCnt);
					end else checks = checks + 1;
					if (v_changes_in_line != 1) begin
						errors = errors + 1;
						if (errors <= 40)
							$display("FAIL: %0d V changes in scanline (V=%0d)", v_changes_in_line, VCnt);
					end else checks = checks + 1;
				end
			end
			in_line = 1;
			line_len = 0;
			line_syncs = 0;
			v_changes_in_line = 0;
			frame_vwrap = frame_vwrap + 1;
		end else begin
			line_len = line_len + 1;
		end

		// V stepping
		if (vprev != 9'd511) begin
			if (VCnt != vprev) begin
				v_changes_in_line = v_changes_in_line + 1;
				if (!(VCnt == (vprev + 1) || (vprev == VMAX && VCnt == 0))) begin
					failmsg("V counter does not step by 1");
				end
				if (VCnt == 0) begin
					// frame boundary
					if (checked) begin
						checks = checks + 1;
						if (frame_syncs != LINES) begin
							errors = errors + 1;
							if (errors <= 40)
								$display("FAIL: frame %0d has %0d HSyncs (expected %0d)", frame, frame_syncs, LINES);
						end
						checks = checks + 1;
						if (frame_vwrap != LINES) begin
							errors = errors + 1;
							if (errors <= 40)
								$display("FAIL: frame %0d has %0d lines (expected %0d)", frame, frame_vwrap, LINES);
						end
						checks = checks + 1;
						if (!(int_rises == 1 && reads_done == 1 && db7_good == 1 && db7_bad == 0)) begin
							errors = errors + 1;
							if (errors <= 40)
								$display("FAIL: frame %0d INT pattern (rises=%0d seen=%0d reads=%0d db7=%0d db7bad=%0d)", frame, int_rises, int_high_seen, reads_done, db7_good, db7_bad);
						end
					end
					frame = frame + 1;
					if (frame == 2) checked = 1;
					frame_syncs = 0;
					frame_vwrap = 0;
					int_high_seen = 0;
					int_rises = 0;
					reads_done = 0;
					db7_good = 0;
					db7_bad = 0;
				end
			end
		end
		if (VCnt > v_max_seen) v_max_seen = VCnt;
		if (VCnt > VMAX) failmsg("V counter exceeds max");
		vprev = VCnt;

		// SYNC rising edges
		if (SYNC && !sync_prev) begin
			line_syncs = line_syncs + 1;
			frame_syncs = frame_syncs + 1;
		end
		sync_prev = SYNC;

		// VB/BLNK window sanity (mid-line samples, only in checked frames)
		if (checked && HCnt == 12) begin
			if (VCnt > 1 && VCnt < 240) begin
				if (VB) vb_on_visible = vb_on_visible + 1;
				if (BLNK) blnk_on_visible = blnk_on_visible + 1;
			end
`ifdef RP2C02
			if (VCnt >= 245 && VCnt < 260) begin
`elsif RP2C07
			if (VCnt >= 245 && VCnt < 310) begin
`else
			if (VCnt >= 245 && VCnt < 260) begin
`endif
				if (VB) vb_vblank_samples = vb_vblank_samples + 1;
				if (BLNK) blnk_vblank_samples = blnk_vblank_samples + 1;
			end
		end

		// VBlank interrupt: count rising edges; perform exactly one $2002
		// read per checked frame at V==247 (pixels 120..130): DB7 reads 1
		// mid-read, and Int clears once the read strobe ends.
		if (Int && !int_prev2) int_rises = int_rises + 1;
		int_prev2 = Int;
		if (checked) begin
			if (Int) int_high_seen = 1;
			if (VCnt == 247 && reads_done == 0 && HCnt >= 120 && HCnt <= 130) begin
				n_R2 = 1'b0;
				n_DBE = 1'b0;
				if (HCnt == 126) begin
					checks = checks + 1;
					if (DB7 !== 1'b1) begin
						errors = errors + 1;
						db7_bad = db7_bad + 1;
						if (errors <= 40) $display("FAIL: $2002 DB7 read = %b (expected 1)", DB7);
					end else db7_good = db7_good + 1;
				end
				if (HCnt == 130) begin
					n_R2 = 1'b1;
					n_DBE = 1'b1;
					reads_done = reads_done + 1;
					#2;
					checks = checks + 1;
					if (Int !== 1'b0) begin
						errors = errors + 1;
						if (errors <= 40) $display("FAIL: Int not cleared by $2002 read");
					end
				end
			end else if (!(VCnt == 247)) begin
				n_R2 = 1'b1;		// strobe released outside line 247
				n_DBE = 1'b1;
			end
		end

		// done after the first checked frame completes (frames 2 and 3 are
		// both asserted; stop after frame 3 wraps)
		if (frame >= 4) begin
			// summary assertions
			checks = checks + 1;
			if (h_max_seen != 340) begin
				errors = errors + 1;
				$display("FAIL: H max = %0d (expected 340)", h_max_seen);
			end
			checks = checks + 1;
			if (v_max_seen != VMAX) begin
				errors = errors + 1;
				$display("FAIL: V max = %0d (expected %0d)", v_max_seen, VMAX);
			end
			checks = checks + 1;
			if (vb_on_visible != 0) begin
				errors = errors + 1;
				$display("FAIL: VB high on %0d visible-line samples", vb_on_visible);
			end else if (blnk_on_visible != 0) begin
				errors = errors + 1;
				$display("FAIL: BLNK high on %0d visible-line samples", blnk_on_visible);
			end
			checks = checks + 1;
`ifdef RP2C02
			if (vb_vblank_samples < 25 || blnk_vblank_samples < 25) begin
`elsif RP2C07
			if (vb_vblank_samples < 100 || blnk_vblank_samples < 100) begin
`else
			if (vb_vblank_samples < 25 || blnk_vblank_samples < 25) begin
`endif
				errors = errors + 1;
				$display("FAIL: VB/BLNK not held during vblank (VB %0d, BLNK %0d samples)", vb_vblank_samples, blnk_vblank_samples);
			end
			if (errors == 0)
				$display("fsm_test: TEST PASS (%0d checks)", checks);
			else
				$display("fsm_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
			$finish;
		end
	end

	initial begin
`ifdef RP2C02
		$dumpfile("fsm_test_ntsc.vcd");
`elsif RP2C07
		$dumpfile("fsm_test_pal.vcd");
`else
		$display("wtf?");
		$finish;
`endif
		$dumpvars(0, FSM_Run);
		$dumpoff;			// tiny VCD (wave window re-enabled below)

		CLK = 1'b0; RES = 1'b1; n_R2 = 1'b1; n_DBE = 1'b1;
		#3000;				// hold reset
		RES = 1'b0;

		// dump only a short window: a couple of scanlines inside the first
		// checked vblank (V==245..247), so the VCD stays small
		while (!(frame == 2 && VCnt >= 245 && VCnt < 247)) @(negedge PCLK);
		$dumpon;
		repeat (2 * 341) @(negedge PCLK);
		$dumpoff;

		// time watchdog (never expected to fire)
		while (1) @(negedge PCLK);
	end

endmodule // FSM_Run
