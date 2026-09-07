// Scroll registers (ScrollRegs + the $2005/$2006 write toggle in PpuRegs)
// self-check against the NES PPU scroll spec and BreakingNESWiki/PPU/scroll_regs.md.
//
// The scroll register file stores the loopy "t" fields:
//   FH  = fine X (x register), not part of t
//   TH  = t[4:0]   coarse X
//   TV  = t[9:5]   coarse Y
//   NTH = t[10]    nametable select (horizontal)
//   NTV = t[11]    nametable select (vertical)
//   FV  = t[14:12] fine Y (bit 2 forced 0 by $2006 first writes)
// The reconstructed VRAM address is
//   v = (FV << 12) | (NTV << 11) | (NTH << 10) | (TV << 5) | TH
// (e.g. $2006 $3F/$00 -> 0x3F00, $21/$14 -> 0x2114).
//
// Write sources per the wiki tables:
//   FH  <- first  $2005  DB[2:0]
//   TH  <- first  $2005  DB[7:3]   or second $2006 DB[4:0]
//   FV  <- second $2005  DB[2:0]   or first  $2006 {DB4,DB5,0}
//   TV  <- second $2005  DB[7:3]   or first  $2006 DB[0:1] (TV[4:3])
//                                 or second $2006 DB[7:5] (TV[2:0])
//   NT  <- $2000 DB[0:1]           or first  $2006 DB[2:3]
//
// Part 1 drives the n_W* register pulses directly (tests the ScrollRegs decode
// exactly as documented).  Part 2 drives real CPU bus cycles through PpuRegs
// and checks the NES write-toggle semantics: after RC or a $2002 read the next
// $2005 write is the X scroll and the next $2006 write is the high byte; the
// toggle is shared between $2005/$2006.
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module scroll_regs_test ();

	reg RC = 0;
	reg n_DBE = 1;
	reg RnW = 1;
	reg [2:0] RS = 0;
	reg [7:0] Dval = 0;
	wire [7:0] CPU_DB = n_DBE ? 8'bz : Dval;

	wire n_W5_1, n_W5_2, n_W6_1, n_W6_2, n_R7, n_W7, n_W4, n_W3, n_R2, n_W1, n_W0, n_R4;

	wire [4:0] TV, TH;
	wire [2:0] FH, FV;
	wire NTH, NTV;
	wire W6_2_Ena;

	// Part 1 drives the ScrollRegs pulses directly (bypassing PpuRegs):
	// `direct` = 1 selects the locally forced pulse values.
	reg direct = 0;
	reg nW0_d = 1, nW51_d = 1, nW52_d = 1, nW61_d = 1, nW62_d = 1;
	wire p_W0  = direct ? nW0_d  : n_W0;
	wire p_W5_1 = direct ? nW51_d : n_W5_1;
	wire p_W5_2 = direct ? nW52_d : n_W5_2;
	wire p_W6_1 = direct ? nW61_d : n_W6_1;
	wire p_W6_2 = direct ? nW62_d : n_W6_2;

	PpuRegs regs (
		.RC(RC), .n_DBE(n_DBE), .RS(RS), .RnW(RnW), .CPU_DB(CPU_DB),
		.n_W5_1(n_W5_1), .n_W5_2(n_W5_2), .n_W6_1(n_W6_1), .n_W6_2(n_W6_2),
		.n_R7(n_R7), .n_W7(n_W7), .n_W4(n_W4), .n_W3(n_W3), .n_R2(n_R2), .n_W1(n_W1), .n_W0(n_W0), .n_R4(n_R4),
		.I_1_32(), .OBSEL(), .BGSEL(), .O_8_16(), .n_SLAVE(), .VBL(),
		.BnW(), .n_BGCLIP(), .n_OBCLIP(), .BGE(), .BLACK(), .OBE(),
		.n_TR(), .n_TG(), .n_TB() );

	ScrollRegs scc (
		.TV(TV), .TH(TH), .W6_2_Ena(W6_2_Ena),
		.n_W6_1(p_W6_1), .n_W6_2(p_W6_2), .n_DBE(n_DBE), .RC(RC),
		.n_W0(p_W0), .n_W5_1(p_W5_1), .n_W5_2(p_W5_2), .CPU_DB(CPU_DB),
		.FH(FH), .FV(FV), .NTH(NTH), .NTV(NTV) );

	integer errors = 0;
	integer checks = 0;

	// Compare the reconstructed VRAM address + fine X against the expectation.
	// The 15-bit t layout is {FV[2:0], NTV, NTH, TV[4:0], TH[4:0]}.
	task check_v;
		input [159:0] what;
		input [14:0] exp_v;
		input [2:0] exp_FH;
		begin
			checks = checks + 1;
			if ({FV, NTV, NTH, TV, TH} !== exp_v || FH !== exp_FH) begin
				errors = errors + 1;
				$display("FAIL %0s: v=%05x (FH=%0d FV=%0d TH=%0d TV=%0d NTH=%b NTV=%b), expected v=%05x FH=%0d",
					what, {FV, NTV, NTH, TV, TH}, FH, FV, TH, TV, NTH, NTV,
					exp_v, exp_FH);
			end
		end
	endtask

	// CPU bus write to PPU register `addr` (0..7 = $2000..$2007) with value `data`
	task cpu_write;
		input [2:0] addr;
		input [7:0] data;
		begin
			#5;
			RS = addr; RnW = 0; Dval = data;
			#1;					// RS/RnW/data settle before the bus is enabled
			n_DBE = 0;
			#10;
			n_DBE = 1;
			#1;
			RS = 0; RnW = 1;	// release the register select after the cycle
			#4;
		end
	endtask

	// CPU bus read of $2002 (clears the write toggle inside PpuRegs)
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
			#4;
		end
	endtask

	// Direct single-cycle assertion of one register pulse on the n_W* inputs.
	// which bit 0..4 = n_W0 / n_W5_1 / n_W5_2 / n_W6_1 / n_W6_2 (1 = asserted).
	task direct_cycle;
		input [7:0] which;
		input [7:0] data;
		begin
			#5;
			nW0_d = 1; nW51_d = 1; nW52_d = 1; nW61_d = 1; nW62_d = 1;
			if (which[0]) nW0_d = 0;
			if (which[1]) nW51_d = 0;
			if (which[2]) nW52_d = 0;
			if (which[3]) nW61_d = 0;
			if (which[4]) nW62_d = 0;
			direct = 1;
			Dval = data;
			#1;					// pulses settle before the bus is enabled
			n_DBE = 0;
			#10;
			n_DBE = 1;
			#1;
			direct = 0;
			nW0_d = 1; nW51_d = 1; nW52_d = 1; nW61_d = 1; nW62_d = 1;
			#4;
		end
	endtask

	task pulse_rc;
		begin
			RC = 1; #5; RC = 0; #5;
		end
	endtask

	initial begin
		$dumpfile("scroll_regs_test.vcd");
		$dumpvars(0, scroll_regs_test);

		#5; pulse_rc;
		check_v("reset clears all", 15'h0000, 3'd0);

		// ============ PART 1: direct pulse decode (wiki tables) ============
		// first $2005 write 0xB7: fine-X = 111, coarse-X = 10110 (22)
		direct_cycle(8'b00000010, 8'hB7);
		check_v("first $2005 (X) -> FH/TH", 15'd22, 3'd7);
		// second $2005 write 0x4E: fine-Y = 110 (6), coarse-Y = 01001 (9)
		direct_cycle(8'b00000100, 8'h4E);
		check_v("second $2005 (Y) -> FV/TV", (6 << 12) | (9 << 5) | 22, 3'd7);
		// $2000 write touches only the nametable bits (0x03 -> NTH, NTV)
		direct_cycle(8'b00000001, 8'h03);
		check_v("$2000 NT bits", (6 << 12) | (1 << 11) | (1 << 10) | (9 << 5) | 22, 3'd7);
		direct_cycle(8'b00000001, 8'h00);
		check_v("$2000=0 clears NT", (6 << 12) | (9 << 5) | 22, 3'd7);
		// first $2006 (high byte) 0x2F: FV = {0,d5,d4} = {0,1,0} = 2, NT = {d3,d2} = {1,1},
		// TV[3] <- d0 = 1, TV[4] <- d1 = 1
		direct_cycle(8'b00001000, 8'h2F);
		check_v("first $2006 high 0x2F", (2 << 12) | (1 << 11) | (1 << 10) | (25 << 5) | 22, 3'd7);
		// second $2006 (low byte) 0x63: TH <- 0x03, TV[2:0] <- 0b011 -> TV = 0b11011 = 27
		direct_cycle(8'b00010000, 8'h63);
		check_v("second $2006 low 0x63", (2 << 12) | (1 << 11) | (1 << 10) | (27 << 5) | 3, 3'd7);
		// FV bit 2 forced 0 by a $2006 first write even when a $2005 Y write set it
		pulse_rc;
		direct_cycle(8'b00000100, 8'hC4);	// Y = 0xC4: FV = 4 (bit2=1), TV = 24
		check_v("Y=0xC4 sets FV=4", {3'd4, 1'b0, 1'b0, 5'd24, 5'd0}, 3'd0);
		direct_cycle(8'b00001000, 8'h30);	// first $2006 0x30: FV = {0,1,1} = 3 -> bit2 cleared
		check_v("first $2006 clears FV bit2", {3'd3, 1'b0, 1'b0, 5'd0, 5'd0}, 3'd0);

		// ============ PART 2: end-to-end bus order (NES scroll spec) ============
		pulse_rc;
		check_v("RC clears again", 15'h0000, 3'd0);

		// After RC the first $2005 write must be the X scroll
		cpu_write(3'd5, 8'hA7);		// X: fine 7, coarse 0xA7>>3 = 20
		check_v("post-RC first $2005 is X", 5'd20, 3'd7);
		cpu_write(3'd5, 8'h96);		// Y: fine 6, coarse 0x96>>3 = 18
		check_v("second $2005 is Y", {3'd6, 1'b0, 1'b0, 5'd18, 5'd20}, 3'd7);

		// $2002 read resets the toggle: next $2006 write is the high byte
		cpu_read_2002();
		cpu_write(3'd6, 8'h21);		// high byte: FV = {0,1,0} = 2, TV[3] <- 1
		check_v("post-$2002 first $2006 is high byte", {3'd2, 1'b0, 1'b0, 5'd10, 5'd20}, 3'd7);
		cpu_write(3'd6, 8'h14);		// low byte: TH <- 0x14 = 20, TV[2:0] <- 0
		check_v("second $2006 is low byte -> v=$2114", {3'd2, 1'b0, 1'b0, 5'd8, 5'd20}, 3'd7);

		// Cross-register toggle: a $2006 write right after a $2005 write is the
		// SECOND write (low byte); the toggle remembers only the order.
		pulse_rc;
		cpu_write(3'd5, 8'hE3);		// X: fine 3, coarse 28
		check_v("X first", 5'd28, 3'd3);
		cpu_write(3'd6, 8'h9C);		// treated as $2006 low byte: TH <- 0x1C = 28, TV[2:0] <- 4
		check_v("$2005 then $2006 acts as low byte", {3'd0, 1'b0, 1'b0, 5'd4, 5'd28}, 3'd3);
		cpu_write(3'd6, 8'h2A);		// high byte 0x2A = 0b0101010: FV=2, NTV(d3)=1,
							// NTH(d2)=0, TV[4](d1)=1 -> TV = 0b10100 = 20
		check_v("next $2006 is high byte", {3'd2, 1'b1, 1'b0, 5'd20, 5'd28}, 3'd3);

		// RC resets the toggle order as well
		pulse_rc;
		cpu_write(3'd6, 8'h11);		// first write after RC = high byte: FV <- 1, TV[3] <- 1
		check_v("post-RC first $2006 is high byte", {3'd1, 1'b0, 1'b0, 5'd8, 5'd0}, 3'd0);

		// $2000 nametable select bits via the CPU bus
		cpu_write(3'd0, 8'h02);		// NTV = bit1
		check_v("$2000=0x02 sets NTV", {3'd1, 1'b1, 1'b0, 5'd8, 5'd0}, 3'd0);
		cpu_write(3'd1, 8'hFF);		// $2001 write must not disturb scroll regs
		check_v("$2001 write does not disturb scroll", {3'd1, 1'b1, 1'b0, 5'd8, 5'd0}, 3'd0);

		// Other register traffic keeps the scroll values intact
		cpu_write(3'd4, 8'h55);		// $2004
		cpu_write(3'd7, 8'hAA);		// $2007 write
		cpu_read_2002();
		check_v("other traffic does not disturb", {3'd1, 1'b1, 1'b0, 5'd8, 5'd0}, 3'd0);

		if (errors == 0)
			$display("scroll_regs_test: TEST PASS (%0d checks)", checks);
		else
			$display("scroll_regs_test: TEST FAIL (%0d errors)", errors);
		$finish;
	end

endmodule // scroll_regs_test
