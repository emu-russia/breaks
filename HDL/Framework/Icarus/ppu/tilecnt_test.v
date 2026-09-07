// TileCnt (background tile counters, HDL/PPU/tilecnt.v) self-check.
//
// The module is exercised in realistic context: a minimal "PPU zero" cluster
// (PixelClock + HVCounters + HVDecoder + PPU_FSM) drives TileCnt exactly as
// in ppu_top.v, with the background scroll inputs (TH/TV/NTH/NTV/FV) held at
// fixed values. Assertions follow the documented NES "v register" behaviour
// (nesdev PPU scrolling; BreakingNESWiki/PPU/tilecnt.md counter table):
//
//   1. Per visible scanline the coarse-X counter (THO) performs one complete
//      +1 (mod 32) cycle - all 32 tile columns of the nametable row are
//      covered - and every transition is +1 (mod 32), except the single
//      dot-256 reload that re-seeds THO from the scroll value TH (one
//      arbitrary-jump transition per line, and only there).
//   2. The dot-256 reload also restores the horizontal nametable bit (NTX,
//      NT_adr bit 10) from the scroll bit NTH.
//   3. The fine-Y counter (FVO) advances by one per scanline (mod 8), and
//      the coarse-Y counter (TVO) advances one step on every fine-Y 7->0
//      wrap, with the nametable-bottom wrap rule: TVO 29 -> 0 together with
//      a toggle of the vertical nametable bit (NTY, NT_adr bit 11).
//   4. The vertical bits are loaded from the scroll inputs (TV/NTV/FV) at
//      the frame-start RESCL: scanline 0 of each frame (from frame 2 on)
//      starts with TVO=TV, FVO=FV, NTY=NTV.
//   5. NT fetch addresses always decode as
//         NT_adr = 0x2000 | NTY<<11 | NTX<<10 | TVO<<5 | THO
//      (bit 12 tied low, bit 13 = nametable base) whenever an NT fetch is
//      signalled by the FSM, checked against the concurrently sampled
//      counter outputs - verifies the address wiring/bit order.
//
// Hardware background: the tile-counter cells were emitted by the schematic
// translator with undriven step/load/carry nets (dead counters); they are
// rewired in tilecnt.v per the PPU_Evo.circ pages, see the comments there.

