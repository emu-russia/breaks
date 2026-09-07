// Bus multiplexer self-check (BreakingNESWiki/6502/busmux.md):
//  - During PHI2 every internal bus is precharged to 0xFF.
//  - Z_ADL0..2 / Z_ADH0 / Z_ADH17 ground the corresponding ADL/ADH bits
//    (forming constant vectors such as the interrupt vector address).
//  - SB_DB / SB_ADH connect the SB bus to DB / ADH (bidirectional).
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module busmux_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	tri1 [7:0] SB, DB, ADL, ADH;	// precharge-hold for undriven bits

	reg z_adl0, z_adl1, z_adl2, z_adh0, z_adh17;
	reg sb_db, sb_adh;
	reg pre;					// force PHI2 view

	BusMux busmux (
		.PHI2(PHI2),
		.SB(SB),
		.DB(DB),
		.ADL(ADL),
		.ADH(ADH),
		.Z_ADL0(z_adl0),
		.Z_ADL1(z_adl1),
		.Z_ADL2(z_adl2),
		.Z_ADH0(z_adh0),
		.Z_ADH17(z_adh17),
		.SB_DB(sb_db),
		.SB_ADH(sb_adh) );

	// TB driver for testing the bus-to-bus connections
	reg [7:0] sb_val;
	reg sb_drv;
	assign SB = sb_drv ? sb_val : 8'bz;

	integer errors = 0;
	integer tests  = 0;

	task expect8;
		input [159:0] what;
		input [7:0] exp;
		input [7:0] got;
		begin
			tests = tests + 1;
			if (got !== exp) begin
				$display("FAIL %0s: got %02x, expected %02x", what, got, exp);
				errors = errors + 1;
			end
		end
	endtask

	initial begin
		$dumpfile("busmux_test.vcd");
		$dumpvars(0, busmux_test);

		CLK <= 1'b0;
		z_adl0 = 0; z_adl1 = 0; z_adl2 = 0; z_adh0 = 0; z_adh17 = 0;
		sb_db = 0; sb_adh = 0;
		sb_drv = 0;
		repeat (2) @(posedge CLK);

		// ---- precharge: mid-PHI2 every bus reads 0xFF
		@(posedge CLK) #10;
		expect8("precharge SB",  8'hFF, SB);
		expect8("precharge DB",  8'hFF, DB);
		expect8("precharge ADL", 8'hFF, ADL);
		expect8("precharge ADH",  8'hFF, ADH);

		// ---- zeroing: mid-PHI1 (no precharge), each Z_xx grounds its bits
		@(negedge CLK) #5;
		z_adl0 = 1; z_adl1 = 1; z_adl2 = 0;
		z_adh0 = 0; z_adh17 = 1;
		#3;
		expect8("Z_ADL01 -> FC",   8'hFC, ADL);		// only bits 0,1 grounded
		expect8("Z_ADH17 -> 01",   8'h01, ADH);		// bits 1-7 grounded, bit0 holds high
		z_adl0 = 0; z_adl1 = 0; z_adl2 = 0;
		z_adh17 = 0; z_adh0 = 0;

		// ---- bus-to-bus: SB_DB, SB_ADH
		sb_drv = 1; sb_val = 8'hA5;
		sb_db = 1;		// SB <=> DB
		#3;
		expect8("SB_DB -> DB", 8'hA5, DB);
		sb_db = 0; sb_adh = 1;
		#2;
		expect8("SB_ADH -> ADH", 8'hA5, ADH);
		sb_adh = 0;
		sb_drv = 0;

		if (errors == 0)
			$display("busmux_test: TEST PASS (%0d checks)", tests);
		else
			$display("busmux_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // busmux_test
