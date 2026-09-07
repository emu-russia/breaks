// Regs control self-check (Regs_Control).
// With a vector held for one full cycle, sample in the following PHI1:
//   Y_SB  =  X1|X2|X3|X4|X5|(X6&X7)|(X0&STOR)
//   X_SB  =  X8|X9|X10|X11|X13|(X6&~X7)|(X12&STOR)
//   SB_X  =  X14|X15|X16
//   SB_Y  =  X18|X19|X20
//   SB_S  =  nSBS          (nSBS = ~(X13 | ~(~X48|n_ready) | STKOP))
//   S_S   =  ~nSBS? -> nSBS  (S_S = ~(ss_latch_q|PHI2), q stores ~nSBS)
//   S_SB  =  X17
//   S_ADL =  ~nSADL        (nSADL = ~((X21&nready_latch_nq)|X35))
//   STKOP =  ~(tmp1|n_ready)   (tmp1 = ~(X21..X26))
//   STXY  =  (X0&STOR)|(X12&STOR)
//   n_SBXY=  (X14|X15|X16)|(X18|X19|X20)
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module regs_control_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	reg STOR, n_ready;
	reg [129:0] X;
	wire STXY, n_SBXY, STKOP;
	wire Y_SB, X_SB, S_SB, SB_X, SB_Y, SB_S, S_S, S_ADL;

	Regs_Control rc (
		.PHI1(PHI1), .PHI2(PHI2),
		.STOR(STOR), .n_ready(n_ready),
		.X(X),
		.STXY(STXY), .n_SBXY(n_SBXY), .STKOP(STKOP),
		.Y_SB(Y_SB), .X_SB(X_SB), .S_SB(S_SB), .SB_X(SB_X), .SB_Y(SB_Y),
		.SB_S(SB_S), .S_S(S_S), .S_ADL(S_ADL) );

	integer errors = 0;
	integer tests  = 0;
	integer pat, i;

	reg exp_tmp1, exp_stkop, exp_nsbs;
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
		$dumpfile("regs_control_test.vcd");
		$dumpvars(0, regs_control_test);

		CLK <= 1'b0;
		STOR <= 0; n_ready <= 0;
		X <= 0;
		repeat (2) @(posedge CLK);

		for (pat = 0; pat < 80; pat = pat + 1) begin
			@(negedge CLK);		// PHI1 start
			STOR = pat[0]; n_ready = pat[1];
			X = 0;
			case (pat % 10)
				0: X = 0;
				1: X = 130'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
				2: for (i = 0; i < 130; i = i + 1) X[i] = pat[i % 8];
				3: begin X[0]=1; X[1]=1; X[6]=1; X[7]=1; X[12]=1; X[13]=1; X[17]=1; end
				4: begin X[14]=1; X[18]=1; X[21]=1; X[22]=1; X[48]=1; X[35]=1; end
				5: begin X[2]=1; X[5]=1; X[8]=1; X[15]=1; X[19]=1; X[23]=1; X[49]=1; end
				6: begin X[3]=1; X[9]=1; X[16]=1; X[20]=1; X[24]=1; X[6]=1; end
				7: begin X[4]=1; X[10]=1; X[25]=1; X[26]=1; X[12]=1; X[7]=1; end
				8: begin X[5]=1; X[11]=1; X[2]=1; X[17]=1; X[21]=1; end
				default: begin X[0]=1; X[12]=1; X[21]=1; X[35]=1; X[48]=1; X[13]=1; end
			endcase
			@(posedge CLK);		// PHI2: latches update
			@(negedge CLK) #8;	// PHI1: effective outputs

			expect("STXY",  ~((X[0]&STOR)|(X[12]&STOR)), STXY);
			expect("n_SBXY", (X[14]|X[15]|X[16])|(X[18]|X[19]|X[20]), n_SBXY);
			exp_tmp1 = ~(X[21]|X[22]|X[23]|X[24]|X[25]|X[26]);
			exp_stkop = ~(exp_tmp1 | n_ready);
			expect("STKOP", exp_stkop, STKOP);
			expect("Y_SB",  X[1]|X[2]|X[3]|X[4]|X[5]|(X[6]&X[7])|(X[0]&STOR), Y_SB);
			expect("X_SB",  X[8]|X[9]|X[10]|X[11]|X[13]|(X[6]&~X[7])|(X[12]&STOR), X_SB);
			expect("SB_X",  X[14]|X[15]|X[16], SB_X);
			expect("SB_Y",  X[18]|X[19]|X[20], SB_Y);
			expect("S_SB",  X[17], S_SB);
			exp_nsbs = ~( X[13] | ~(~X[48]|n_ready) | exp_stkop );
			expect("S_S",    exp_nsbs, S_S);			// S_S  = nSBS
			expect("SB_S",   ~exp_nsbs, SB_S);			// SB_S = ~nSBS
			expect("S_ADL", (X[21] & ~n_ready) | X[35], S_ADL);
		end

		if (errors == 0)
			$display("regs_control_test: TEST PASS (%0d checks)", tests);
		else
			$display("regs_control_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // regs_control_test
