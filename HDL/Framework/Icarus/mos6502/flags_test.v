// Flags register self-check: N/Z/C/D/I/V are written from the data bus
// (DB_P) and read back (P_DB). Because the module stores the flags in
// distributed latches, verify the full round-trip: write a byte, read it
// back and compare the flag bits (DB0=C, DB1=Z, DB2=I, DB3=D, DB6=V,
// DB7=N; DB5 always floats; DB4 is B_OUT which we hold low).
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module flags_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	// Internal data bus is dynamic NMOS (precharge-hold): tri1 keeps
	// undriven bits at 1 instead of z (see busmux_test.v).
	tri1 [7:0] DB;

	reg p_db, db_p, db_n, db_c, db_v;
	reg [7:0] db_val;
	reg db_drv;
	assign DB = db_drv ? db_val : 8'bz;

	wire n_z, n_n, n_c, n_d, n_i, n_v;		// active-low flag outputs

	Flags flags (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.P_DB(p_db),
		.DB_P(db_p),
		.DBZ_Z(1'b0),
		.DB_N(db_n),
		.IR5_C(1'b0),
		.DB_C(db_c),
		.ACR_C(1'b0),
		.IR5_D(1'b0),
		.IR5_I(1'b0),
		.DB_V(db_v),
		.Z_V(1'b0),
		.ACR(1'b0),
		.AVR(1'b0),
		.B_OUT(1'b0),
		.n_IR5(1'b0),
		.BRK6E(1'b0),
		.Dec112(1'b0),
		.SO_frompad(1'b0),
		.DB(DB),
		.n_ZOUT(n_z),
		.n_NOUT(n_n),
		.n_COUT(n_c),
		.n_DOUT(n_d),
		.n_IOUT(n_i),
		.n_VOUT(n_v) );

	integer errors = 0;
	integer tests  = 0;

	task check;
		input [159:0] what;
		input [7:0] exp;
		reg [7:0] got;
		begin
			tests = tests + 1;
			got = DB & 8'hCF;			// compare C,Z,I,D,V,N bits only
			if (got !== (exp & 8'hCF)) begin
				$display("FAIL %0s: readback %02x, expected %02x", what, got, exp & 8'hCF);
				errors = errors + 1;
			end
		end
	endtask

	// write byte v into the P register via DB_P, then read it back via P_DB
	task roundtrip;
		input [7:0] v;
		begin
			// write: keep DB_P asserted over several full cycles so both
			// latch stages settle
			db_drv = 1; db_val = v;
			db_p = 1; db_n = 1; db_c = 1; db_v = 1;	// PLP-style write of all flags
			repeat (4) @(posedge CLK);
			db_p = 0; db_n = 0; db_c = 0; db_v = 0;
			@(posedge CLK);			// let the command latches settle
			// read back
			p_db = 1;
			db_drv = 0;
			#5;
			check("readback", v);
			p_db = 0;
			@(negedge CLK);
		end
	endtask

	initial begin
		$dumpfile("flags_test.vcd");
		$dumpvars(0, flags_test);

		CLK <= 1'b0;
		p_db <= 0; db_p <= 0; db_n <= 0; db_c <= 0; db_v <= 0;
		db_drv <= 0;
		repeat (2) @(posedge CLK);

		roundtrip(8'h00);
		roundtrip(8'hCF);			// all six flags set
		roundtrip(8'h80);			// N only
		roundtrip(8'h01);			// C only
		roundtrip(8'h20);			// no flag bits (bit5 ignored)
		roundtrip(8'h00);

		if (errors == 0)
			$display("flags_test: TEST PASS (%0d checks)", tests);
		else
			$display("flags_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // flags_test
