// Regs (X/Y/S) self-check:
//  - The register contents can be watched on the debug outputs y/x/s.
//  - X/Y: while SB_Y / SB_X is asserted the register follows the SB bus
//    (transparent), otherwise it holds; Y_SB / X_SB put the register value
//    onto SB (direct polarity, as observed in the netlist).
// S uses the master/slave pair (S_dbg comes from the output slave latch) and
// is only checked for its initial state here.
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module regs_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	// Internal buses are dynamic NMOS (precharge-hold): tri1 keeps
	// undriven bits at 1 instead of z (see busmux_test.v).
	tri1 [7:0] SB, ADL;
	reg [7:0] sb_val;
	reg sb_drv;
	assign SB = sb_drv ? sb_val : 8'bz;

	reg Y_SB, SB_Y, X_SB, SB_X, S_SB, S_ADL, S_S, SB_S;

	Regs regs (
		.PHI2(PHI2),
		.Y_SB(Y_SB),
		.SB_Y(SB_Y),
		.X_SB(X_SB),
		.SB_X(SB_X),
		.S_SB(S_SB),
		.S_ADL(S_ADL),
		.S_S(S_S),
		.SB_S(SB_S),
		.SB(SB),
		.ADL(ADL) );

	integer errors = 0;
	integer tests  = 0;

	task check_y;
		input [159:0] what;
		input [7:0] exp;
		begin
			tests = tests + 1;
			if (regs.y !== exp) begin
				$display("FAIL %0s: Y=%02x, expected %02x", what, regs.y, exp);
				errors = errors + 1;
			end
		end
	endtask

	task check_x;
		input [159:0] what;
		input [7:0] exp;
		begin
			tests = tests + 1;
			if (regs.x !== exp) begin
				$display("FAIL %0s: X=%02x, expected %02x", what, regs.x, exp);
				errors = errors + 1;
			end
		end
	endtask

	task check_sb;
		input [159:0] what;
		input [7:0] exp;
		begin
			tests = tests + 1;
			if (SB !== exp) begin
				$display("FAIL %0s: SB=%02x, expected %02x", what, SB, exp);
				errors = errors + 1;
			end
		end
	endtask

	initial begin
		$dumpfile("regs_test.vcd");
		$dumpvars(0, regs_test);

		CLK <= 1'b0;
		sb_drv <= 0; sb_val <= 0;
		Y_SB <= 0; SB_Y <= 0; X_SB <= 0; SB_X <= 0;
		S_SB <= 0; S_ADL <= 0; S_S <= 1'b1; SB_S <= 0;
		repeat (2) @(posedge CLK);

		// initial state
		@(negedge CLK) #5;
		check_y("initial Y", 8'h00);
		check_x("initial X", 8'h00);
		tests = tests + 1;
		if (regs.s !== 8'hFF) begin
			$display("FAIL initial S: %02x, expected FF", regs.s);
			errors = errors + 1;
		end

		// load Y from SB
		@(negedge CLK);
		sb_drv = 1; sb_val = 8'hA5;
		SB_Y = 1;
		repeat (2) @(posedge CLK);
		@(negedge CLK) #5;
		check_y("Y loaded", 8'hA5);
		// release and change bus: must hold
		SB_Y = 0;
		sb_val = 8'h00;
		repeat (2) @(posedge CLK);
		@(negedge CLK) #5;
		check_y("Y holds", 8'hA5);
		sb_drv = 0;

		// output Y onto SB
		Y_SB = 1;
		#5;
		check_sb("Y -> SB", 8'hA5);
		Y_SB = 0;

		// load X from SB
		@(negedge CLK);
		sb_drv = 1; sb_val = 8'h5A;
		SB_X = 1;
		repeat (2) @(posedge CLK);
		@(negedge CLK) #5;
		check_x("X loaded", 8'h5A);
		SB_X = 0;
		sb_val = 8'hFF;
		repeat (2) @(posedge CLK);
		@(negedge CLK) #5;
		check_x("X holds", 8'h5A);
		sb_drv = 0;
		X_SB = 1;
		#5;
		check_sb("X -> SB", 8'h5A);
		X_SB = 0;

		// Y overwritten with a second value
		@(negedge CLK);
		sb_drv = 1; sb_val = 8'hB4;
		SB_Y = 1;
		repeat (2) @(posedge CLK);
		SB_Y = 0; sb_drv = 0;
		@(negedge CLK) #5;
		check_y("Y overwritten", 8'hB4);

		// S: load from SB, store to SB and ADL (direct polarity)
		tests = tests + 1;
		if (regs.s !== 8'hFF) begin
			$display("FAIL S unchanged: %02x, expected FF", regs.s);
			errors = errors + 1;
		end
		@(negedge CLK);
		sb_drv = 1; sb_val = 8'hFD;
		SB_S = 1; S_S = 0;
		repeat (2) @(posedge CLK);
		SB_S = 0; S_S = 1;
		sb_drv = 0;
		@(negedge CLK) #5;
		tests = tests + 1;
		if (regs.s !== 8'hFD) begin
			$display("FAIL S loaded: %02x, expected FD", regs.s);
			errors = errors + 1;
		end
		// store S on SB and ADL
		S_SB = 1; S_ADL = 1;
		#5;
		check_sb("S -> SB", 8'hFD);
		tests = tests + 1;
		if (ADL !== 8'hFD) begin
			$display("FAIL S -> ADL: %02x, expected FD", ADL);
			errors = errors + 1;
		end
		S_SB = 0; S_ADL = 0;

		if (errors == 0)
			$display("regs_test: TEST PASS (%0d checks)", tests);
		else
			$display("regs_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // regs_test
