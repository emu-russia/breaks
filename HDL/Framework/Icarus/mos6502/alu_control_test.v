// ALU control self-check (ALU_Control).
// The combinational outputs AND/SR/INC_SB follow their decode equations:
//   AND   = X[69] | X[70]
//   SR    = X[75] | (X[76] & T6)
//   INC_SB= X[39]|X[40]|X[41]|X[42]|X[43] | (X[44] & T6)
// The registered outputs (NDB_ADD..n_DSA) must settle to 0/1 in both
// phases. A sweep over T-states and X patterns is run.
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module alu_control_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	reg brfw, n_ready, brk6e, stkop, pgx;
	reg T0, T1, T6, T7;
	reg n_dout, n_cout;
	reg [129:0] X;
	wire INC_SB, SR, AND;
	wire NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD, ADD_SB06, ADD_SB7, ADD_ADL;
	wire ANDS, EORS, ORS, SRS, SUMS, n_ACIN, n_DAA, n_DSA;

	ALU_Control ac (
		.PHI1(PHI1), .PHI2(PHI2),
		.BRFW(brfw), .n_ready(n_ready), .BRK6E(brk6e), .STKOP(stkop), .PGX(pgx),
		.X(X),
		.T0(T0), .T1(T1), .T6(T6), .T7(T7),
		.n_DOUT(n_dout), .n_COUT(n_cout),
		.INC_SB(INC_SB), .SR(SR), .AND(AND),
		.NDB_ADD(NDB_ADD), .DB_ADD(DB_ADD), .Z_ADD(Z_ADD), .SB_ADD(SB_ADD),
		.ADL_ADD(ADL_ADD), .ADD_SB06(ADD_SB06), .ADD_SB7(ADD_SB7), .ADD_ADL(ADD_ADL),
		.ANDS(ANDS), .EORS(EORS), .ORS(ORS), .SRS(SRS), .SUMS(SUMS),
		.n_ACIN(n_ACIN), .n_DAA(n_DAA), .n_DSA(n_DSA) );

	integer errors = 0;
	integer tests  = 0;
	integer pat, i;
	reg bad_x;

	task expect;
		input [159:0] what;
		input exp;
		input got;
		begin
			tests = tests + 1;
			if (got !== exp) begin
				$display("FAIL %0s pat %0d: got %b, expected %b", what, pat, got, exp);
				errors = errors + 1;
			end
		end
	endtask

	initial begin
		$dumpfile("alu_control_test.vcd");
		$dumpvars(0, alu_control_test);

		CLK <= 1'b0;
		brfw <= 0; n_ready <= 0; brk6e <= 0; stkop <= 0; pgx <= 0;
		T0 <= 0; T1 <= 0; T6 <= 0; T7 <= 0;
		n_dout <= 1; n_cout <= 1;
		X <= 0;
		repeat (2) @(posedge CLK);

		for (pat = 0; pat < 96; pat = pat + 1) begin
			@(negedge CLK);
			T0 = (pat % 8 == 0); T1 = (pat % 8 == 1);
			T6 = (pat % 8 == 6); T7 = (pat % 8 == 7);
			brk6e = (pat % 8 == 6); n_ready = (pat % 8 == 3);
			stkop = pat[0]; pgx = pat[1]; brfw = pat[2];
			n_dout = ~pat[3]; n_cout = ~pat[4];
			X = 0;
			case (pat % 6)
				0: X = 0;
				1: X = 130'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
				2: for (i = 0; i < 130; i = i + 1) X[i] = pat[i % 8];
				3: begin X[39]=1; X[44]=1; X[69]=1; X[75]=1; X[76]=1; end
				4: begin X[40]=1; X[43]=1; X[70]=1; X[26]=1; X[27]=1; X[29]=1; X[30]=1; end
				default: begin X[32]=1; X[33]=1; X[45]=1; X[47]=1; X[48]=1; X[49]=1; X[51]=1;
					 X[52]=1; X[56]=1; X[84]=1; X[85]=1; X[93]=1; X[50]=1; end
			endcase
			#5;
			// combinational outputs
			expect("AND", X[69] | X[70], AND);
			expect("SR",  X[75] | (X[76] & T6), SR);
			expect("INC_SB", X[39]|X[40]|X[41]|X[42]|X[43]|(X[44]&T6), INC_SB);
			#20;	// into PHI2
			bad_x = 0;
			if (NDB_ADD === 1'bx || DB_ADD === 1'bx || Z_ADD === 1'bx ||
			    SB_ADD === 1'bx || ADL_ADD === 1'bx || ADD_SB06 === 1'bx ||
			    ADD_SB7 === 1'bx || ADD_ADL === 1'bx || ANDS === 1'bx ||
			    EORS === 1'bx || ORS === 1'bx || SRS === 1'bx || SUMS === 1'bx ||
			    n_ACIN === 1'bx || n_DAA === 1'bx || n_DSA === 1'bx) bad_x = 1;
			tests = tests + 1;
			if (bad_x) begin
				$display("FAIL registered x at pat %0d", pat);
				errors = errors + 1;
			end
		end

		if (errors == 0)
			$display("alu_control_test: TEST PASS (%0d checks)", tests);
		else
			$display("alu_control_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // alu_control_test