`timescale 1ns/1ns

module tilecnt_test ();

	reg CLK = 0;
	reg RES = 0;
	always #23.28 CLK = ~CLK;

	wire PCLK, n_PCLK;
	wire [8:0] HCnt, VCnt;
	wire [23:0] HPLA;
	wire [9:0] VPLA;
	wire VB, BLNK, V_IN, HC, VC;
	wire H0_DD;
	wire SC_CNT, RESCL, E_EV, F_TB, F_TA, F_AT, n_FNT, n_FO;
	wire DB7_w;

	PixelClock pclk (.n_CLK(~CLK), .CLK(CLK), .RES(RES), .n_PCLK(n_PCLK), .PCLK(PCLK));
	HVCounters hv (.n_PCLK(n_PCLK), .PCLK(PCLK), .RES(RES), .HC(HC), .VC(VC), .V_IN(V_IN), .H_out(HCnt), .V_out(VCnt));
	HVDecoder dec (.H_in(HCnt), .V_in(VCnt), .VB(VB), .BLNK(BLNK), .HPLA_out(HPLA), .VPLA_out(VPLA));
	PPU_FSM fsm (
		.n_PCLK(n_PCLK), .PCLK(PCLK), .H_out(HCnt), .V_out(VCnt),
		.HPLA_out(HPLA), .VPLA_out(VPLA), .RES(RES), .VBL_EN(1'b0), .n_R2(1'b1),
		.n_DBE(1'b1), .n_OBCLIP(1'b0), .n_BGCLIP(1'b0), .BLACK(1'b0),
		.VB(VB), .BLNK(BLNK), .V_IN(V_IN), .HC(HC), .VC(VC),
		.H0_DD(H0_DD), .H0_D(), .H1_DD(), .nH1_D(), .H2_DD(), .nH2_D(), .H3_DD(), .H4_DD(), .H5_DD(),
		.S_EV(), .CLIP_O(), .CLIP_B(), .Z_HPOS(), .n_EVAL(),
		.E_EV(E_EV), .I_OAM2(), .OBJ_READ(), .n_VIS(), .n_FNT(n_FNT),
		.F_TB(F_TB), .F_TA(F_TA), .n_FO(n_FO), .F_AT(F_AT), .SC_CNT(SC_CNT),
		.BURST(), .SYNC(), .n_PICTURE(), .RESCL(RESCL), .Int(), .DB7(DB7_w));

	// scroll register values (would come from ScrollRegs in the real PPU)
	reg [4:0] TH_scroll;
	reg [4:0] TV_scroll;
	reg       NTH_scroll;
	reg       NTV_scroll;
	reg [2:0] FV_scroll;

	wire [13:0] AT_adr, NT_adr;
	wire [4:0] THO, TVO;
	wire [2:0] n_FVO;

	TileCnt dut (
		.n_PCLK(n_PCLK), .PCLK(PCLK), .W6_2_Ena(1'b0), .SC_CNT(SC_CNT), .RESCL(RESCL),
		.E_EV(E_EV), .TSTEP(1'b0), .F_TB(F_TB), .H0_DD(H0_DD), .BLNK(BLNK), .I_1_32(1'b0),
		.TH(TH_scroll), .TV(TV_scroll), .NTH(NTH_scroll), .NTV(NTV_scroll), .FV(FV_scroll),
		.n_FVO(n_FVO), .THO(THO), .TVO(TVO), .AT_adr(AT_adr), .NT_adr(NT_adr) );

	integer errors = 0;
	integer checks = 0;

	// ------- bookkeeping -------
	integer frames = 0;          // RESCL (frame-start) pulses seen
	reg    started = 0;          // model armed (frame >= 2)
	integer curV = -1;
	integer model_fineY;         // fine Y of the line being displayed (model)
	integer model_coarseY;       // coarse Y of the line being displayed (model)
	reg    model_NTY;

	// per-line accumulation
	reg    in_line;
	reg    prev_line_visible;
	integer line_seen [0:31];
	integer line_changes;
	integer last_THO;
	reg    jump_used;
	reg    row_checked;
	integer line_no;

	function automatic integer mod32(input integer v);
		begin
			mod32 = (v % 32 + 32) % 32;
		end
	endfunction

	always @(negedge PCLK) begin
		if (RES) begin
			started = 0;
			in_line = 0;
		end else if (^VCnt === 1'bx || ^VCnt === 1'bz) begin
			// H/V counters still unknown after reset: re-sync
			curV = -1;
		end else if (VCnt !== curV) begin
			// ----- scanline boundary -----
			if (VCnt < curV) begin
				// scanline counter rolled over (261->0 NTSC, 311->0 PAL):
				// frame boundary (RESCL loads the vertical bits from scroll)
				frames = frames + 1;
				started = (frames >= 2);
			end
			if (in_line) begin
				// a checked visible line finished: verify the full coarse-X
				// cycle coverage
				begin : linecheck
					integer i, missing;
					missing = 0;
					for (i = 0; i < 32; i = i + 1)
						if (line_seen[i] != 1) missing = missing + 1;
					if (missing != 0) begin
						errors = errors + 1;
						if (errors <= 25)
							$display("FAIL: line V=%0d: THO coverage missing %0d of 32 columns", line_no, missing);
					end else
						checks = checks + 1;
					if (line_changes < 33 || line_changes > 37) begin
						errors = errors + 1;
						if (errors <= 25)
							$display("FAIL: line V=%0d: THO changed %0d times (expect ~34 = 32-cycle + 1 reload + 2 tail steps)", line_no, line_changes);
					end else
						checks = checks + 1;
				end
				in_line = 0;
			end
			// step the vertical model for the new line
			if (started && prev_line_visible && VCnt > 0 && VCnt < 240) begin
				// fine Y always advances once per visible scanline
				if (model_fineY == 7) begin
					// coarse Y advances on the fine-Y 7->0 wrap
					if (model_coarseY == 29) begin
						model_coarseY = 0;
						model_NTY = ~model_NTY;
					end else if (model_coarseY == 31) begin
						model_coarseY = 0;
					end else begin
						model_coarseY = (model_coarseY + 1) & 5'h1F;
					end
				end
				model_fineY = (model_fineY + 1) & 3'h7;
			end
			prev_line_visible = 0;
			curV = VCnt;
			if (started && VCnt == 0) begin
				// scanline 0 of a frame: vertical state loaded by RESCL
				model_fineY   = FV_scroll;
				model_coarseY = TV_scroll;
				model_NTY     = NTV_scroll;
			end
			if (started && VCnt < 240 && BLNK == 0) begin
				in_line = 1;
				line_no = VCnt;
				line_changes = 0;
				jump_used = 0;
				row_checked = 0;
				last_THO = -1;
				begin : clearseen
					integer i;
					for (i = 0; i < 32; i = i + 1) line_seen[i] = 0;
				end
			end
		end else if (started && in_line && BLNK == 0) begin
			prev_line_visible = 1;

			// --- mid-line row-state check (fixed dot, well before the
			//     dot-256 vertical update) ---
			if (!row_checked && HCnt >= 56 && HCnt <= 64) begin
				row_checked = 1;
				if (~n_FVO !== model_fineY[2:0]) begin
					errors = errors + 1;
					if (errors <= 25)
						$display("FAIL: V=%0d fineY (n_FVO=%b, model %0d)", curV, n_FVO, model_fineY);
				end else checks = checks + 1;
				if (TVO !== model_coarseY[4:0]) begin
					errors = errors + 1;
					if (errors <= 25)
						$display("FAIL: V=%0d coarseY (TVO=%0d, model %0d)", curV, TVO, model_coarseY);
				end else checks = checks + 1;
				if (NT_adr[11] !== model_NTY) begin
					errors = errors + 1;
					if (errors <= 25)
						$display("FAIL: V=%0d NTY (got %b, model %b)", curV, NT_adr[11], model_NTY);
				end else checks = checks + 1;
				// at this dot of the line the horizontal nametable bit equals
				// the scroll bit NTH (no coarse-X wrap happened yet for this
				// scroll value - wrap at dot ~176 for TH=7)
				if (NT_adr[10] !== NTH_scroll) begin
					errors = errors + 1;
					if (errors <= 25)
						$display("FAIL: V=%0d NTX mid-line (got %b, model %b)", curV, NT_adr[10], NTH_scroll);
				end else checks = checks + 1;
			end

			// --- NT fetch address decode (n_FNT active low) ---
			if (!n_FNT) begin
				if (NT_adr[13:12] !== 2'b10 || NT_adr[4:0] !== THO || NT_adr[9:5] !== TVO) begin
					errors = errors + 1;
					if (errors <= 25)
						$display("FAIL: NT_adr decode V=%0d H=%0d THO=%0d TVO=%0d NTadr=%04x", curV, HCnt, THO, TVO, NT_adr);
				end else checks = checks + 1;
			end

			// --- THO transitions ---
			if (last_THO == -1) begin
				last_THO = THO;
				line_seen[THO] = 1;
			end else if (THO !== last_THO) begin
				line_changes = line_changes + 1;
				if (mod32(THO) == mod32(last_THO + 1)) begin
					// normal +1 tile step (also covers the 31->0 wrap)
					checks = checks + 1;
				end else if (HCnt >= 240 && HCnt <= 280 && !jump_used) begin
					// the dot-256 reload: re-seed THO from the scroll value
					// and restore NTX
					jump_used = 1;
					if (THO !== TH_scroll) begin
						errors = errors + 1;
						if (errors <= 25)
							$display("FAIL: V=%0d reload: THO=%0d, expected scroll %0d", curV, THO, TH_scroll);
					end else checks = checks + 1;
					if (NT_adr[10] !== NTH_scroll) begin
						errors = errors + 1;
						if (errors <= 25)
							$display("FAIL: V=%0d reload: NTX=%b, expected scroll %b", curV, NT_adr[10], NTH_scroll);
					end else checks = checks + 1;
				end else begin
					errors = errors + 1;
					if (errors <= 25)
						$display("FAIL: V=%0d H=%0d THO bad step %0d -> %0d", curV, HCnt, last_THO, THO);
				end
				last_THO = THO;
				line_seen[THO] = 1;
			end
		end
	end

	initial begin
		$dumpfile("tilecnt_test.vcd");
		$dumpvars(0, tilecnt_test);
		$dumpoff;                       // bounded dump: first frame is uninteresting
		TH_scroll  = 5'd7;
		TV_scroll  = 5'd10;
		NTH_scroll = 1'b1;
		NTV_scroll = 1'b0;
		FV_scroll  = 3'd4;
		curV = -1;
		in_line = 0;
		prev_line_visible = 0;
		#2000; RES = 1; #2000; RES = 0;
		// run until well into frame 3 (checks run on frames 2 and 3)
		repeat (280000) @(posedge PCLK);
		$dumpon;
		repeat (1200) @(posedge PCLK);
		if (errors == 0)
			$display("tilecnt_test: TEST PASS (%0d checks)", checks);
		else
			$display("tilecnt_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // tilecnt_test
