// ObjectFIFO self-check against NES sprite rendering semantics.
// Reference: BreakingNESWiki/PPU/fifo.md (lane structure, H3''..H5'' lane
// select table, priority, sprite-0 hit, CLPO left-8 clipping).
//
// Protocol used by the bench (documented in HDL/PPU/fifo.v):
//   * lanes are loaded during OBJ_READ dots; the lane is selected by the
//     H3''..H5'' code per the wiki table (code 7 -> lane 0, 3 -> lane 1,
//     5 -> lane 2, 1 -> lane 3, 6 -> lane 4, 2 -> lane 5, 4 -> lane 6,
//     0 -> lane 7) and the data type by H0''..H2'': 2 = attribute (OB),
//     3 = X position (OB), 5 = pattern plane A (PD), 7 = pattern plane B
//     (PD).  PD_FIFO=0 forces zero patterns (empty sprite slot).
//   * Z_HPOS arms the loaded lanes; every dot with n_VIS=0 is one screen
//     pixel; a lane starts emitting at screen dot X (8 pixels).
//   * Outputs: n_ZCOL0/n_ZCOL1 active-low pixel bits, ZCOL2/ZCOL3 palette
//     bits, n_ZPRIO = ~attribute bit 5, n_SPR0HIT low while sprite 0
//     (lane 0) emits a non-transparent pixel, CLPO=1 blanks all lanes.
// Compile with -D RP2C02 -D ICARUS.

