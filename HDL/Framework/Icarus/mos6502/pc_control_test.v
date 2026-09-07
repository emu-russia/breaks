// PC control property test (PC_Control).
// PC_Control turns the decode bus into the PC commands through several
// PHI1/PHI2 latch chains. There is no simple combinational truth table, so
// the test checks the two observable properties:
//   1. with a driven vector held for several cycles every output settles to
//      0/1 in both phases (no x/z, no undriven nets);
//   2. the command set is deterministic: presenting the same vector again
//      reproduces the same outputs (catches hysteresis / state leakage).
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module pc_control_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	reg n_ready, T0, T1, BR0;
	reg [129:0] X;
	wire PCL_DB, PCH_DB, PC_DB, PCL_ADL, PCH_ADH, PCL_PCL, ADL_PCL, n_ADL_PCL, DL_PCH, ADH_PCH, PCH_PCH, n_PCH_PCH;

	PC_Control pc (
		.PHI1(PHI1), .PHI2(PHI2),
		.n_ready(n_ready), .T0(T0), .T1(T1), .BR0(BR0),
		.X(X),
		.PCL_DB(PCL_DB), .PCH_DB(PCH_DB), .PC_DB(PC_DB), .PCL_ADL(PCL_ADL),
		.PCH_ADH(PCH_ADH), .PCL_PCL(PCL_PCL), .ADL_PCL(ADL_PCL),
		.n_ADL_PCL(n_ADL_PCL), .DL_PCH(DL_PCH), .ADH_PCH(ADH_PCH),
		.PCH_PCH(PCH_PCH), .n_PCH_PCH(n_PCH_PCH) );

	integer errors = 0;
	integer tests  = 0;
	integer pat, i, pass;

	// snapshots of the 12 outputs per pattern, recorded on the first pass
	reg [11:0] snap_p1 [0:63];
	reg [11:0] snap_p2 [0:63];
	reg [11:0] snap_p1_prev [0:63];
	reg [11:0] snap_p2_prev [0:63];

	task snapshot;
		output [11:0] s;
		begin
			s = {PCL_DB, PCH_DB, PC_DB, PCL_ADL, PCH_ADH, PCL_PCL,
			     ADL_PCL, n_ADL_PCL, DL_PCH, ADH_PCH, PCH_PCH, n_PCH_PCH};
		end
	endtask

	task check_now;
		input [159:0] what;
		reg [11:0] s;
		integer b;
		begin
			snapshot(s);
			tests = tests + 1;
			for (b = 0; b < 12; b = b + 1)
				if (s[b] === 1'bx || s[b] === 1'bz) begin
					$display("FAIL %0s pat %0d: bit %0d is x/z", what, pat, b);
					errors = errors + 1;
				end
		end
	endtask

	initial begin
		$dumpfile("pc_control_test.vcd");
		$dumpvars(0, pc_control_test);

		CLK <= 1'b0;
		n_ready <= 0; T0 <= 0; T1 <= 0; BR0 <= 0;
		X <= 0;
		repeat (2) @(posedge CLK);

		for (pass = 0; pass < 2; pass = pass + 1) begin
			for (pat = 0; pat < 40; pat = pat + 1) begin
				@(negedge CLK);
				n_ready = pat[0]; T0 = (pat % 8 == 0); T1 = (pat % 8 == 1); BR0 = (pat % 8 == 6);
				X = 0;
				case (pat % 8)
					0: X = 0;
					1: X = 130'h1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
					2: for (i = 0; i < 130; i = i + 1) X[i] = pat[i % 8];
					3: begin X[56]=1; X[77]=1; X[78]=1; X[80]=1; X[93]=1; X[83]=1; X[129]=1; end
					4: begin X[84]=1; X[94]=1; X[95]=1; X[96]=1; X[83]=1; end
					5: begin X[57]=1; X[94]=1; X[129]=1; X[128]=1; X[56]=1; end
					6: begin X[77]=1; X[78]=1; X[84]=1; X[101]=1; X[45]=1; X[46]=1; X[47]=1; end
					default: begin X[48]=1; X[79]=1; X[81]=1; X[82]=1; X[55]=1; X[65]=1; X[64]=1; end
				endcase
				// settle for two full cycles
				repeat (2) @(posedge CLK);
				// sample in PHI1 and PHI2
				@(negedge CLK) #8;
				check_now("PHI1");
				snapshot(snap_p1[pat]);
				@(posedge CLK) #12;
				check_now("PHI2");
				snapshot(snap_p2[pat]);
				if (pass == 1) begin
					tests = tests + 1;
					if (snap_p1[pat] !== snap_p1_prev[pat]) begin
						$display("FAIL PHI1 not deterministic pat %0d", pat);
						errors = errors + 1;
					end
					if (snap_p2[pat] !== snap_p2_prev[pat]) begin
						$display("FAIL PHI2 not deterministic pat %0d", pat);
						errors = errors + 1;
					end
				end
			end
			// copy pass0 snapshots to _prev arrays
			for (i = 0; i < 40; i = i + 1) begin
				snap_p1_prev[i] = snap_p1[i];
				snap_p2_prev[i] = snap_p2[i];
			end
		end

		if (errors == 0)
			$display("pc_control_test: TEST PASS (%0d checks)", tests);
		else
			$display("pc_control_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // pc_control_test
