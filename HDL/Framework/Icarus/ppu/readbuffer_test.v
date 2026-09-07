// ReadBuffer (HDL/PPU/vram_ctrl.v) self-check.
//
// The read buffer is the intermediate storage for the $2007 VRAM data port:
// the PPU loads it from the external VRAM data bus (PD) with PD_RB after each
// fetch, and the CPU reads it back through $2007 while the VRAM controller
// opens it onto the internal DB.
//
// Storage is a level-sensitive register (Common/sdffr): rb_q follows PD_in
// while PD_RB=1, holds while PD_RB=0, and RC=1 resets it to 0 (RC dominates).
//
// Output enable semantics follow BreakingNESWiki/PPU/vram_ctrl.md: "XRB:
// включает tri-state логику, которая отсоединяет PPU read buffer от
// внутренней шины данных" — XRB=1 switches the RB output stage into
// tri-state, i.e. the buffer is DISCONNECTED from the internal DB bus (it
// must never fight the register/OAM/CRAM/pad drivers that share DB).
// VRAM_Control asserts XRB for every state except a non-palette $2007 read,
// so the buffer drives rb_q onto DB only while XRB=0.
//
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module readbuffer_test ();

	reg XRB;
	reg RC;
	reg PD_RB;
	reg [7:0] PD_in;

	reg [7:0] db_val;
	reg db_drv;
	wire [7:0] CPU_DB = db_drv ? db_val : 8'bz;

	ReadBuffer uut (
		.XRB(XRB),
		.RC(RC),
		.PD_RB(PD_RB),
		.PD_in(PD_in),
		.CPU_DB(CPU_DB) );

	integer errors = 0;
	integer checks = 0;

	// check rb_q indirectly through CPU_DB (XRB=0 opens the output)
	task check_q;
		input [159:0] what;
		input [7:0] exp;
		begin
			db_drv = 0;
			XRB = 1'b0;
			#1;
			checks = checks + 1;
			if (CPU_DB !== exp) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL %0s: CPU_DB=%02x, expected %02x", what, CPU_DB, exp);
			end
		end
	endtask

	initial begin
		$dumpfile("readbuffer_test.vcd");
		$dumpvars(0, readbuffer_test);

		XRB = 1'b1; RC = 1'b1; PD_RB = 1'b0; PD_in = 8'hFF;   // held in reset
		db_drv = 0;
		#1;

		// 1) Reset: buffer content is 0.
		check_q("reset value", 8'h00);

		// 2) RC dominates PD_RB: even an open load does not survive reset.
		PD_in = 8'hA5; PD_RB = 1'b1;
		#1;
		check_q("RC dominates load", 8'h00);
		RC = 1'b0;
		#1;

		// 3) Load: while PD_RB=1 the buffer follows PD_in.
		PD_in = 8'hA5;
		#1;
		check_q("loaded A5", 8'hA5);
		PD_in = 8'h3C;
		#1;
		check_q("follows while open", 8'h3C);

		// 4) Hold: with PD_RB=0 a changing PD_in must not disturb rb_q.
		PD_RB = 1'b0;
		PD_in = 8'hFF;
		#1;
		check_q("holds after close", 8'h3C);
		#50;
		check_q("holds over time", 8'h3C);

		// 5) Output tri-state: XRB=1 disconnects rb_q from CPU_DB (z).
		XRB = 1'b1;
		#1;
		checks = checks + 1;
		if (CPU_DB !== 8'bz) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL XRB=1 not z: %02x", CPU_DB);
		end

		// 6) Re-load and re-check the open path.
		PD_RB = 1'b1; PD_in = 8'hC3;
		#1;
		PD_RB = 1'b0;
		#1;
		check_q("reloaded C3", 8'hC3);

		// 7) Reset again: RC clears the buffer while it holds.
		RC = 1'b1;
		#1;
		check_q("reset clears", 8'h00);
		RC = 1'b0;
		#1;

		// 8) Idle behaviour: everything driven, no x/z, output stays z.
		XRB = 1'b1;
		PD_RB = 1'b0; PD_in = 8'h55;
		#1;
		checks = checks + 1;
		if (CPU_DB !== 8'bz) begin
			errors = errors + 1;
			if (errors <= 20) $display("FAIL idle not z: %02x", CPU_DB);
		end

		if (errors == 0)
			$display("readbuffer_test: TEST PASS (%0d checks)", checks);
		else
			$display("readbuffer_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // readbuffer_test
