// BGCol / background data-shift cells self-check (HDL/PPU/bgcol.v).
//
// Scope: the pattern shift-register datapath and the colour output gate.
//
//  1. BGC_SRBit cell (BreakingNESWiki/PPU/bgcol.md, BGC_SRBit page):
//     LOAD captures val_in, STEP captures shift_in, otherwise the cell
//     holds; the content is transferred to the cell output when NEXTS is
//     high. The original translation tied the master-latch enable to 0
//     (cell frozen); fixed to the schematic's default-high constant Vcc.
//  2. BGC_SR8 (8 of the cells, common Nexts/Load/Step):
//     - parallel load: after Load+Nexts, sout == val (bit-for-bit);
//     - right shift: each Step+Nexts moves the content one place towards
//       stage 0 with the serial input sin entering stage 7 (pattern bit 7
//       = leftmost pixel, shifts out first in tile order);
//     - reload after partial shifts returns sout == val again.
//  3. BGCol top-level /CLPB path: while /CLPB is low (background clipping
//     active, left 8 pixels of the screen), the pixel colour output BGC is
//     forced to 0 regardless of the pattern/attribute activity (NES: the
//     clipped region shows colour 0 / backdrop).
//  4. BGCol per-pixel pipeline (BGC_0..3, the real background colour
//     datapath; the original translation left every internal net of these
//     cells undriven, so BGC never depended on PD - re-implemented in
//     bgcol.v).  The bench drives the top BGCol with the actual PPU fetch
//     schedule (F_TA/F_TB/F_AT/H0_DD per 8-pixel tile window, see how
//     ppu_top feeds BGCol and the FSM sequence) and verifies that the BGC
//     colour bits really walk the loaded pattern bytes per pixel, that the
//     fine-H scroll (FH) rotates the walk, and that the attribute bits
//     (BGC[3:2]) follow the colour row / quadrant selection.