`timescale 1ns/1ns

module fifo_test ();

	reg PCLK = 0;
	reg n_PCLK = 1;
	always #50 PCLK = ~PCLK;
	always #50 n_PCLK = ~n_PCLK;   // posedge n_PCLK falls mid-dot

	reg OBJ_READ = 0;
	reg H0_DD, H1_DD, H2_DD, H3_DD, H4_DD, H5_DD;
	reg Z_HPOS = 0;
	reg n_VIS = 1;
	reg PD_FIFO = 1;
	reg CLPO = 0;
	reg [7:0] PD = 0;
	reg [7:0] OB = 0;

	wire n_SPR0HIT, n_ZCOL0, n_ZCOL1, ZCOL2, ZCOL3, n_ZPRIO, n_OBJ_RD_ATTR;

	ObjectFIFO uut (
		.n_SPR0HIT(n_SPR0HIT), .n_ZCOL0(n_ZCOL0), .n_ZCOL1(n_ZCOL1),
		.ZCOL2(ZCOL2), .ZCOL3(ZCOL3), .n_ZPRIO(n_ZPRIO),
		.n_OBJ_RD_ATTR(n_OBJ_RD_ATTR),
		.OBJ_READ(OBJ_READ),
		.H0_DD(H0_DD), .H1_DD(H1_DD), .H2_DD(H2_DD),
		.H3_DD(H3_DD), .H4_DD(H4_DD), .H5_DD(H5_DD),
		.n_PCLK(n_PCLK), .Z_HPOS(Z_HPOS), .n_VIS(n_VIS),
		.PCLK(PCLK), .PD_FIFO(PD_FIFO), .PD(PD), .CLPO(CLPO), .OB(OB) );

	integer errors = 0;
	integer checks = 0;
	integer dot_i;

	// ---------- helpers -------------------------------------------------
	// pixel color of the DUT outputs decoded into a plain 2-bit sprite
	// pixel {B,A} + palette + priority (1 = transparent marker)
	task sample_pixel(output [7:0] px);
		begin
			px = 8'h00;
			px[0] = ~n_ZCOL0;     // plane A bit
			px[1] = ~n_ZCOL1;     // plane B bit
			px[3:2] = {ZCOL3, ZCOL2};
			px[4] = ~n_ZPRIO;     // 1 = sprite in front of bg
			px[5] = ~n_SPR0HIT;   // 1 = sprite 0 hit condition present
		end
	endtask

	// one dot: wait for the posedge (state advance) and sample after it
	task dot;
		begin
			@(posedge PCLK);
			#2;
		end
	endtask

	// set the H bits of the module (delayed H counter values)
	task set_h(input [2:0] abc, input [2:0] sel);
		begin
			{H3_DD, H4_DD, H5_DD} = sel;
			{H0_DD, H1_DD, H2_DD} = abc;
		end
	endtask

	// load phase `abc` (attribute/X/A/B) of lane `lane` with OB/PD data held
	task lane_load(input [2:0] lane, input [2:0] abc, input [7:0] data);
		begin
			case (lane)
				0: set_h(abc, 3'd7);
				1: set_h(abc, 3'd3);
				2: set_h(abc, 3'd5);
				3: set_h(abc, 3'd1);
				4: set_h(abc, 3'd6);
				5: set_h(abc, 3'd2);
				6: set_h(abc, 3'd4);
				7: set_h(abc, 3'd0);
			endcase
			if (abc == 3'd5 || abc == 3'd7) PD = data; else OB = data;
			OBJ_READ = 1;
			dot();
			OBJ_READ = 0;
		end
	endtask

	// check a pixel against expectations
	task expect_px(input [159:0] what, input [7:0] exp);
		reg [7:0] got;
		begin
			#1;                      // let combinational outputs settle
			sample_pixel(got);
			checks = checks + 1;
			if (got !== exp) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL: %0s dot%0d nZCOL0/1=%b%b ZCOL2/3=%b%b nZPRIO=%b nSPR0HIT=%b (want %08b)",
						what, dot_i, n_ZCOL0, n_ZCOL1, ZCOL2, ZCOL3, n_ZPRIO, n_SPR0HIT, exp);
			end
		end
	endtask

	// run `n` visible dots and compare each to expected pixel fn (exp array)
	task expect_visible_dots(input [159:0] what, input integer n,
	                         input [7:0] e0, e1, e2, e3, e4, e5, e6, e7,
	                         input [7:0] tail);
		reg [7:0] e [0:7];
		begin
			e[0] = e0; e[1] = e1; e[2] = e2; e[3] = e3;
			e[4] = e4; e[5] = e5; e[6] = e6; e[7] = e7;
			for (dot_i = 0; dot_i < n; dot_i = dot_i + 1) begin
				if (dot_i < 8)
					expect_px(what, e[dot_i]);
				else
					expect_px(what, tail);
				dot();
			end
		end
	endtask

	// reset the module into a clean idle state: the module has no reset
	// input, so zero the pattern planes of every lane (transparent sprite)
	// and push everything through a Z_HPOS cycle + one visible dot.
	task flush();
		integer li;
		begin
			OBJ_READ = 0; CLPO = 0; n_VIS = 1; PD_FIFO = 1; PD = 8'd0; OB = 8'd0;
			for (li = 0; li < 8; li = li + 1) begin
				lane_load(li[2:0], 3'd2, 8'd0);
				lane_load(li[2:0], 3'd3, 8'd0);
				lane_load(li[2:0], 3'd5, 8'd0);
				lane_load(li[2:0], 3'd7, 8'd0);
			end
			Z_HPOS = 1; dot(); Z_HPOS = 0; dot();
		end
	endtask

	// ------------------------------------------------------------------
	initial begin
		$dumpfile("fifo_test.vcd");
		$dumpvars(0, fifo_test);

		set_h(3'd0, 3'd0);   // no load
		OBJ_READ = 0; PD_FIFO = 1;

		// ---- 1. idle: no lanes loaded, nothing is shown -----------------
		flush();
		n_VIS = 0;
		expect_px("idle pixel", 8'h00);
		dot(); n_VIS = 1;

		// ---- 2. single sprite at X=0 (lane 0 = sprite 0) -----------------
		// sprite data: attr pal=3, prio=1, no flip; X=0;
		// plane A pattern 1011_0000 -> pixels {0,2,3} set, plane B empty
		flush();
		lane_load(3'd0, 3'd2, 8'b0010_0011);   // attr: OB[5]=1 prio, OB[1:0]=11
		lane_load(3'd0, 3'd3, 8'd0);           // X = 0
		lane_load(3'd0, 3'd5, 8'b1011_0000);   // plane A
		lane_load(3'd0, 3'd7, 8'd0);           // plane B
		Z_HPOS = 1; dot(); Z_HPOS = 0;
		n_VIS = 0;
		// pixels 0,2,3 -> color 01 (B=0,A=1), pal 3, prio front, spr0-hit
		expect_visible_dots("sprite X=0", 10,
			8'h3D, 8'h00, 8'h3D, 8'h3D,
			8'h00, 8'h00, 8'h00, 8'h00, 8'h00);
		n_VIS = 1;

		// ---- 3. sprite X offset: pixels appear at dots X..X+7 ------------
		flush();
		lane_load(3'd0, 3'd2, 8'b0010_0011);
		lane_load(3'd0, 3'd3, 8'd4);           // X = 4
		lane_load(3'd0, 3'd5, 8'b1000_0000);   // pixel 0 only
		lane_load(3'd0, 3'd7, 8'd0);
		Z_HPOS = 1; dot(); Z_HPOS = 0;
		n_VIS = 0;
		expect_visible_dots("sprite X=4", 12,
			8'h00, 8'h00, 8'h00, 8'h00, 8'h3D, 8'h00,
			8'h00, 8'h00, 8'h00);
		n_VIS = 1;

		// ---- 4. horizontal flip (attr bit 6) ------------------------------
		flush();
		lane_load(3'd0, 3'd2, 8'b0110_0011);   // flip=1, prio=1, pal=3
		lane_load(3'd0, 3'd3, 8'd0);
		lane_load(3'd0, 3'd5, 8'b1000_0000);   // bit 7 set -> mirrors to bit 0
		lane_load(3'd0, 3'd7, 8'd0);
		Z_HPOS = 1; dot(); Z_HPOS = 0;
		n_VIS = 0;
		expect_visible_dots("flip", 9,
			8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
			8'h3D, 8'h00);
		n_VIS = 1;

		// ---- 5. priority: lane 0 (sprite 0) wins over lane 1 -------------
		// lane 0: X=4, single pixel {0} pal=0 prio=1
		// lane 1: X=0, all 8 pixels set pal=1 prio=1 (lower priority)
		flush();
		lane_load(3'd0, 3'd2, 8'b0010_0000);   // prio=1, pal=0
		lane_load(3'd0, 3'd3, 8'd4);
		lane_load(3'd0, 3'd5, 8'b1000_0000);
		lane_load(3'd0, 3'd7, 8'd0);
		lane_load(3'd1, 3'd2, 8'b0010_0101);   // prio=1, pal=1
		lane_load(3'd1, 3'd3, 8'd0);
		lane_load(3'd1, 3'd5, 8'b1111_1111);
		lane_load(3'd1, 3'd7, 8'b1111_1111);
		Z_HPOS = 1; dot(); Z_HPOS = 0;
		n_VIS = 0;
		// dots 0..3: lane 1 only -> B=A=1 pal1 front; sprite0 not showing
		// dot  4..7: lane 0 front -> B=0,A=1 pal0, spr0hit
		expect_visible_dots("priority", 9,
			8'h17, 8'h17, 8'h17, 8'h17,
			8'h31, 8'h17, 8'h17, 8'h17, 8'h00);
		n_VIS = 1;

		// ---- 6. sprite behind background: n_ZPRIO reflects attr bit 5 -----
		flush();
		lane_load(3'd0, 3'd2, 8'b0000_0000);   // prio=0 (behind), pal=0
		lane_load(3'd0, 3'd3, 8'd0);
		lane_load(3'd0, 3'd5, 8'b1000_0000);
		lane_load(3'd0, 3'd7, 8'd0);
		Z_HPOS = 1; dot(); Z_HPOS = 0;
		n_VIS = 0;
		expect_visible_dots("behind bg", 9,
			8'h21, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
			8'h00, 8'h00);
		n_VIS = 1;

		// ---- 7. CLPO clips the left 8 screen pixels -----------------------
		flush();
		lane_load(3'd0, 3'd2, 8'b0010_0011);
		lane_load(3'd0, 3'd3, 8'd5);
		lane_load(3'd0, 3'd5, 8'b1111_1111);
		lane_load(3'd0, 3'd7, 8'b1111_1111);
		Z_HPOS = 1; dot(); Z_HPOS = 0;
		n_VIS = 0;
		CLPO = 1;
		// dots 0..7 are clipped; the sprite pixels exist on screen dots 8..12
		for (dot_i = 0; dot_i < 13; dot_i = dot_i + 1) begin
			if (dot_i == 8) CLPO = 0;         // clip only the left 8 dots
			if (dot_i >= 8 && dot_i <= 12)
				expect_px("CLPO left 8", 8'h3F);
			else
				expect_px("CLPO left 8", 8'h00);
			dot();
		end
		CLPO = 0; n_VIS = 1;

		// ---- 8. sprite 0 hit follows the sprite 0 pixels -------------------
		// lane 0 has pixels on dots 0..2 only (then transparent); lane 1
		// shows on all dots -> n_SPR0HIT low exactly on dots 0..2
		flush();
		lane_load(3'd0, 3'd2, 8'b0010_0000);
		lane_load(3'd0, 3'd3, 8'd0);
		lane_load(3'd0, 3'd5, 8'b1110_0000);   // pixels 0,1,2
		lane_load(3'd0, 3'd7, 8'd0);
		lane_load(3'd1, 3'd2, 8'b0010_0001);
		lane_load(3'd1, 3'd3, 8'd0);
		lane_load(3'd1, 3'd5, 8'b1111_1111);
		lane_load(3'd1, 3'd7, 8'b1111_1111);
		Z_HPOS = 1; dot(); Z_HPOS = 0;
		n_VIS = 0;
		expect_visible_dots("sprite0 hit", 9,
			8'h31, 8'h31, 8'h31, 8'h17,
			8'h17, 8'h17, 8'h17, 8'h17, 8'h00);
		n_VIS = 1;

		// ---- 9. PD_FIFO=0 loads zero patterns (empty sprite slot) ----------
		flush();
		lane_load(3'd0, 3'd2, 8'b0010_0011);
		lane_load(3'd0, 3'd3, 8'd0);
		PD_FIFO = 0;
		lane_load(3'd0, 3'd5, 8'b1111_1111);   // blocked -> zeros
		lane_load(3'd0, 3'd7, 8'b1111_1111);
		PD_FIFO = 1;
		Z_HPOS = 1; dot(); Z_HPOS = 0;
		n_VIS = 0;
		expect_visible_dots("PD_FIFO block", 3,
			8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);
		n_VIS = 1;

		// ---- 10. n_OBJ_RD_ATTR pulses on the attribute load -----------------
		// attr phase (code 2) with OBJ_READ -> strobe low on the next dot
		flush();
		OB = 8'b0010_0011;
		set_h(3'd2, 3'd7);     // attr phase, lane 0
		OBJ_READ = 1;
		#1;
		checks = checks + 1;
		if (n_OBJ_RD_ATTR !== 1'b1) begin
			errors = errors + 1;
			$display("FAIL: n_OBJ_RD_ATTR active too early (%b)", n_OBJ_RD_ATTR);
		end
		dot();                 // strobe fires after the dot (delayed)
		checks = checks + 1;
		if (n_OBJ_RD_ATTR !== 1'b0) begin
			errors = errors + 1;
			$display("FAIL: n_OBJ_RD_ATTR did not pulse (got %b)", n_OBJ_RD_ATTR);
		end
		OBJ_READ = 0;
		dot();
		checks = checks + 1;
		if (n_OBJ_RD_ATTR !== 1'b1) begin
			errors = errors + 1;
			$display("FAIL: n_OBJ_RD_ATTR stuck low (%b)", n_OBJ_RD_ATTR);
		end

		if (errors == 0)
			$display("fifo_test: TEST PASS (%0d checks)", checks);
		else
			$display("fifo_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // fifo_test
