// CRAM (HDL/PPU/cram.v: CB_Control + CRAM_Decoder + CRAM_Block) self-check.
//
// Documented behaviour (BreakingNESWiki/PPU/cram.md, rails.md, regs.md and the
// Visual 2C02 node map in visual2c02.md):
//
//  * Colour RAM organisation: CGA3,CGA2 select the column (CGA3 msb); the row
//    is CGA4,CGA1,CGA0 (CGA4 msb) and rows 0 and 4 share one word line
//    ("Ряды 0 и 4 совмещены"). During PCLK=1 the array precharges: no row is
//    selected.  CRAM_Decoder must assert exactly the matching ROW line.
//
//  * CPU interface: #CB/DB = "0: CB -> DB" only while reading $2007 with the
//    palette address on the mux (n_R7=0, n_DBE=0, TH_MUX=1 -> n_CB_DB=0, and
//    CPU_DB = {00, cram[CGA]}).  The DB->CB->CRAM capture happens only when
//    n_DB_CB=0 && n_DBE=0 at a PCLK rising edge (write $2007 to the palette).
//
//  * Pixel outputs (inverted): n_LL = ~cram[CGA][5:4] is always driven (the
//    luma transistor is permanently open).  n_CC = ~cram[CGA][3:0] while the
//    chip node "/BW" lets chroma through, i.e. while drawing or outputting a
//    palette read AND color mode ($2001[0]=0, BnW=0); in monochrome mode
//    (BnW=1) or outside the picture the chroma is forced to 0000 (n_CC=1111),
//    which is rendered as a gray shade by luma only.
//
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module cram_test ();

	reg PCLK;
	reg n_PCLK;
	reg clk_en = 1'b1;
	always #25 if (clk_en) begin PCLK = ~PCLK; n_PCLK = ~PCLK; end

	// ---- CRAM_Decoder DUT ----
	reg [4:0] CGA;
	wire COL2, COL3, COL0, COL1;
	wire ROW0_4, ROW1, ROW2, ROW3, ROW5, ROW6, ROW7;

	CRAM_Decoder dec (
		.PCLK(PCLK), .CGA(CGA),
		.COL2(COL2), .COL3(COL3), .COL0(COL0), .COL1(COL1),
		.ROW0_4(ROW0_4), .ROW1(ROW1), .ROW2(ROW2), .ROW3(ROW3),
		.ROW5(ROW5), .ROW6(ROW6), .ROW7(ROW7) );

	// ---- CB_Control DUT ----
	reg n_DBE;
	reg TH_MUX;
	reg DB_PAR;
	reg n_PICTURE;
	reg BnW;
	reg n_R7;
	wire n_BW, n_CB_DB, n_DB_CB;

	CB_Control cbctl (
		.n_DBE(n_DBE), .TH_MUX(TH_MUX), .DB_PAR(DB_PAR), .n_PICTURE(n_PICTURE),
		.BnW(BnW), .PCLK(PCLK), .n_R7(n_R7),
		.n_BW(n_BW), .n_CB_DB(n_CB_DB), .n_DB_CB(n_DB_CB) );

	// ---- CRAM_Block DUT ----
	reg [7:0] db_val;
	reg db_drv;
	wire [7:0] CPU_DB = db_drv ? db_val : 8'bz;
	wire [3:0] n_CC;
	wire [1:0] n_LL;

	CRAM_Block cram (
		.n_PCLK(n_PCLK), .PCLK(PCLK),
		.n_R7(n_R7), .n_DBE(n_DBE), .TH_MUX(TH_MUX), .DB_PAR(DB_PAR),
		.n_PICTURE(n_PICTURE), .BnW(BnW),
		.CGA(CGA), .CPU_DB(CPU_DB), .n_CC(n_CC), .n_LL(n_LL) );

	integer errors = 0;
	integer checks = 0;
	integer addr;
	reg [5:0] stored;
	reg [3:0] expcc;
	reg [1:0] expll;

	// test pattern stored at palette address `a`: (a*5+9) & 0x3F
	function automatic [5:0] pal_value(input integer a);
		begin
			pal_value = (a[4:0] * 5 + 9) & 6'h3F;
		end
	endfunction

	// ----- helpers --------------------------------------------------------

	// CPU write of $2007 into the palette: while PCLK is running with
	// TH_MUX=1/DB_PAR=1 (so the CB control latch holds DB_PAR=1 and n_DB_CB=0)
	// arm n_DBE=0 at the low phase and capture on the next PCLK rising edge.
	task cram_write(input [4:0] a, input [7:0] data);
		begin
			n_DBE = 1'b1; n_R7 = 1'b1; TH_MUX = 1'b1; DB_PAR = 1'b1;
			@(posedge PCLK); #1;          // refresh the DB_PAR latch (w3=1)
			@(negedge PCLK);
			CGA = a;
			db_drv = 1; db_val = data;
			n_DBE = 1'b0;                 // armed, no race: set in the low phase
			@(posedge PCLK); #1;          // capture edge
			n_DBE = 1'b1; db_drv = 0;     // release
			@(negedge PCLK);
		end
	endtask

	// CPU read of $2007 with a palette address: freeze the DB_PAR latch at 0
	// (n_DB_CB=1 -> no capture while n_DBE is low), then enable CB->DB.
	task cram_read(input [4:0] a, input [7:0] exp);
		begin
			n_DBE = 1'b1; n_R7 = 1'b1; TH_MUX = 1'b1; DB_PAR = 1'b0;
			@(posedge PCLK); #1;          // latch DB_PAR=0 (w3=0)
			@(negedge PCLK);
			CGA = a;
			db_drv = 0;
			n_R7 = 1'b0; n_DBE = 1'b0;    // enable CB -> DB
			#1;
			checks = checks + 1;
			if (CPU_DB !== exp) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL read %0s: addr=%02x CPU_DB=%02x, exp %02x", "2007", a, CPU_DB, exp);
			end
			n_R7 = 1'b1; n_DBE = 1'b1;
			#1;
			checks = checks + 1;
			if (CPU_DB !== 8'bz) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL read disabled: CPU_DB=%02x, exp z", CPU_DB);
			end
		end
	endtask

	// Sample n_CC/n_LL in a fixed pixel scenario.
	task check_pix(input [159:0] what, input [4:0] a, input [3:0] ec, input [1:0] el);
		begin
			CGA = a;
			#1;
			checks = checks + 1;
			if (n_CC !== ec) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL %0s: addr=%02x n_CC=%b, exp %b", what, a, n_CC, ec);
			end
			checks = checks + 1;
			if (n_LL !== el) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL %0s: addr=%02x n_LL=%b, exp %b", what, a, n_LL, el);
			end
		end
	endtask

	initial begin
		$dumpfile("cram_test.vcd");
		$dumpvars(0, cram_test);

		PCLK = 1'b0; n_PCLK = 1'b1;
		n_DBE = 1; TH_MUX = 0; DB_PAR = 0; n_PICTURE = 0; BnW = 0; n_R7 = 1;
		CGA = 0; db_drv = 0; db_val = 0;
		repeat (2) @(posedge PCLK);

		// ---- 1) CRAM_Decoder decode ----------------------------------------
		// Per cram.md the column select value is {CGA3(msb), CGA2} and the row
		// select value is {CGA4(msb), CGA1, CGA0}; physical rows 0 and 4 share
		// one word line (ROW0_4), so row values 000 and 100 both assert it.
		// During PCLK=1 the array precharges: no row line is asserted.
		clk_en = 0;
		PCLK = 1'b0; n_PCLK = 1'b1;   // access phase
		for (addr = 0; addr < 32; addr = addr + 1) begin
			CGA = addr[4:0];
			#1;
			// exactly the addressed column asserts
			checks = checks + 1;
			begin : colcheck
				reg [1:0] colsel;
				colsel = {CGA[3], CGA[2]};
				if (COL0 !== (colsel == 2'd0) || COL1 !== (colsel == 2'd1) ||
				    COL2 !== (colsel == 2'd2) || COL3 !== (colsel == 2'd3)) begin
					errors = errors + 1;
					if (errors <= 20) $display("FAIL col decode CGA=%02x COL=%b%b%b%b", CGA, COL3, COL2, COL1, COL0);
				end
			end
			checks = checks + 1;
			if (COL0 + COL1 + COL2 + COL3 != 1) begin
				errors = errors + 1;
				if (errors <= 20) $display("FAIL col decode not 1-of-4 CGA=%02x", CGA);
			end
			// exactly the addressed (merged) row asserts
			checks = checks + 1;
			case ({CGA[4], CGA[1], CGA[0]})
				3'b000, 3'b100: if (ROW0_4 !== 1'b1) begin errors = errors + 1; if (errors<=20) $display("FAIL row 0/4 CGA=%02x", CGA); end
				3'b001: if (ROW1 !== 1'b1) begin errors = errors + 1; if (errors<=20) $display("FAIL row1 CGA=%02x", CGA); end
				3'b010: if (ROW2 !== 1'b1) begin errors = errors + 1; if (errors<=20) $display("FAIL row2 CGA=%02x", CGA); end
				3'b011: if (ROW3 !== 1'b1) begin errors = errors + 1; if (errors<=20) $display("FAIL row3 CGA=%02x", CGA); end
				3'b101: if (ROW5 !== 1'b1) begin errors = errors + 1; if (errors<=20) $display("FAIL row5 CGA=%02x", CGA); end
				3'b110: if (ROW6 !== 1'b1) begin errors = errors + 1; if (errors<=20) $display("FAIL row6 CGA=%02x", CGA); end
				3'b111: if (ROW7 !== 1'b1) begin errors = errors + 1; if (errors<=20) $display("FAIL row7 CGA=%02x", CGA); end
			endcase
			// no other ROW line may be active (column bits must not matter)
			checks = checks + 1;
			if (ROW0_4 + ROW1 + ROW2 + ROW3 + ROW5 + ROW6 + ROW7 != 1) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL row decode not 1-of-N CGA=%02x r0=%b r1=%b r2=%b r3=%b r5=%b r6=%b r7=%b",
						CGA, ROW0_4, ROW1, ROW2, ROW3, ROW5, ROW6, ROW7);
			end
		end
		PCLK = 1'b1; n_PCLK = 1'b0;   // precharge phase: all rows off
		for (addr = 0; addr < 32; addr = addr + 1) begin
			CGA = addr[4:0];
			#1;
			checks = checks + 1;
			if (ROW0_4 | ROW1 | ROW2 | ROW3 | ROW5 | ROW6 | ROW7) begin
				errors = errors + 1;
				if (errors <= 20) $display("FAIL row active during PCLK=1 CGA=%02x", CGA);
			end
			checks = checks + 1;
			if (COL0 === 1'bx || COL1 === 1'bx || COL2 === 1'bx || COL3 === 1'bx ||
			    COL0 === 1'bz || COL1 === 1'bz || COL2 === 1'bz || COL3 === 1'bz) begin
				errors = errors + 1;
				if (errors <= 20) $display("FAIL COL not driven CGA=%02x", CGA);
			end
		end
		clk_en = 1;

		// ---- 2) CB_Control: CB->DB decode ($2007 read, palette range) -----
		// sweep the read decode; expect n_CB_DB=0 only on the palette $2007
		// read (n_R7=0 && n_DBE=0 && TH_MUX=1).
		begin : cbctl_sweep
			integer rr, dd, tt, x;
			for (x = 0; x < 4; x = x + 1) begin
				rr = x[1]; dd = x[0];
				for (tt = 0; tt < 2; tt = tt + 1) begin
					n_R7 = rr; n_DBE = dd; TH_MUX = tt; DB_PAR = 0;
					#1;
					checks = checks + 1;
					if (n_CB_DB !== ~( (rr == 0) && (dd == 0) && (tt == 1) )) begin
						errors = errors + 1;
						if (errors <= 20)
							$display("FAIL n_CB_DB decode n_R7=%b n_DBE=%b TH_MUX=%b got=%b", rr, dd, tt, n_CB_DB);
					end
				end
			end
		end
		n_R7 = 1; n_DBE = 1; TH_MUX = 0;

		// ---- 3) CRAM_Block round trips over the whole 32-entry palette -----
		// stored per address: (addr*5 + 9) & 0x3F, only 6 bits are kept.
		for (addr = 0; addr < 32; addr = addr + 1) begin
			cram_write(addr[4:0], pal_value(addr));
		end
		for (addr = 0; addr < 32; addr = addr + 1) begin
			cram_read(addr[4:0], {2'b00, pal_value(addr)});
		end

		// ---- 4) Pixel outputs ---------------------------------------------
		// (a) colour mode drawing a pixel (n_PICTURE=0: draw range, BnW=0):
		//     chroma and luma of the addressed palette entry are output
		//     inverted.  n_R7/n_DBE high (no CPU bus cycle in progress).
		clk_en = 0; PCLK = 1'b0; n_PCLK = 1'b1;
		n_R7 = 1'b1; n_DBE = 1'b1; TH_MUX = 1'b1; DB_PAR = 1'b1;
		n_PICTURE = 1'b0; BnW = 1'b0;
		for (addr = 0; addr < 32; addr = addr + 1) begin
			stored = pal_value(addr);
			expcc = ~stored[3:0];
			expll = ~stored[5:4];
			check_pix("color draw", addr[4:0], expcc, expll);
		end

		// (b) monochrome mode (BnW=1): chroma is suppressed (n_CC=1111),
		//     luma still passes (the B/W transistor only gates the chroma bits).
		BnW = 1'b1;
		for (addr = 0; addr < 32; addr = addr + 1) begin
			stored = pal_value(addr);
			expll = ~stored[5:4];
			check_pix("mono draw", addr[4:0], 4'b1111, expll);
		end

		// (c) outside the picture (n_PICTURE=1) nothing is drawn: chroma off,
		//     luma still follows the entry (harmless, video is blanked anyway).
		BnW = 1'b0; n_PICTURE = 1'b1;
		for (addr = 0; addr < 32; addr = addr + 1) begin
			stored = pal_value(addr);
			expll = ~stored[5:4];
			check_pix("blank", addr[4:0], 4'b1111, expll);
		end
		clk_en = 1;

		// ---- 5) Capture data path details ---------------------------------
		// DB bits 7:6 are not part of the palette: they must be discarded.
		cram_write(5'd3, 8'b11_100101);
		cram_read(5'd3, 8'b00_100101);

		// no capture while n_DBE=1
		n_DBE = 1'b1; n_R7 = 1'b1; TH_MUX = 1'b1; DB_PAR = 1'b1;
		@(posedge PCLK); #1;
		@(negedge PCLK);
		CGA = 5'd3; db_drv = 1; db_val = 8'h00;
		n_DBE = 1'b1;                    // strobe high: nothing to capture
		@(posedge PCLK); #1;
		db_drv = 0;
		@(negedge PCLK);
		cram_read(5'd3, 8'b00_100101);   // unchanged

		if (errors == 0)
			$display("cram_test: TEST PASS (%0d checks)", checks);
		else
			$display("cram_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // cram_test
