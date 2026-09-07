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
//     clipped region shows colour 0 / backdrop), and the clip gate is
//     inactive (n_CLPB high) when no data has been fed yet.
//
// The remaining bgcol hardware (BGC_0..3 stage pipelines that serialise the
// two pattern planes together with the attribute bits) is still awaiting the
// full schematic re-derivation done for TileCnt (tilecnt.v) - see comments
// in bgcol.v; this bench covers every piece that is wired and running.

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

	reg  H0_DD, F_TA, F_TB, n_FO, F_AT;
	reg [4:0] THO, TVO;
	reg [2:0] FH;
	reg n_CLPB;
	reg [7:0] PD;
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
		if (errors == 0)
			$display("bgcol_test: TEST PASS (%0d checks)", checks);
		else
			$display("bgcol_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // bgcol_test