`timescale 1ns/1ns

module bgcol_test ();

	integer errors = 0;
	integer checks = 0;

	// ----------------------------------------------------------------
	// 1) BGC_SRBit cell
	// ----------------------------------------------------------------
	reg  s_LOAD, s_STEP, s_NEXTS, s_shift_in, s_val_in;
	wire s_out;
	BGC_SRBit sbit (
		.LOAD(s_LOAD), .STEP(s_STEP), .NEXTS(s_NEXTS),
		.shift_in(s_shift_in), .val_in(s_val_in), .shift_out(s_out) );

	// ----------------------------------------------------------------
	// 2) BGC_SR8
	// ----------------------------------------------------------------
	reg  r_Load, r_Step, r_Nexts, r_sin;
	reg [7:0] r_val;
	wire [7:0] r_sout;
	BGC_SR8 sr8 (
		.Nexts(r_Nexts), .val(r_val), .sin(r_sin),
		.Load(r_Load), .Step(r_Step), .sout(r_sout) );

	// ----------------------------------------------------------------
	// 3) BGCol top-level clip path
	// ----------------------------------------------------------------
	reg  PCLK = 0, n_PCLK = 1;
	always #25 begin PCLK = ~PCLK; n_PCLK = ~PCLK; end

	// default-driven from t=0 so the top-level inputs never float (x) in the
	// waveform before the BGCol scenarios start
	reg  H0_DD = 0, F_TA = 0, F_TB = 0, n_FO = 1, F_AT = 0;
	reg [4:0] THO = 0;
	reg [4:0] TVO = 0;
	reg [2:0] FH = 0;
	reg n_CLPB = 1;
	reg [7:0] PD = 8'h00;
	wire [3:0] BGC;

	BGCol bg (
		.H0_DD(H0_DD), .F_TA(F_TA), .F_TB(F_TB), .n_FO(n_FO), .F_AT(F_AT),
		.THO(THO), .TVO(TVO), .FH(FH), .PCLK(PCLK), .n_CLPB(n_CLPB),
		.n_PCLK(n_PCLK), .PD(PD), .BGC(BGC) );

	// helpers
	task sbit_check(input [255:0] what, input bit exp);
		begin
			if (s_out !== exp) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL: SRBit %s: got %b expected %b", what, s_out, exp);
			end else
				checks = checks + 1;
		end
	endtask

	// drive an SR8 load + commit
	// The two phases must not overlap: the cell masters are always
	// transparent dynamic latches, so an enable must be dropped (master
	// holds via tri-state keep) before NEXTS commits the outputs - exactly
	// the non-overlapping two-phase drive the control logic provides.
	task sr8_load(input [7:0] v);
		begin
			r_val = v;
			r_sin = 1'b0; r_Step = 1'b0; r_Load = 1'b1;
			#10 r_Load = 1'b0; #5;
			r_Nexts = 1'b1; #10 r_Nexts = 1'b0; #5;
		end
	endtask

	task sr8_step(input bit s);
		begin
			r_sin = s;
			r_Step = 1'b1; #10 r_Step = 1'b0; #5;
			r_Nexts = 1'b1; #10 r_Nexts = 1'b0; #5;
		end
	endtask

	// single-cell helpers (LOAD/STEP phase then NEXTS phase)
	task sbit_phase(input bit load_en, input bit step_en, input bit v, input bit sh);
		begin
			s_val_in = v; s_shift_in = sh;
			s_LOAD = load_en; s_STEP = step_en;
			#10; s_LOAD = 1'b0; s_STEP = 1'b0; #5;
			s_NEXTS = 1'b1; #10; s_NEXTS = 1'b0; #5;
		end
	endtask

	integer p;
	integer i;

	// ----------------------------------------------------------------
	// state for the BGCol per-pixel pipeline test (section 4)
	// ----------------------------------------------------------------
	reg [7:0] tA [0:11];      // plane-A byte presented per fetch window
	reg [7:0] tB [0:11];      // plane-B byte presented per fetch window
	reg [7:0] tAT[0:11];      // attribute byte presented per fetch window
	integer NFW = 12;         // fetch windows per scenario run
	integer tqsel;            // quadrant select {TVO[1], H01} (observed)
	reg [3:0] expBGC;

	// check one sampled pixel (window ww, dot dd; BGC already sampled)
	task pipe_check(input integer ww, input integer dd, input integer tileJ,
			input integer px, input [2:0] fh);
		integer bix;
		begin
			bix = 7 - ((px + fh) % 8);
			expBGC = {tAT[tileJ][2*tqsel + 1], tAT[tileJ][2*tqsel],
				  tB[tileJ][bix], tA[tileJ][bix]};
			checks = checks + 1;
			if (BGC !== expBGC) begin
				errors = errors + 1;
				if (errors <= 30)
					$display("FAIL: pip win%0d d%0d tile%0d px%0d FH=%0d BGC=%b exp=%b (t=%0t)",
						ww, dd, tileJ, px, fh, BGC, expBGC, $time);
			end
		end
	endtask

	// run one scenario: drive NFW fetch windows on BGCol using the PPU fetch
	// schedule, sampling BGC each dot and comparing to the tile model.  The
	// byte pair fetched in window J is displayed during window J+1 dots
	// 2..7 (pixels 0..5) and window J+2 dots 0..1 (pixels 6,7).
	task pipe_run;
		integer ww, d;
		begin
			for (ww = 0; ww < NFW; ww = ww + 1) begin
				for (d = 0; d < 8; d = d + 1) begin
					@(posedge PCLK); #3;
					// schedule for this 8-dot tile window (d0 = boundary)
					H0_DD = ~d[0];
					F_TA = (d == 5) || (d == 6);
					F_TB = (d == 7) || (d == 0);
					F_AT = (d == 2);
					case (d)
						0: PD = (ww >= 1) ? tB[ww-1] : 8'h00; // plane B, F_TB 2nd dot / SRLOAD
						2,3: PD = tAT[ww];                    // attribute fetch
						5,6: PD = tA[ww];                     // plane-A fetch
						7: PD = tB[ww];                       // plane-B fetch
						default: PD = 8'h00;
					endcase
					@(negedge PCLK); #5;   // sample BGC mid ph0 of dot d
					tqsel = {TVO[1], bg.u1.H01};
					if (ww >= 1 && d >= 2 && (ww - 1) <= NFW - 2)
						pipe_check(ww, d, ww - 1, d - 2, FH);
					else if (ww >= 2 && d < 2 && (ww - 2) <= NFW - 2)
						pipe_check(ww, d, ww - 2, d + 6, FH);
				end
			end
		end
	endtask

	initial begin
		$dumpfile("bgcol_test.vcd");
		$dumpvars(0, bgcol_test);
		s_LOAD = 0; s_STEP = 0; s_NEXTS = 0; s_shift_in = 0; s_val_in = 0;

		// ---------- BGC_SRBit ----------
		// The dlatch primitives initialise q=0 (nq=1), so first normalise
		// the cell with a load of 0 before checking the behaviour.
		sbit_phase(1'b1, 1'b0, 1'b0, 1'b0);      // LOAD 0
		sbit_check("normalised load 0", 1'b0);
		// LOAD val_in=1: master takes 1 but the output stage still holds the
		// old content until NEXTS commits
		s_val_in = 1'b1; s_shift_in = 1'b0;
		s_LOAD = 1'b1; #10 s_LOAD = 1'b0; #5;
		sbit_check("master set, output not yet committed", 1'b0);
		s_NEXTS = 1'b1; #10 s_NEXTS = 1'b0; #5;
		sbit_check("after NEXTS (LOAD 1)", 1'b1);
		// STEP with shift_in=0 clears the content
		sbit_phase(1'b0, 1'b1, 1'b0, 1'b0);      // STEP 0
		sbit_check("after STEP 0", 1'b0);
		// STEP with shift_in=1 sets it again
		sbit_phase(1'b0, 1'b1, 1'b0, 1'b1);      // STEP 1
		sbit_check("after STEP 1", 1'b1);
		// hold: no LOAD/STEP, output keeps its value
		s_LOAD = 1'b0; s_STEP = 1'b0; #20;
		sbit_check("hold keeps value", 1'b1);
		// and a final load of 0
		sbit_phase(1'b1, 1'b0, 1'b0, 1'b0);
		sbit_check("reload 0", 1'b0);

		// ---------- BGC_SR8 ----------
		// parallel load round-trips through every byte
		for (p = 0; p < 256; p = p + 1) begin
			sr8_load(p[7:0]);
			if (r_sout !== p[7:0]) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL: SR8 load %02x -> sout %02x", p, r_sout);
			end else
				checks = checks + 1;
		end
		// shift behaviour with a marker byte
		sr8_load(8'b11001010);          // 0xCA
		sr8_step(1'b0);                 // expect 01100101 (0x65)
		if (r_sout !== 8'b01100101) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL: SR8 shift1 got %02x", r_sout);
		end else checks = checks + 1;
		sr8_step(1'b0);                 // expect 00110010 (0x32)
		if (r_sout !== 8'b00110010) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL: SR8 shift2 got %02x", r_sout);
		end else checks = checks + 1;
		sr8_step(1'b1);                 // sin=1 enters at bit 7: 10011001 (0x99)
		if (r_sout !== 8'b10011001) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL: SR8 shift3 got %02x", r_sout);
		end else checks = checks + 1;
		// reload resets the whole content
		sr8_load(8'h5A);
		if (r_sout !== 8'h5A) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL: SR8 reload got %02x", r_sout);
		end else checks = checks + 1;

		// ---------- BGCol /CLPB clipping ----------
		H0_DD = 0; F_TA = 0; F_TB = 0; n_FO = 1; F_AT = 0;
		THO = 0; TVO = 0; FH = 0; PD = 8'h00;
		// clipping active: output must stay 0 through many clocked dots even
		// while pattern fetch strobes and data are presented
		n_CLPB = 1'b0;
		begin : clipwin
			integer k;
			for (k = 0; k < 200; k = k + 1) begin
				FH = k % 8;
				PD = (k[7:0] * 7);
				H0_DD = k[0];
				F_TA = (k % 16) == 2;
				F_TB = (k % 16) == 3;
				F_AT = (k % 16) == 4;
				@(negedge PCLK);
				checks = checks + 1;
				if (BGC !== 4'b0000) begin
					errors = errors + 1;
					if (errors <= 20)
						$display("FAIL: BGC clip: t=%0t BGC=%b (expected 0 while n_CLPB=0)", $time, BGC);
				end
			end
		end
		// and no x/z bits anywhere in the output
		// (clip forces 0 even with uninitialised datapath)
		n_CLPB = 1'b1;

		// --------------------------------------------------------------
		// 4) BGCol real per-pixel pipeline (BGC_0..3, data-driven colour)
		// --------------------------------------------------------------
		// The BGCol top is driven with the real PPU fetch schedule: every
		// 8-dot tile window the FSM presents (see the F_TA/F_TB/F_AT fetch
		// sequence and H0_DD in the H decoder / ppu_top BGCol feed):
		//   dot 0 (boundary): F_TB 2nd dot, SRLOAD -> byte pair fetched in
		//                      the previous window enters the shifters
		//   dots 2..3: F_AT (attribute byte on PD)
		//   dots 5..6: F_TA (plane-A byte on PD)
		//   dot 7:      F_TB 1st dot (plane-B byte on PD)
		// The fetched pair of window J is displayed across window J+1 dots
		// 2..7 and window J+2 dots 0..1: pixel p = pattern bit (7-((p+FH)
		// mod 8)) (bit 7 leftmost, fine-H start select), BGC[3:2] = the
		// attribute pair of the tile's quadrant selected by {TVO[1], H01}.
		H0_DD = 0; F_TA = 0; F_TB = 0; n_FO = 1; F_AT = 0;
		THO = 5'd0; TVO = 5'd0; FH = 3'd0; PD = 8'h00;

		// scenario A: FH=0, quadrant (TVO[1]=0, H01=0) -> attribute bits 1:0
		// of each window's attribute byte colour the row.  Tiles carry
		// deliberately different pattern bytes so every pixel is distinct.
		begin : pipeA
			integer j;
			for (j = 0; j < 12; j = j + 1) begin
				tA[j] = 8'h00; tB[j] = 8'h00; tAT[j] = 8'h00;
			end
			tA[0]=8'hAA; tB[0]=8'h55; tAT[0]=8'h00;
			tA[1]=8'h81; tB[1]=8'h7E; tAT[1]=8'h03;
			tA[2]=8'h00; tB[2]=8'h00; tAT[2]=8'h01;
			tA[3]=8'hFF; tB[3]=8'hFF; tAT[3]=8'h02;
			tA[4]=8'h10; tB[4]=8'h01; tAT[4]=8'h03;
			tA[5]=8'hF0; tB[5]=8'h0F; tAT[5]=8'h00;
			tA[6]=8'hC3; tB[6]=8'h3C; tAT[6]=8'h01;
			tA[7]=8'h69; tB[7]=8'h96; tAT[7]=8'h02;
			tA[8]=8'h5A; tB[8]=8'hA5; tAT[8]=8'h03;
			// flush windows 9..11 with zero tiles
			THO = 5'd0; TVO = 5'd0; FH = 3'd0;
			pipe_run;
		end
		// scenario B: same tiles, fine-H = 3 -> the walk starts at bit 4
		begin : pipeB
			THO = 5'd0; TVO = 5'd0; FH = 3'd3;
			pipe_run;
		end
		// scenario C: fine-H = 7 -> the walk starts at bit 0 (LSB-first)
		begin : pipeC
			THO = 5'd0; TVO = 5'd0; FH = 3'd7;
			pipe_run;
		end
		// scenario D: quadrant select {TVO[1]=0, H01=1} -> bits 3:2
		begin : pipeD
			integer j;
			for (j = 0; j < 12; j = j + 1) begin
				tA[j] = 8'h00; tB[j] = 8'h00; tAT[j] = 8'h00;
			end
			tA[0]=8'hAA; tB[0]=8'h55; tAT[0]=8'h00;
			tA[1]=8'h81; tB[1]=8'h7E; tAT[1]=8'h0C;   // bits 3:2 = 11
			tA[2]=8'h5A; tB[2]=8'hA5; tAT[2]=8'h04;   // bits 3:2 = 01
			tA[3]=8'h3C; tB[3]=8'hC3; tAT[3]=8'h08;   // bits 3:2 = 10
			THO = 5'd2; TVO = 5'd0; FH = 3'd0;   // THO[1]=1 -> H01=1
			pipe_run;
		end
		// scenario E: quadrant select {TVO[1]=1, H01=0} -> bits 5:4
		begin : pipeE
			integer j;
			for (j = 0; j < 12; j = j + 1) begin
				tA[j] = 8'h00; tB[j] = 8'h00; tAT[j] = 8'h00;
			end
			tA[0]=8'hAA; tB[0]=8'h55; tAT[0]=8'h00;
			tA[1]=8'h81; tB[1]=8'h7E; tAT[1]=8'h30;   // bits 5:4 = 11
			tA[2]=8'h5A; tB[2]=8'hA5; tAT[2]=8'h10;   // bits 5:4 = 01
			tA[3]=8'h3C; tB[3]=8'hC3; tAT[3]=8'h20;   // bits 5:4 = 10
			THO = 5'd0; TVO = 5'd2; FH = 3'd1;   // TVO[1]=1 (fine-H 1 also)
			pipe_run;
		end
		// scenario F: quadrant select {TVO[1]=1, H01=1} -> bits 7:6
		begin : pipeF
			integer j;
			for (j = 0; j < 12; j = j + 1) begin
				tA[j] = 8'h00; tB[j] = 8'h00; tAT[j] = 8'h00;
			end
			tA[0]=8'hAA; tB[0]=8'h55; tAT[0]=8'h00;
			tA[1]=8'h81; tB[1]=8'h7E; tAT[1]=8'hC0;   // bits 7:6 = 11
			tA[2]=8'h5A; tB[2]=8'hA5; tAT[2]=8'h40;   // bits 7:6 = 01
			tA[3]=8'h3C; tB[3]=8'hC3; tAT[3]=8'h80;   // bits 7:6 = 10
			THO = 5'd2; TVO = 5'd2; FH = 3'd0;
			pipe_run;
		end

		if (errors == 0)
			$display("bgcol_test: TEST PASS (%0d checks)", checks);
		else
			$display("bgcol_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // bgcol_test
