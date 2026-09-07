// Flags control self-check (Flags_Control).
// With a vector stable through PHI2 every output follows its decode formula
// (the PHI2 latches are transparent while enabled):
//   P_DB  = X[98]|X[99];        IR5_I = X[108];   IR5_C = X[110];
//   IR5_D = X[120];             Z_V   = X[127];
//   ACR_C = ~nARITH (nq of the carry latch); nARITH = ~((X[107]&T7)|X[112]|X[116..119])
//   DBZ_Z = ACR_C|ZTST|X[109];
//   DB_N  = ~( (~(ACR_C|ZTST|X[109])) & (~(X[114]|X[115])) | X[109] );
//   DB_P  = (X[114]|X[115]) & ~n_ready;
//   DB_C  = SR | DB_P;
//   DB_V  = (X[114]|X[115]) | X[113];
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module flags_control_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	reg T7, ZTST, n_ready, SR;
	reg [129:0] X;
	wire P_DB, IR5_I, IR5_C, IR5_D, Z_V, ACR_C, DBZ_Z, DB_N, DB_P, DB_C, DB_V;

	Flags_Control fc (
		.PHI2(PHI2), .X(X),
		.T7(T7), .ZTST(ZTST), .n_ready(n_ready), .SR(SR),
		.P_DB(P_DB), .IR5_I(IR5_I), .IR5_C(IR5_C), .IR5_D(IR5_D), .Z_V(Z_V),
		.ACR_C(ACR_C), .DBZ_Z(DBZ_Z), .DB_N(DB_N), .DB_P(DB_P), .DB_C(DB_C), .DB_V(DB_V) );

	integer errors = 0;
	integer tests  = 0;
	integer pat, i;

	reg exp_narith, exp_acrc, exp_dbz, exp_dbn, exp_dbp, exp_dbc, exp_dbv;

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
		$dumpfile("flags_control_test.vcd");
		$dumpvars(0, flags_control_test);

		CLK <= 1'b0;
		T7 <= 0; ZTST <= 0; n_ready <= 0; SR <= 0;
		X <= 0;
		repeat (2) @(posedge CLK);

		for (pat = 0; pat < 96; pat = pat + 1) begin
			@(negedge CLK);
			T7 = pat[0]; ZTST = pat[1]; n_ready = pat[2]; SR = pat[3];
			X = 0;
			case (pat % 8)
				0: X = 0;
				1: X = 130'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
				2: for (i = 0; i < 130; i = i + 1) X[i] = pat[i % 8];
				3: begin X[98]=1; X[99]=1; X[107]=1; X[108]=1; X[109]=1; X[110]=1; X[112]=1; end
				4: begin X[113]=1; X[114]=1; X[115]=1; X[116]=1; X[117]=1; X[118]=1; end
				5: begin X[119]=1; X[120]=1; X[127]=1; end
				6: begin X[98]=1; X[113]=1; X[109]=1; X[114]=1; end
				default: begin X[107]=1; X[112]=1; X[108]=1; X[110]=1; X[120]=1; end
			endcase
			@(posedge CLK) #12;		// mid-PHI2, latches transparent

			expect("P_DB",  X[98] | X[99], P_DB);
			expect("IR5_I", X[108], IR5_I);
			expect("IR5_C", X[110], IR5_C);
			expect("IR5_D", X[120], IR5_D);
			expect("Z_V",   X[127], Z_V);
			exp_narith = ~((X[107] & T7) | X[112] | X[116] | X[117] | X[118] | X[119]);
			exp_acrc = ~exp_narith;
			expect("ACR_C", exp_acrc, ACR_C);
			exp_dbz = exp_acrc | ZTST | X[109];
			expect("DBZ_Z", exp_dbz, DBZ_Z);
			exp_dbp = (X[114] | X[115]) & ~n_ready;
			expect("DB_P", exp_dbp, DB_P);
			exp_dbc = SR | exp_dbp;
			expect("DB_C", exp_dbc, DB_C);
			exp_dbv = (X[114] | X[115]) | X[113];
			expect("DB_V", exp_dbv, DB_V);
			exp_dbn = ~( (~(exp_acrc | ZTST | X[109])) & (~(X[114] | X[115])) | X[109] );
			expect("DB_N", exp_dbn, DB_N);
		end

		if (errors == 0)
			$display("flags_control_test: TEST PASS (%0d checks)", tests);
		else
			$display("flags_control_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // flags_control_test
