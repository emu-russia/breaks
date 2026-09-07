// Branch logic self-check (branch taken decision).
// For a branch opcode:
//   selected flag by (b6,b7): (0,0)->N, (1,0)->V, (0,1)->C, (1,1)->Z
//   taken  = (selected flag == b5)   (branch on clear when b5=0, set when b5=1)
// The module receives the IR bits complemented through the decode lines
// (X[121] = ~b6, X[126] = ~b7) and n_IR5 = ~b5 and outputs n_BRTAKEN,
// which is active low (0 when the branch is taken).
// All 8 branch opcodes x all 16 flag combinations are checked.
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module branch_logic_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	reg [7:0] ir;					// branch opcode
	reg [129:0] X;
	reg n_c, n_v, n_n, n_z;			// flags, active low (0 = set)
	wire [7:0] db;
	wire n_brtaken, brfw;


	BranchLogic bl (
		.PHI1(PHI1), .PHI2(PHI2),
		.n_IR5(~ir[5]),
		.X(X),
		.n_COUT(n_c),
		.n_VOUT(n_v),
		.n_NOUT(n_n),
		.n_ZOUT(n_z),
		.DB(db),
		.BR2(1'b0),
		.n_BRTAKEN(n_brtaken),
		.BRFW(brfw) );

	integer errors = 0;
	integer tests  = 0;

	reg [7:0] opcodes [0:7];
	integer idx;
	integer flags;
	reg selc, selz, seln, selv;
	reg flagval;
	reg expected;

	initial begin
		$dumpfile("branch_logic_test.vcd");
		$dumpvars(0, branch_logic_test);

		CLK <= 1'b0;
		ir <= 8'h00; X <= 0;
		n_c <= 1; n_v <= 1; n_n <= 1; n_z <= 1;
		repeat (2) @(posedge CLK);

		opcodes[0] = 8'h10; opcodes[1] = 8'h30;	// BPL, BMI (N)
		opcodes[2] = 8'h50; opcodes[3] = 8'h70;	// BVC, BVS (V)
		opcodes[4] = 8'h90; opcodes[5] = 8'hB0;	// BCC, BCS (C)
		opcodes[6] = 8'hD0; opcodes[7] = 8'hF0;	// BNE, BEQ (Z)

		for (idx = 0; idx < 8; idx = idx + 1) begin
			ir = opcodes[idx];
			X = 130'b0;
			X[121] = ~ir[6];			// n_IR6
			X[126] = ~ir[7];			// n_IR7
			selc = ~ir[6] &  ir[7];
			selz =  ir[6] &  ir[7];
			seln = ~ir[6] & ~ir[7];
			selv =  ir[6] & ~ir[7];
			for (flags = 0; flags < 16; flags = flags + 1) begin
				// flags bit 0=C 1=Z 2=N 3=V (1 = set)
				n_c = ~flags[0]; n_z = ~flags[1]; n_n = ~flags[2]; n_v = ~flags[3];
				if (selc) flagval = flags[0];
				else if (selz) flagval = flags[1];
				else if (seln) flagval = flags[2];
				else flagval = flags[3];
				expected = ~(flagval == ir[5]);		// n_BRTAKEN active low
				#2;
				tests = tests + 1;
				if (n_brtaken !== expected) begin
					$display("FAIL op ir=%02x idx=%0d X121=%b X126=%b nIR5=%b nC=%b nZ=%b nN=%b nV=%b: n_BRTAKEN=%b, expected %b",
						ir, idx, X[121], X[126], ~ir[5], n_c, n_z, n_n, n_v, n_brtaken, expected);
					errors = errors + 1;
				end
			end
		end

		if (errors == 0)
			$display("branch_logic_test: TEST PASS (%0d checks)", tests);
		else
			$display("branch_logic_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // branch_logic_test
