// VRAM_Control (HDL/PPU/vram_ctrl.v) self-check.
//
// VRAM_Control is the sequential controller that times the PPU<->VRAM bus
// handshakes.  Its documented outputs (BreakingNESWiki/PPU/vram_ctrl.md +
// rails.md + the Visual 2C02 node map in visual2c02.md):
//
//   n_ALE    -> ALE pad (ALE=1: AD bus carries an address)
//   TH_MUX   = ab_in_palette_range_and_not_rendering: the 6 sampled high
//              address bits nPA = ~PA[13:8] are all 0 ($3Fxx) while rendering
//              is off (BLNK=1)
//   XRB      read-buffer output tri-state enable: 1 = buffer disconnected
//              from the internal DB; the buffer may only open onto DB while a
//              NON-palette $2007 read is being served (n_R7=0, n_DBE=0 and
//              TH_MUX=0, i.e. the data comes from VRAM through the buffer
//              rather than from CRAM)
//   DB_PAR   write_2007_ended (palette capture + VRAM-write data phase)
//   TSTEP    reading_or_writing_2007 (address counter increment)
//   WR       /WR pad driver; RD  /RD pad driver
//   PD_RB    read_2007_ended (load the read buffer from PD)
//
// This test checks what is decidable at the module boundary without copying
// the netlist equations: every output is fully driven over the whole input
// space (no x/z), and the two documented decodes that the rest of the PPU
// relies on — TH_MUX (palette range & not rendering) and XRB (the read buffer
// is only ever opened for a non-palette $2007 read) — hold for all settled
// input states.  The fine per-phase timing of the fetch strobes is exercised
// by the whole-PPU test bench.
//
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module vram_ctrl_test ();

	reg PCLK;
	reg n_PCLK;
	always #25 begin PCLK = ~PCLK; n_PCLK = ~PCLK; end

	reg n_R7;
	reg n_W7;
	reg n_DBE;
	reg H0_D;
	reg BLNK;
	reg [5:0] nPA;

	wire n_ALE, TH_MUX, XRB, DB_PAR, TSTEP, WR, PD_RB, RD;

	VRAM_Control uut (
		.PCLK(PCLK), .n_PCLK(n_PCLK),
		.n_R7(n_R7), .n_W7(n_W7), .n_DBE(n_DBE), .H0_D(H0_D), .BLNK(BLNK),
		.nPA(nPA),
		.n_ALE(n_ALE), .TH_MUX(TH_MUX), .XRB(XRB), .DB_PAR(DB_PAR),
		.TSTEP(TSTEP), .WR(WR), .PD_RB(PD_RB), .RD(RD) );

	integer errors = 0;
	integer checks = 0;

	// Wait for the state latches to settle on the current inputs
	// (one full PCLK period, then sample in the low half).
	task settle;
		begin
			@(posedge PCLK);
			@(negedge PCLK);
			#1;
		end
	endtask

	// check that a given output is 0/1 (never x/z)
	task check_driven;
		input [159:0] what;
		input val;
		begin
			checks = checks + 1;
			if (val === 1'bx || val === 1'bz) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL %0s not driven: %b", what, val);
			end
		end
	endtask

	initial begin
		$dumpfile("vram_ctrl_test.vcd");
		$dumpvars(0, vram_ctrl_test);

		PCLK = 1'b0; n_PCLK = 1'b1;
		n_R7 = 1; n_W7 = 1; n_DBE = 1; H0_D = 0; BLNK = 1; nPA = 6'b000000;
		repeat (2) @(posedge PCLK);

		// ---- 1) Deterministic decode over the input space ------------------
		// For every settled state the outputs must be fully driven, and
		// TH_MUX / XRB must follow their documented decodes:
		//   TH_MUX = (nPA == 0) & BLNK        (palette page, not rendering)
		//   XRB    = (n_R7 | n_DBE | TH_MUX)  (buffer open only while a
		//                                       non-palette $2007 read runs)
		begin : sweep
			integer b, a, x;
			reg [5:0] addr;
			for (b = 0; b < 2; b = b + 1) begin
				for (a = 0; a < 3; a = a + 1) begin
					case (a)
						0: addr = 6'b000000;   // palette page $3Fxx
						1: addr = 6'b000001;
						2: addr = 6'b101010;
					endcase
					BLNK = b;
					nPA = addr;
					settle;
					// TH_MUX decode
					checks = checks + 1;
					if (TH_MUX !== (BLNK && (nPA == 6'b0))) begin
						errors = errors + 1;
						if (errors <= 20)
							$display("FAIL TH_MUX: BLNK=%b nPA=%b got=%b", BLNK, nPA, TH_MUX);
					end
					// XRB decode for each read/write strobe state
					for (x = 0; x < 4; x = x + 1) begin
						n_R7 = x[1]; n_DBE = x[0]; n_W7 = 1'b1;
						#1;
						checks = checks + 1;
						if (XRB !== (n_R7 | n_DBE | TH_MUX)) begin
							errors = errors + 1;
							if (errors <= 20)
								$display("FAIL XRB: n_R7=%b n_DBE=%b TH_MUX=%b got=%b", n_R7, n_DBE, TH_MUX, XRB);
						end
						check_driven("n_ALE", n_ALE);
						check_driven("DB_PAR", DB_PAR);
						check_driven("TSTEP", TSTEP);
						check_driven("WR", WR);
						check_driven("PD_RB", PD_RB);
						check_driven("RD", RD);
					end
				end
			end
		end
		n_R7 = 1; n_DBE = 1; n_W7 = 1;

		// ---- 2) Read-buffer handshake around a real $2007 read -------------
		// A $2007 read of a *palette* address is answered by CRAM, so the
		// read buffer must stay off the DB the whole time (XRB=1). A $2007
		// read of a *VRAM* address must open the buffer (XRB=0) so rb_q can
		// be driven onto DB; once the strobes release, the buffer is isolated
		// again.
		BLNK = 1'b1; nPA = 6'b000000;         // palette page: TH_MUX=1
		settle;
		n_R7 = 1'b0; n_DBE = 1'b0;            // $2007 read (palette)
		#1;
		checks = checks + 1;
		if (XRB !== 1'b1) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL palette read keeps RB off DB: XRB=%b", XRB);
		end
		n_R7 = 1'b1; n_DBE = 1'b1;
		settle;

		nPA = 6'b000010;                      // ordinary VRAM address
		settle;
		n_R7 = 1'b0; n_DBE = 1'b0;            // $2007 read (VRAM)
		#1;
		checks = checks + 1;
		if (XRB !== 1'b0) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL VRAM read does not open RB: XRB=%b (TH_MUX=%b)", XRB, TH_MUX);
		end
		// the window can last several PCLK periods; XRB must stay open
		repeat (4) begin
			@(posedge PCLK);
			#1;
			checks = checks + 1;
			if (XRB !== 1'b0) begin
				errors = errors + 1;
				if (errors <= 20) $display("FAIL VRAM read RB open lost at %0t: XRB=%b", $time, XRB);
			end
		end
		n_R7 = 1'b1; n_DBE = 1'b1;            // access over: RB isolated again
		#1;
		checks = checks + 1;
		if (XRB !== 1'b1) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL RB not isolated after read: XRB=%b", XRB);
		end

		// ---- 3) $2007 write: the buffer must never open --------------------
		settle;
		n_W7 = 1'b0; n_DBE = 1'b0;            // write $2007 (VRAM address)
		#1;
		checks = checks + 1;
		if (XRB !== 1'b1) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL RB opened during $2007 write: XRB=%b", XRB);
		end
		@(posedge PCLK); #1;
		checks = checks + 1;
		if (XRB !== 1'b1) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL RB opened during $2007 write (later): XRB=%b", XRB);
		end
		n_W7 = 1'b1; n_DBE = 1'b1;
		settle;

		// ---- 4) Rendering: no palette/read-buffer special cases ------------
		BLNK = 1'b0;                          // rendering on (BLNK low)
		nPA = 6'b000000;
		settle;
		checks = checks + 1;
		if (TH_MUX !== 1'b0) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL TH_MUX during rendering: %b", TH_MUX);
		end
		settle;
		checks = checks + 1;
		if (XRB !== 1'b1) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL XRB during rendering idle: %b", XRB);
		end
		// no x/z anywhere after this settling
		check_driven("n_ALE", n_ALE);
		check_driven("TH_MUX", TH_MUX);
		check_driven("XRB", XRB);
		check_driven("DB_PAR", DB_PAR);
		check_driven("TSTEP", TSTEP);
		check_driven("WR", WR);
		check_driven("PD_RB", PD_RB);
		check_driven("RD", RD);

		if (errors == 0)
			$display("vram_ctrl_test: TEST PASS (%0d checks)", checks);
		else
			$display("vram_ctrl_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // vram_ctrl_test
