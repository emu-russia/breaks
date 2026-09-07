// PPU register file (PpuRegs + RegSelect + SCCXFirstSecond + RegCTRL0/1 +
// RWDecoder + Clipper, all in HDL/PPU/regs.v) self-check against the NES PPU
// register specification and BreakingNESWiki/PPU/regs.md.
//
// Covered behaviour:
//  * RWDecoder: /RD & /WR complements of RnW while /DBE = 0, both inactive
//    (high) while /DBE = 1.
//  * RegSelect: full RS[2:0] x R/W decode of the register read/write pulses
//    ($2000..$2007), including the first/second $2005/$2006 write pulses.
//  * SCCXFirstSecond: after RC or a $2002 read the NEXT $2005/$2006 write is
//    the FIRST one (NES scroll/vram-address write order); the toggle is shared
//    between $2005 and $2006 and flips on every one of those writes; a WRITE
//    to $2002 (or reads of other registers) does not touch it.
//  * RegCTRL0 ($2000): I_1_32 = bit2, OBSEL = ~bit3, BGSEL = ~bit4,
//    O_8_16 = bit5, n_SLAVE = bit6, VBL = bit7 (bits 0/1 of $2000 belong to
//    the scroll NT_Select in scroll_regs.v and are outside PpuRegs).
//  * RegCTRL1 ($2001): BnW = bit0, n_BGCLIP = bit1, n_OBCLIP = bit2,
//    BGE = bit3, OBE = bit4, BLACK = ~(BGE|OBE), n_TR = ~bit5, n_TG = ~bit6,
//    n_TB = ~bit7.  The left-8 background/sprite clipping of the NES takes
//    place while the corresponding bit is 0, hence the direct/inverted outputs.
//  * Registers hold between writes and are cleared by RC; the $2002 read does
//    not clear the control registers.
//  * Clipper: /CLPB (active low, to BGCOL) and CLPO (active high, to Obj FIFO)
//    per the wiki signal table:
//       n_CLPB = ~(n_VIS | CLIP_B | ~BGE)   (n_VIS=1 while not visible)
//       CLPO   =  n_VIS | CLIP_O | ~OBE
//    i.e. background is clipped while visible+CLIP_B (+when BG rendering is
//    off), sprites are clipped while visible+CLIP_O or sprite rendering is off.
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module regs_test ();

	reg RC = 0;
	reg n_DBE = 1;
	reg RnW = 1;
	reg [2:0] RS = 0;
	reg [7:0] Dval = 0;
	wire [7:0] CPU_DB = n_DBE ? 8'bz : Dval;

	wire n_W5_1, n_W5_2, n_W6_1, n_W6_2, n_R7, n_W7, n_W4, n_W3, n_R2, n_W1, n_W0, n_R4;
	wire I_1_32, OBSEL, BGSEL, O_8_16, n_SLAVE, VBL;
	wire BnW, n_BGCLIP, n_OBCLIP, BGE, BLACK, OBE, n_TR, n_TG, n_TB;

	PpuRegs regs (
		.RC(RC), .n_DBE(n_DBE), .RS(RS), .RnW(RnW), .CPU_DB(CPU_DB),
		.n_W5_1(n_W5_1), .n_W5_2(n_W5_2), .n_W6_1(n_W6_1), .n_W6_2(n_W6_2),
		.n_R7(n_R7), .n_W7(n_W7), .n_W4(n_W4), .n_W3(n_W3), .n_R2(n_R2), .n_W1(n_W1), .n_W0(n_W0), .n_R4(n_R4),
		.I_1_32(I_1_32), .OBSEL(OBSEL), .BGSEL(BGSEL), .O_8_16(O_8_16), .n_SLAVE(n_SLAVE), .VBL(VBL),
		.BnW(BnW), .n_BGCLIP(n_BGCLIP), .n_OBCLIP(n_OBCLIP), .BGE(BGE), .BLACK(BLACK), .OBE(OBE),
		.n_TR(n_TR), .n_TG(n_TG), .n_TB(n_TB) );

	wire n_RD, n_WR;
	RWDecoder rwdec (.RnW(RnW), .n_DBE(n_DBE), .n_RD(n_RD), .n_WR(n_WR) );

	reg n_PCLK = 1;
	reg n_VIS, CLIP_B, CLIP_O;
	wire n_CLPB, CLPO;
	Clipper clip (.n_PCLK(n_PCLK), .n_VIS(n_VIS), .CLIP_B(CLIP_B), .CLIP_O(CLIP_O),
		.BGE(BGE), .OBE(OBE), .n_CLPB(n_CLPB), .CLPO(CLPO) );

	integer errors = 0;
	integer checks = 0;

	// ------------------------------------------------------------------
	// helpers
	// ------------------------------------------------------------------

	task expect1;
		input [159:0] what;
		input [1:0] got;
		input [1:0] exp;
		begin
			checks = checks + 1;
			if (got !== exp) begin
				errors = errors + 1;
				$display("FAIL %0s: got %b, expected %b", what, got, exp);
			end
		end
	endtask

	// compare the 13 decode outputs against a 13-bit active set.
	// bit0 nW0, bit1 nW1, bit2 nW3, bit3 nW4, bit4 nW5_1, bit5 nW5_2,
	// bit6 nW6_1, bit7 nW6_2, bit8 nW7, bit9 nR2, bit10 nR4, bit11 nR7,
	// bit12 nW56 (a bit is set when the pulse is ACTIVE, i.e. low)
	task expect_decode;
		input [159:0] what;
		input [12:0] exp;
		begin
			checks = checks + 1;
			if ({regs.n_W56, n_R7, n_R4, n_R2, n_W7, n_W6_2, n_W6_1, n_W5_2, n_W5_1,
			      n_W4, n_W3, n_W1, n_W0} !== exp) begin
				errors = errors + 1;
				$display("FAIL %0s: got %b, expected %b",
					what, {regs.n_W56, n_R7, n_R4, n_R2, n_W7, n_W6_2, n_W6_1, n_W5_2, n_W5_1,
					       n_W4, n_W3, n_W1, n_W0}, exp);
			end
		end
	endtask

	// do one bus cycle (address/control settle first) and check the decode
	task decode_cycle;
		input [159:0] what;
		input [2:0] addr;
		input rw;
		input [12:0] exp;
		begin
			#5;
			RS = addr; RnW = rw; Dval = 8'h00;
			#1;
			n_DBE = 0;
			#5;
			expect_decode(what, exp);
			n_DBE = 1;
			#1;
			RS = 0; RnW = 1;
			#4;
		end
	endtask

	// full CPU write with data (for the control register checks)
	task cpu_write;
		input [2:0] addr;
		input [7:0] data;
		begin
			#5;
			RS = addr; RnW = 0; Dval = data;
			#1;
			n_DBE = 0;
			#10;
			n_DBE = 1;
			#1;
			RS = 0; RnW = 1;
			#5;
		end
	endtask

	task cpu_read_2002;
		begin
			#5;
			RS = 3'd2; RnW = 1;
			#1;
			n_DBE = 0;
			#10;
			n_DBE = 1;
			#1;
			RS = 0;
			#5;
		end
	endtask

	task pulse_rc;
		begin
			RC = 1; #5; RC = 0; #5;
		end
	endtask

	initial begin
		$dumpfile("regs_test.vcd");
		$dumpvars(0, regs_test);

		pulse_rc;

		// ===================== RWDecoder =====================
		// /DBE = 1: neither read nor write
		RnW = 1; n_DBE = 1; #3;
		expect1("RWDecoder idle read", {n_RD, n_WR}, 2'b11);
		RnW = 0; n_DBE = 1; #3;
		expect1("RWDecoder idle write", {n_RD, n_WR}, 2'b11);
		// /DBE = 0 with read
		RnW = 1; n_DBE = 0; #3;
		expect1("RWDecoder read active", {n_RD, n_WR}, 2'b01);
		// /DBE = 0 with write
		RnW = 0; n_DBE = 0; #3;
		expect1("RWDecoder write active", {n_RD, n_WR}, 2'b10);
		n_DBE = 1; RnW = 1; #3;

		// ===================== RegSelect decode =====================
		// non-toggle registers (toggle state irrelevant)
		decode_cycle("$2000 write n_W0", 3'd0, 1'b0, 13'b1111111111110);	// $2000 write -> n_W0
		decode_cycle("$2001 write n_W1", 3'd1, 1'b0, 13'b1111111111101);	// $2001 write -> n_W1
		decode_cycle("$2002 write ignored", 3'd2, 1'b0, 13'b1111111111111);	// $2002 write ignored
		decode_cycle("$2002 read n_R2", 3'd2, 1'b1, 13'b1110111111111);	// $2002 read -> n_R2
		decode_cycle("$2003 write n_W3", 3'd3, 1'b0, 13'b1111111111011);	// $2003 write -> n_W3
		decode_cycle("$2004 write n_W4", 3'd4, 1'b0, 13'b1111111110111);	// $2004 write -> n_W4
		decode_cycle("$2004 read n_R4", 3'd4, 1'b1, 13'b1101111111111);	// $2004 read -> n_R4
		decode_cycle("$2005 read: nothing", 3'd5, 1'b1, 13'b1111111111111);	// $2005 read: nothing
		decode_cycle("$2006 read: nothing", 3'd6, 1'b1, 13'b1111111111111);	// $2006 read: nothing
		decode_cycle("$2007 write n_W7", 3'd7, 1'b0, 13'b1111011111111);	// $2007 write -> n_W7
		decode_cycle("$2007 read n_R7", 3'd7, 1'b1, 13'b1011111111111);	// $2007 read -> n_R7

		// $2005/$2006 toggle behaviour (NES write order: first = X/high byte)
		pulse_rc;
		decode_cycle("1st $2005 n_W5_1 + n_W56", 3'd5, 1'b0, 13'b0111111101111);	// 1st $2005 -> n_W5_1 + n_W56
		decode_cycle("2nd $2005 n_W5_2 + n_W56", 3'd5, 1'b0, 13'b0111111011111);	// 2nd $2005 -> n_W5_2 + n_W56
		decode_cycle("1st $2006 n_W6_1 + n_W56", 3'd6, 1'b0, 13'b0111110111111);	// 1st $2006 -> n_W6_1 + n_W56
		decode_cycle("2nd $2006 n_W6_2 + n_W56", 3'd6, 1'b0, 13'b0111101111111);	// 2nd $2006 -> n_W6_2 + n_W56

		// shared toggle: $2005 then $2006 -> second one is the $2006 second write
		pulse_rc;
		decode_cycle("$2005 first n_W5_1 + n_W56", 3'd5, 1'b0, 13'b0111111101111);	// $2005 first -> n_W5_1 + n_W56
		decode_cycle("$2006 write after $2005 = 2nd", 3'd6, 1'b0, 13'b0111101111111);	// $2006 write after $2005 = 2nd

		// $2002 read resets the toggle to "first"
		decode_cycle("decode", 3'd2, 1'b1, 13'b1110111111111);
		decode_cycle("again the first $2005 write", 3'd5, 1'b0, 13'b0111111101111);	// again the first $2005 write
		// ... and RC resets it as well
		pulse_rc;
		decode_cycle("first $2006 write after RC", 3'd6, 1'b0, 13'b0111110111111);	// first $2006 write after RC

		// $2002 WRITE does not reset the toggle: next $2006 write is the second one
		decode_cycle("$2002 write (ignored)", 3'd2, 1'b0, 13'b1111111111111);	// $2002 write (ignored)
		decode_cycle("still the second write", 3'd6, 1'b0, 13'b0111101111111);	// still the second write

		// internal first/second flip-flop state
		checks = checks + 2;
		if (regs.fs.Frst !== 1'b0 || regs.fs.Scnd !== 1'b1) begin
			errors = errors + 1;
			$display("FAIL toggle after RC: Frst=%b Scnd=%b, expected 0/1", regs.fs.Frst, regs.fs.Scnd);
		end
		decode_cycle("decode", 3'd5, 1'b0, 13'b0111111101111);
		if (regs.fs.Frst !== 1'b1 || regs.fs.Scnd !== 1'b0) begin
			errors = errors + 1;
			$display("FAIL toggle after one write: Frst=%b Scnd=%b, expected 1/0", regs.fs.Frst, regs.fs.Scnd);
		end

		// ===================== $2000 control register =====================
		pulse_rc;
		cpu_write(3'd0, 8'hB5);		// 1011_0101: bits 7,5,4,2,0
		checks = checks + 1;
		if ({VBL, n_SLAVE, O_8_16, BGSEL, OBSEL, I_1_32} !== 6'b10_1_0_1_1) begin
			errors = errors + 1;
			$display("FAIL $2000=0xB5: I_1_32=%b OBSEL=%b BGSEL=%b O_8_16=%b n_SLAVE=%b VBL=%b",
				I_1_32, OBSEL, BGSEL, O_8_16, n_SLAVE, VBL);
		end
		cpu_write(3'd1, 8'hAA);		// $2001 write must not disturb $2000
		cpu_write(3'd3, 8'h00);		// ... nor $2003
		checks = checks + 1;
		if ({VBL, n_SLAVE, O_8_16, BGSEL, OBSEL, I_1_32} !== 6'b10_1_0_1_1) begin
			errors = errors + 1;
			$display("FAIL $2000 holds: got %b%b%b%b%b%b", VBL, n_SLAVE, O_8_16, BGSEL, OBSEL, I_1_32);
		end
		cpu_write(3'd0, 8'h00);		// write zeros
		checks = checks + 1;
		if ({VBL, n_SLAVE, O_8_16, BGSEL, OBSEL, I_1_32} !== 6'b00_0_1_1_0) begin
			errors = errors + 1;
			$display("FAIL $2000=0: got %b%b%b%b%b%b", VBL, n_SLAVE, O_8_16, BGSEL, OBSEL, I_1_32);
		end

		// ===================== $2001 control register =====================
		cpu_write(3'd1, 8'h1E);		// 0001_1110: bits 1..4
		checks = checks + 1;
		if ({BnW, n_BGCLIP, n_OBCLIP, BGE, OBE, BLACK, n_TR, n_TG, n_TB} !==
		    9'b0_1_1_1_1_0_1_1_1) begin
			errors = errors + 1;
			$display("FAIL $2001=0x1E: BnW=%b nBG=%b nOB=%b BGE=%b OBE=%b BLACK=%b nTR=%b nTG=%b nTB=%b",
				BnW, n_BGCLIP, n_OBCLIP, BGE, OBE, BLACK, n_TR, n_TG, n_TB);
		end
		// grayscale + full emphasis: 0xE1 = 1110_0001 -> BnW=1, nTR/nTG/nTB=0
		cpu_write(3'd1, 8'hE1);
		checks = checks + 1;
		if ({BnW, n_BGCLIP, n_OBCLIP, BGE, OBE, BLACK, n_TR, n_TG, n_TB} !==
		    9'b1_0_0_0_0_1_0_0_0) begin
			errors = errors + 1;
			$display("FAIL $2001=0xE1: BnW=%b nBG=%b nOB=%b BGE=%b OBE=%b BLACK=%b nTR=%b nTG=%b nTB=%b",
				BnW, n_BGCLIP, n_OBCLIP, BGE, OBE, BLACK, n_TR, n_TG, n_TB);
		end
		cpu_write(3'd0, 8'hFF);		// $2000 write must not disturb $2001
		checks = checks + 1;
		if ({BnW, n_BGCLIP, n_OBCLIP, BGE, OBE, BLACK, n_TR, n_TG, n_TB} !==
		    9'b1_0_0_0_0_1_0_0_0) begin
			errors = errors + 1;
			$display("FAIL $2001 holds after $2000 write");
		end
		// RC clears both control registers
		pulse_rc;
		checks = checks + 1;
		if ({VBL, n_SLAVE, O_8_16, BGSEL, OBSEL, I_1_32, BnW, n_BGCLIP, n_OBCLIP, BGE, OBE, n_TR, n_TG, n_TB} !==
		    14'b0_0_0_1_1_0_0_0_0_0_0_1_1_1) begin
			errors = errors + 1;
			$display("FAIL after RC: ctrl regs not cleared");
		end
		// a $2002 read does NOT clear the control registers
		cpu_write(3'd1, 8'h1E);
		cpu_read_2002();
		checks = checks + 1;
		if ({n_BGCLIP, n_OBCLIP, BGE, OBE} !== 4'b1111) begin
			errors = errors + 1;
			$display("FAIL $2002 read cleared $2001");
		end

		// ===================== Clipper =====================
		// combinational through the latches while n_PCLK = 1:
		//   n_CLPB = ~(n_VIS | CLIP_B | ~BGE), CLPO = n_VIS | CLIP_O | ~OBE
		// (n_VIS = 1 while the pixel is not visible)
		// first put $2001 into a known state (BG+sprites on, no clip bits)
		cpu_write(3'd1, 8'h18);		// BGE=1, OBE=1
		begin : clip_cases
			integer g;
			for (g = 0; g < 16; g = g + 1) begin
				#2;
				n_VIS = g[3]; CLIP_B = g[2]; CLIP_O = g[1];
				n_PCLK = 1;		// BGE/OBE fixed by $2001 = 0x18
				#3;
				expect1("clipper BGE=OBE=1", {n_CLPB, CLPO},
					{~(n_VIS | CLIP_B | 1'b0), (n_VIS | CLIP_O | 1'b0)});
			end
		end
		cpu_write(3'd1, 8'h00);		// BGE=0, OBE=0 (rendering off)
		#2;
		n_VIS = 0; CLIP_B = 0; CLIP_O = 0;
		n_PCLK = 1; #3;
		expect1("clipper rendering off", {n_CLPB, CLPO},
			{~(1'b0 | 1'b0 | 1'b1), (1'b0 | 1'b0 | 1'b1)});	// /CLPB=0, CLPO=1
		#2;
		n_PCLK = 0;		// outputs hold
		#3;
		expect1("clipper holds while n_PCLK=0", {n_CLPB, CLPO}, 2'b01);

		if (errors == 0)
			$display("regs_test: TEST PASS (%0d checks)", checks);
		else
			$display("regs_test: TEST FAIL (%0d errors)", errors);
		$finish;
	end

endmodule // regs_test
