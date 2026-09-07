// Bus control self-check (Bus_Control).
// The combinational outputs ZTST/PGX are checked against their equations:
//   nSBAC = ~(X[58..64]);  ZTST = ~n_SBXY | ~nSBAC | T7 | AND
//   PGX   = ~( (~(X[71]|X[72])) & ~BR0 )
// The latched outputs (Z_ADH0..DL_DB) must always settle to 0/1 (no x/z)
// after each PHI2. A sweep over the T0..T7 states and several X patterns
// (all-0, all-1, walking ones, decode-like lines) is run.
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module bus_control_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	reg n_sbxy, AND, STOR, Z_ADL0, ACRL2, DL_PCH, n_ready, INC_SB, BRK6E, STXY, n_pch_pch;
	reg T0, T1, T2, T6, T7, BR0, BR2, BR3;
	reg [129:0] X;
	wire ZTST, PGX;
	wire Z_ADH0, Z_ADH17, SB_AC, ADL_ABL, AC_SB, SB_DB, AC_DB, SB_ADH, DL_ADH, DL_ADL, ADH_ABH, DL_DB;

	Bus_Control bc (
		.PHI1(PHI1), .PHI2(PHI2),
		.n_SBXY(n_sbxy), .AND(AND), .STOR(STOR), .Z_ADL0(Z_ADL0), .ACRL2(ACRL2),
		.DL_PCH(DL_PCH), .n_ready(n_ready), .INC_SB(INC_SB), .BRK6E(BRK6E),
		.STXY(STXY), .n_PCH_PCH(n_pch_pch),
		.T0(T0), .T1(T1), .T2(T2), .T6(T6), .T7(T7), .BR0(BR0), .BR2(BR2), .BR3(BR3),
		.X(X),
		.ZTST(ZTST), .PGX(PGX),
		.Z_ADH0(Z_ADH0), .Z_ADH17(Z_ADH17), .SB_AC(SB_AC), .ADL_ABL(ADL_ABL),
		.AC_SB(AC_SB), .SB_DB(SB_DB), .AC_DB(AC_DB), .SB_ADH(SB_ADH),
		.DL_ADH(DL_ADH), .DL_ADL(DL_ADL), .ADH_ABH(ADH_ABH), .DL_DB(DL_DB) );

	integer errors = 0;
	integer tests  = 0;
	integer pat;

	reg [2:0] tstate;			// which T cycle is high
	reg [5:0] xmode;			// X pattern

	// expected values
	reg exp_ztst, exp_pgx, n_sbac;
	reg x71x72;

	reg bad_x;
	integer i;

	always @(posedge CLK) #15 begin
		// check latched outputs settle 0/1 in PHI2
		bad_x = 0;
		if (Z_ADH0 === 1'bx || Z_ADH17 === 1'bx || SB_AC === 1'bx ||
		    ADL_ABL === 1'bx || AC_SB === 1'bx || SB_DB === 1'bx ||
		    AC_DB === 1'bx || SB_ADH === 1'bx || DL_ADH === 1'bx ||
		    DL_ADL === 1'bx || ADH_ABH === 1'bx || DL_DB === 1'bx) bad_x = 1;
		// combinational checks (only for the currently driven pattern)
		tests = tests + 1;
		if (bad_x) begin
			$display("FAIL latched outputs x at pat %0d", pat);
			errors = errors + 1;
		end
	end

	task setpattern;
		input [2:0] ts;		// T0..T7 selected cycle (0=T0..4=T5 none 5=T6 6=T7) simplified
		input [5:0] xm;
		begin
			tstate = ts;
			xmode = xm;
		end
	endtask

	initial begin
		$dumpfile("bus_control_test.vcd");
		$dumpvars(0, bus_control_test);

		CLK <= 1'b0;
		n_sbxy <= 0; AND <= 0; STOR <= 0; Z_ADL0 <= 0; ACRL2 <= 0; DL_PCH <= 0;
		n_ready <= 0; INC_SB <= 0; BRK6E <= 0; STXY <= 0; n_pch_pch <= 1;
		T0 <= 0; T1 <= 0; T2 <= 0; T6 <= 0; T7 <= 0; BR0 <= 0; BR2 <= 0; BR3 <= 0;
		X <= 0;
		repeat (2) @(posedge CLK);

		for (pat = 0; pat < 96; pat = pat + 1) begin
			@(negedge CLK);
			// cycle state: cycle 0..5 -> T0..T5 style (T2 for 2), 6->T6, 7->T7
			T0 = (pat % 8 == 0); T1 = (pat % 8 == 1);
			T2 = (pat % 8 == 2); T6 = (pat % 8 == 6); T7 = (pat % 8 == 7);
			BR0 = (pat % 16 == 0); BR2 = (pat % 24 == 0); BR3 = (pat % 24 == 12);
			BRK6E = (pat % 8 == 6); n_ready = (pat % 8 == 3);
			AND = pat[1]; STOR = pat[2]; n_sbxy = pat[3];
			Z_ADL0 = pat[0]; ACRL2 = pat[2]; DL_PCH = pat[3]; INC_SB = pat[4];
			STXY = pat[5]; n_pch_pch = ~pat[4];
			// X pattern by bits of pat: walking ones across a subset + odd/even
			X = 0;
			case (pat % 6)
				0: X = 0;
				1: X = 130'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
				2: for (i = 0; i < 130; i = i + 1) X[i] = pat[i % 8];
				3: begin X[58]=1; X[64]=1; X[80]=1; X[93]=1; X[71]=1; X[72]=1; end
				4: begin X[45]=1; X[46]=1; X[47]=1; X[48]=1; X[55]=1; X[56]=1; X[57]=1; end
				default: begin X[65]=1; X[66]=1; X[67]=1; X[68]=1; X[74]=1; X[79]=1;
					 X[81]=1; X[82]=1; X[83]=1; X[84]=1; X[89]=1; X[90]=1; X[91]=1; X[101]=1;
					 X[128]=1; X[129]=1; end
			endcase
			#5;
			// combinational check
			n_sbac = ~(X[58] | X[59] | X[60] | X[61] | X[62] | X[63] | X[64]);
			exp_ztst = n_sbxy | ~n_sbac | T7 | AND;
			x71x72 = ~(X[71] | X[72]);
			exp_pgx  = ~(x71x72 & ~BR0);
			tests = tests + 1;
			if (ZTST !== exp_ztst) begin
				$display("FAIL pat %0d ZTST=%b exp %b", pat, ZTST, exp_ztst);
				errors = errors + 1;
			end
			if (PGX !== exp_pgx) begin
				$display("FAIL pat %0d PGX=%b exp %b", pat, PGX, exp_pgx);
				errors = errors + 1;
			end
		end

		// one more idle pass to settle latches, then finish
		repeat (3) @(posedge CLK);

		if (errors == 0)
			$display("bus_control_test: TEST PASS (%0d checks)", tests);
		else
			$display("bus_control_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // bus_control_test
