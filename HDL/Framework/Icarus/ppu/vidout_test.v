// Video signal generator self-check (VideoGen: ChromaDecoder, LumaDecoder,
// PhaseShifter, Emphasis, VidOut, PhaseSwing) driven by the real FSM timing.
//
// Setup ("PPU Zero" + FSM, like fsm_test.v): PixelClock + HVCounters +
// HVDecoder + PPU_FSM provide genuine SYNC / BURST / n_PICTURE timing, and the
// 11-bit RawVOut (plus the composite DAC) of VideoGen is watched.
//
// n_CC / n_LL (the inverted Color Buffer outputs, n_CC = ~chroma, n_LL = ~luma)
// are programmed per scanline: the picture part of the line uses the
// programmed color, and the blanking part (incl. the color burst) presents
// chroma 8 (n_CC = 0111) exactly like the real Color Buffer does for the burst
// phase.
//
// Assertions (references: BreakingNESWiki/PPU/video_out.md, pal.md):
//  - RawVOut never contains x/z under valid stimulus.
//  - Level structure: sync pulses -> only bit 0 (sync level); color burst ->
//    only bits 1/4 alternating (colorburst L/H, subcarrier ~ CLK/6); blanking
//    -> only bit 3 (black level); visible picture -> levels set by n_LL/n_CC.
//  - Luma rails (visible): n_LL = 00 -> swing {8,9}, 01 -> {5,9},
//    10 -> {3,7}, 11 -> {2,6}; grays (n_CC=1111, no chroma phase) hold steady
//    on the rail high tap: 9, 9, 7, 6. Colors 14/15 (n_CC = 0001/0000) are
//    forced "black" (PBLACK) -> level 3.
//  - Burst subcarrier: ~1 rising edge of the RawVOut[4] burst swing per 6 CLK
//    periods inside a color-burst window (subcarrier = CLK/6 => NTSC
//    3.5795 MHz / PAL 4.4336 MHz).
//  - Emphasis: TINT (RawVOut[10]) is never set outside the visible picture and
//    never with all of n_TR/n_TG/n_TB off; with emphasis enabled it must fire.
//  - PAL (RP2C07): burst and chroma swing must be present on both line
//    parities (V0 alternates the chroma decoder bank for the per-line phase
//    alteration). NTSC (RP2C02) has a single decoder bank.
//
// Prints TEST PASS/FAIL. Both revisions must pass.

`timescale 1ns/1ns

module VidOut_Run ();

	reg CLK;
	reg RES;

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

	wire BURST;
	wire SYNC;
	wire n_PICTURE;

	// Tune CLK/PCLK timing according to 2C02/2C07
`ifdef RP2C02
	always #23.28 CLK = ~CLK;
`elsif RP2C07
	always #18.79 CLK = ~CLK;
`else
	always #1 CLK = ~CLK;
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
		.RES(RES), .VBL_EN(1'b0), .n_R2(1'b1), .n_DBE(1'b1), .n_OBCLIP(1'b0), .n_BGCLIP(1'b0), .BLACK(1'b0),
		.BURST(BURST), .SYNC(SYNC), .n_PICTURE(n_PICTURE),
		.VB(VB), .BLNK(BLNK),
		.V_IN(V_IN), .HC(HC), .VC(VC) );

	// ------------------------------------------------------------------
	// VideoGen + composite DAC, driven by the FSM outputs.
	// ------------------------------------------------------------------

	reg [3:0] n_CC;
	reg [1:0] n_LL;
	reg n_TR;
	reg n_TG;
	reg n_TB;

	wire [10:0] RawVOut;
	wire [31:0] CompositeOut;

	VideoGen vidgen (
		.n_CLK(~CLK), .CLK(CLK), .n_PCLK(n_PCLK), .PCLK(PCLK),
		.RES(RES),
		.n_CC(n_CC), .n_LL(n_LL),
		.BURST(BURST), .SYNC(SYNC), .n_PICTURE(n_PICTURE),
		.n_TR(n_TR), .n_TG(n_TG), .n_TB(n_TB),
`ifdef RP2C07
		.V0(VCnt[0]),
`endif
		.RawVOut(RawVOut) );

	PPU_CompositeDAC dac (.RawIn(RawVOut), .CompositeOut(CompositeOut) );

	// ------------------------------------------------------------------
	// Per-line color program. Each programmed color ("row") is applied to a
	// PAIR of consecutive scanlines (row key = (VCnt>>1) % 16), so every row
	// is exercised on both line parities (needed by the PAL checks):
	//   0..3  gray (n_CC = 1111, chroma 0), luma n_LL = 00/01/10/11, no em.
	//   4..7  gray n_LL = 00 with emphasis /TR//TG//TB: all, R, G, B.
	//   8..15 colored (chroma phase present), no emphasis:
	//       8: n_CC 0100 n_LL 00 |  9: n_CC 0100 n_LL 10
	//      10: n_CC 0011 n_LL 00 | 11: n_CC 0001 n_LL 00 (chroma 14 PBLACK)
	//      12: n_CC 0000 n_LL 11 | 13: n_CC 1011 n_LL 01
	//      14: n_CC 0111 n_LL 00 | 15: n_CC 0101 n_LL 01 (0111 = chroma 8,
	//                                            the color-burst phase color)
	// ------------------------------------------------------------------

	reg [3:0] pic_cc;
	reg [1:0] pic_ll;
	reg pic_tr, pic_tg, pic_tb;

	task setrow(input integer r);
		begin
			case (r % 16)
				0:  begin pic_cc = 4'b1111; pic_ll = 2'b00; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b1; end
				1:  begin pic_cc = 4'b1111; pic_ll = 2'b01; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b1; end
				2:  begin pic_cc = 4'b1111; pic_ll = 2'b10; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b1; end
				3:  begin pic_cc = 4'b1111; pic_ll = 2'b11; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b1; end
				4:  begin pic_cc = 4'b1111; pic_ll = 2'b00; pic_tr = 1'b0; pic_tg = 1'b0; pic_tb = 1'b0; end
				5:  begin pic_cc = 4'b1111; pic_ll = 2'b00; pic_tr = 1'b0; pic_tg = 1'b1; pic_tb = 1'b1; end
				6:  begin pic_cc = 4'b1111; pic_ll = 2'b00; pic_tr = 1'b1; pic_tg = 1'b0; pic_tb = 1'b1; end
				7:  begin pic_cc = 4'b1111; pic_ll = 2'b00; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b0; end
				8:  begin pic_cc = 4'b0100; pic_ll = 2'b00; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b1; end
				9:  begin pic_cc = 4'b0100; pic_ll = 2'b10; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b1; end
				10: begin pic_cc = 4'b0011; pic_ll = 2'b00; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b1; end
				11: begin pic_cc = 4'b0001; pic_ll = 2'b00; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b1; end
				12: begin pic_cc = 4'b0000; pic_ll = 2'b11; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b1; end
				13: begin pic_cc = 4'b1011; pic_ll = 2'b01; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b1; end
				14: begin pic_cc = 4'b0111; pic_ll = 2'b00; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b1; end
				15: begin pic_cc = 4'b0101; pic_ll = 2'b01; pic_tr = 1'b1; pic_tg = 1'b1; pic_tb = 1'b1; end
			endcase
		end
	endtask

	// row index for a scanline: each row covers a pair of lines (both parities)
	function [3:0] row_of(input [8:0] v);
		begin
			row_of = (v >> 1) % 16;
		end
	endfunction

	// The FSM keeps n_PICTURE = 0 for H = 329..340 and H = 0..270 of the next
	// line (visible part) and asserts it for the blanking/sync/burst part
	// (H ~ 271..328). Present the burst color only there; the color buffer in
	// the real chip supplies color 8 during the burst the same way.
	always @(negedge CLK) begin
		if (RES) begin
			pic_cc <= 4'b1111; pic_ll <= 2'b00; pic_tr <= 1'b1; pic_tg <= 1'b1; pic_tb <= 1'b1;
			n_CC <= 4'b0111; n_LL <= 2'b00; n_TR <= 1'b1; n_TG <= 1'b1; n_TB <= 1'b1;
		end else if (HCnt == 9'd271) begin
			// blanking part of the line: color 8 (color-burst phase color)
			n_CC <= 4'b0111; n_LL <= 2'b00; n_TR <= 1'b1; n_TG <= 1'b1; n_TB <= 1'b1;
		end else if (HCnt == 9'd0 || HCnt == 9'd329) begin
			// visible part: per-line color program
			setrow(row_of(VCnt));
			n_CC <= pic_cc; n_LL <= pic_ll; n_TR <= pic_tr; n_TG <= pic_tg; n_TB <= pic_tb;
		end
	end

	// ------------------------------------------------------------------
	// Self-checking part
	// ------------------------------------------------------------------

	integer errors = 0;
	integer checks = 0;

	// Highest set level bit among RawVOut[9:1]
	function [3:0] level_of(input [10:0] rv);
		begin
			level_of = 4'd0;
			if (rv[9]) level_of = 4'd9;
			else if (rv[8]) level_of = 4'd8;
			else if (rv[7]) level_of = 4'd7;
			else if (rv[6]) level_of = 4'd6;
			else if (rv[5]) level_of = 4'd5;
			else if (rv[4]) level_of = 4'd4;
			else if (rv[3]) level_of = 4'd3;
			else if (rv[2]) level_of = 4'd2;
			else if (rv[1]) level_of = 4'd1;
		end
	endfunction

	reg prev_sy, prev_bu, prev_np;
	reg [3:0] stable_cnt;
	reg ctrl_changed;
	reg prev_rv4, prev_rv1;

	reg last_was_burst;
	integer burst_clk;
	integer burst_e4;
	integer burst_e1;
	integer burst_windows;
	integer burst_windows_ok;

	// envelope / counters per row (index = (VCnt>>1) % 16), per parity (PAL)
	reg [3:0] row_min [0:15];
	reg [3:0] row_max [0:15];
	integer row_n   [0:15];
	reg [3:0] row_min_p1 [0:15];
	reg [3:0] row_max_p1 [0:15];
	integer row_n_p1 [0:15];
	integer em_on_tint;
	integer em_on_n;
	integer em_off_tint_bad;
	integer rows_seen;
	integer i;				// array init loop
	task check(input [255:0] what, input bit_cond);
		begin
			checks = checks + 1;
			if (!bit_cond) begin
				errors = errors + 1;
				if (errors <= 40)
					$display("FAIL: %0s (t=%0t)", what, $time);
			end
		end
	endtask

	// mid-picture area: away from the sync/burst/blanking part (H ~ 271..328)
	// and from the per-line color switching dots (H = 0/329), so color-keyed
	// checks only see the color that was programmed for the sampled row
	wire inH = (HCnt >= 9'd10 && HCnt <= 9'd260);

	always @(negedge CLK) begin
		if (RES) begin
			prev_sy <= 1'b0; prev_bu <= 1'b0; prev_np <= 1'b1;
			stable_cnt <= 0;
			last_was_burst <= 1'b0;
			burst_clk <= 0; burst_e4 <= 0; burst_e1 <= 0;
			burst_windows <= 0; burst_windows_ok <= 0;
			em_on_tint <= 0; em_on_n <= 0; em_off_tint_bad <= 0;
			rows_seen <= 0;
			// integer memories are not zero-initialized in Verilog
			for (i = 0; i < 16; i = i + 1) begin
				row_min[i] <= 4'd0; row_max[i] <= 4'd0; row_n[i] <= 0;
				row_min_p1[i] <= 4'd0; row_max_p1[i] <= 4'd0; row_n_p1[i] <= 0;
			end
		end else begin
			// Stability filter: the video-out latches (en = n_PCLK) and the FSM
			// need ~1 dot to reflect a SYNC/BURST/n_PICTURE transition, so a
			// level check is only valid once the controls have been unchanged
			// for a few samples. IMPORTANT: the sample on which a control
			// transition is *detected* still carries the old saturated counter,
			// so checks must also be gated on the controls not having changed
			// this very sample (ctrl_changed).
			ctrl_changed = (SYNC != prev_sy) || (BURST != prev_bu) || (n_PICTURE != prev_np);
			if (ctrl_changed)
				stable_cnt <= 0;
			else if (stable_cnt < 8)
				stable_cnt <= stable_cnt + 1;
			prev_sy <= SYNC; prev_bu <= BURST; prev_np <= n_PICTURE;

			if (!ctrl_changed && stable_cnt >= 8 && VCnt >= 9'd4) begin
				if (RawVOut[0] === 1'bx || RawVOut[0] === 1'bz ||
				    RawVOut[10] === 1'bx || RawVOut[10] === 1'bz) begin
					checks = checks + 1;
					errors = errors + 1;
					if (errors <= 40) $display("FAIL: RawVOut contains x/z (t=%0t)", $time);
				end else if (SYNC == 1'b1) begin
					// sync level: only the sync bit, everything else off
					check("sync level", (RawVOut[0] == 1'b1) && (RawVOut[10:1] == 10'b0));
				end else if (BURST == 1'b1) begin
					// color burst: luma/black/emphasis off, swing on bits 1/4 only
					check("burst level", (RawVOut[0] == 1'b0) && (RawVOut[3] == 1'b0) &&
						(RawVOut[10] == 1'b0) && (RawVOut[2] == 1'b0) &&
						(RawVOut[9:5] == 5'b0) && (RawVOut[1] !== RawVOut[4]) &&
						(RawVOut[1] | RawVOut[4]));
				end else if (n_PICTURE == 1'b1) begin
					// blanking: black level (bit 3), nothing else
					check("blanking level", RawVOut == 11'b00000001000);
				end else if (inH) begin
					// ---------------- visible picture ----------------
					if (RawVOut[10]) begin
						if (!pic_tr || !pic_tg || !pic_tb)
							em_on_tint = em_on_tint + 1;
						else
							em_off_tint_bad = em_off_tint_bad + 1;
					end else begin
						if (!pic_tr || !pic_tg || !pic_tb)
							em_on_n = em_on_n + 1;
					end
					if (pic_tr && pic_tg && pic_tb) begin
						// level envelope by programmed color
						begin : env
							integer r;
							integer l;
							r = row_of(VCnt);
							l = level_of(RawVOut);
							if (row_n[r] == 0) begin
								rows_seen = rows_seen + 1;
								row_min[r] = l; row_max[r] = l;
							end else begin
								if (l < row_min[r]) row_min[r] = l;
								if (l > row_max[r]) row_max[r] = l;
							end
							row_n[r] = row_n[r] + 1;
`ifdef RP2C07
							if (VCnt[0]) begin
								if (row_n_p1[r] == 0) begin
									row_min_p1[r] = l; row_max_p1[r] = l;
								end else begin
									if (l < row_min_p1[r]) row_min_p1[r] = l;
									if (l > row_max_p1[r]) row_max_p1[r] = l;
								end
								row_n_p1[r] = row_n_p1[r] + 1;
							end
`endif
						end
					end
				end
			end
		end
	end

	// burst subcarrier window measurement (independent of the stability
	// filter): sample RawVOut on every CLK edge (the swing toggles at the
	// subcarrier rate, ~1 edge per 3 CLK => ~2 per 6 CLK period) and count
	// rising edges of bits 4/1 plus CLK periods inside each BURST=1 window.
	always @(posedge CLK or negedge CLK) begin
		if (RES) begin
			last_was_burst <= 1'b0;
			burst_clk <= 0; burst_e4 <= 0; burst_e1 <= 0;
			burst_windows <= 0; burst_windows_ok <= 0;
		end else begin
			if (BURST == 1'b1) begin
				if (CLK === 1'b1)
					burst_clk = burst_clk + 1;
				if (last_was_burst && burst_clk > 4) begin
					if (prev_rv4 === 1'b0 && RawVOut[4] === 1'b1) burst_e4 = burst_e4 + 1;
					if (prev_rv1 === 1'b0 && RawVOut[1] === 1'b1) burst_e1 = burst_e1 + 1;
				end
			end else if (BURST == 1'b0 && last_was_burst) begin
				if (burst_clk > 40) begin
					burst_windows = burst_windows + 1;
					// one rising edge of the swing per ~6 CLK subcarrier period;
					// the burst window is dot-quantized so its start phase
					// drifts against the subcarrier -> allow +/-2 edges
					if (burst_e4 * 6 >= burst_clk - 14 && burst_e4 * 6 <= burst_clk + 14 &&
						burst_e4 >= 4 && burst_e1 >= 4) begin
						burst_windows_ok = burst_windows_ok + 1;
					end else begin
						checks = checks + 1;
						errors = errors + 1;
						if (errors <= 60)
							$display("FAIL: burst subcarrier density: clk=%0d e4=%0d e1=%0d (t=%0t)", burst_clk, burst_e4, burst_e1, $time);
					end
				end
				burst_clk = 0; burst_e4 = 0; burst_e1 = 0;
			end
			last_was_burst <= (BURST == 1'b1);
			prev_rv4 <= RawVOut[4];
			prev_rv1 <= RawVOut[1];
		end
	end


	initial begin

`ifdef RP2C02
		$dumpfile("vidout_test_ntsc.vcd");
`elsif RP2C07
		$dumpfile("vidout_test_pal.vcd");
`else
		$display("vidout_test: wtf? no revision defined");
		$finish;
`endif
		$dumpvars(0, VidOut_Run);

		CLK <= 1'b0;
		RES <= 1'b1;
		n_CC <= 4'b0111;
		n_LL <= 2'b00;
		n_TR <= 1'b1;
		n_TG <= 1'b1;
		n_TB <= 1'b1;
		prev_rv4 <= 1'b0;
		prev_rv1 <= 1'b0;

		// hold the internal reset for a few cycles, then release
		repeat (32) @ (posedge CLK);
		RES <= 1'b0;

		// dump the first few scanlines only (keep the .vcd small), then
		// continue with assertions only
		repeat (2048 * 10) @ (posedge CLK);
		$dumpoff;

		// run long enough to cover many scanlines of every color row
		repeat (2048 * 110) @ (posedge CLK);

		// ---- summary checks ----
		check("every row seen in the picture", rows_seen >= 12);
		check("burst windows measured", burst_windows >= 40);
		check("burst subcarrier density OK", burst_windows_ok == burst_windows);
		// emphasis: with all of n_TR/n_TG/n_TB off TINT must never fire;
		// with emphasis on it must fire at least sometimes (never outside pic,
		// which the level checks above already enforce)
		check("TINT never with emphasis off", em_off_tint_bad == 0);
		check("TINT fires with emphasis on", em_on_tint > 1000);
		check("emphasis rows output seen", em_on_n > 300);

		// luma rails / gray / PBLACK expectations per row (both revisions)
		begin : railcheck
			integer r;
			reg [3:0] lo, hi;
			for (r = 0; r < 16; r = r + 1) begin
				if (row_n[r] > 0) begin
					lo = row_min[r];
					hi = row_max[r];
					case (r)
						0, 1:
							check("gray steady level 9 (LU3/LU2)", lo == 9 && hi == 9);
						2:
							check("gray steady level 7 (LU1)", lo == 7 && hi == 7);
						3:
							check("gray steady level 6 (LU0)", lo == 6 && hi == 6);
						8, 10, 14:
							check("chroma LU3 swing 8..9", lo == 8 && hi == 9);
						9:
							check("chroma LU1 swing 3..7", lo == 3 && hi == 7);
						11, 12:
							check("PBLACK colors stay at 3", lo == 3 && hi == 3);
						13, 15:
							check("chroma LU2 swing 5..9", lo == 5 && hi == 9);
						default:
							check("unexpected row index", 1'b1);
					endcase
				end
			end
		end

`ifdef RP2C07
		// PAL: the phase alteration banks (V0 selects the decoder bank) must
		// work on both line parities: colored rows swing on odd lines too and
		// grays stay chroma-free (steady) on odd lines.
		begin : palcheck
			integer r;
			for (r = 0; r < 16; r = r + 1) begin
				if (row_n_p1[r] > 0) begin
					if (r == 0 || r == 1)
						check("PAL odd-line gray steady 9", row_max_p1[r] == 9 && row_min_p1[r] == 9);
					else if (r == 2)
						check("PAL odd-line gray steady 7", row_max_p1[r] == 7 && row_min_p1[r] == 7);
					else if (r == 3)
						check("PAL odd-line gray steady 6", row_max_p1[r] == 6 && row_min_p1[r] == 6);
					else if (r == 11 || r == 12)
						check("PAL odd-line PBLACK stays 3", row_max_p1[r] == 3 && row_min_p1[r] == 3);
					else
						check("PAL odd-line chroma swing present", row_max_p1[r] > row_min_p1[r]);
				end
			end
		end
`endif

		if (errors == 0)
			$display("vidout_test: TEST PASS (%0d checks)", checks);
		else
			$display("vidout_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // VidOut_Run
