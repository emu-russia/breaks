// PreDecode self-check:
//  - During PHI2 (Z_IR=0) the opcode on the data bus is captured: PD = opcode,
//    n_PD = ~opcode.
//  - Z_IR=1 clears the predecode register (n_PD = FF).
//  - n_IMPLIED / n_TWOCYCLE are the documented combinational functions of PD
//    (alu-style NOR equations); the test recomputes them from the opcode and
//    compares against the module for every opcode 0..255 (also checks the
//    outputs are fully driven, no x/z).
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module predecode_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire [7:0] Data_bus, n_PD;
	wire n_IMPLIED, n_TWOCYCLE;
	reg [7:0] data_val;
	reg z_ir;
	reg db_drv;
	assign Data_bus = db_drv ? data_val : 8'bz;

	PreDecode predecode (
		.PHI2(PHI2),
		.Z_IR(z_ir),
		.Data_bus(Data_bus),
		.n_PD(n_PD),
		.n_IMPLIED(n_IMPLIED),
		.n_TWOCYCLE(n_TWOCYCLE) );

	integer errors = 0;
	integer tests  = 0;
	integer op;

	// mirror of the module equations for PD = opcode
	function expected_implied;
		input [7:0] pd;
		begin
			expected_implied = ~(pd[0] | pd[2] | ~pd[3]);		// nor(PD0,PD2,n_PD3)
		end
	endfunction

	function expected_twocycle;
		input [7:0] pd;
		reg implied, tmp1, tmp2, tmp3, e;
		begin
			implied = ~(pd[0] | pd[2] | ~pd[3]);
			tmp1 = ~(pd[1] | pd[4] | pd[7]);
			tmp2 = ~(~pd[0] | pd[2] | ~pd[3] | pd[4]);
			tmp3 = ~(pd[0] | pd[2] | pd[3] | pd[4] | ~pd[7]);
			e = (implied & ~tmp1) | tmp2 | tmp3;
			expected_twocycle = ~e;			// n_TWOCYCLE output
		end
	endfunction

	initial begin
		$dumpfile("predecode_test.vcd");
		$dumpvars(0, predecode_test);

		CLK <= 1'b0;
		z_ir <= 1'b0;
		db_drv <= 1;
		data_val <= 8'h00;
		repeat (2) @ (posedge CLK);

		// clear with Z_IR
		z_ir = 1'b1;
		repeat (2) @ (posedge CLK);
		@(negedge CLK) #10;
		tests = tests + 1;
		if (n_PD !== 8'hFF) begin
			$display("FAIL Z_IR clear: n_PD=%02x, expected FF", n_PD);
			errors = errors + 1;
		end
		z_ir = 1'b0;

		// sweep all opcodes: present the opcode during PHI1, sample after PHI2
		for (op = 0; op < 256; op = op + 1) begin
			@(negedge CLK);
			data_val = op[7:0];
			@(posedge CLK) #10;		// PD latched during this PHI2
			// sample again mid-PHI1 of next cycle would show the captured value;
			// PD_latch is transparent during PHI2 while data is on the bus, so
			// sample right after the latch updates (same PHI2):
			tests = tests + 1;
			if (n_PD !== ~op[7:0]) begin
				$display("FAIL opcode %02x: n_PD=%02x, expected %02x", op, n_PD, ~op[7:0]);
				errors = errors + 1;
			end
			if (n_IMPLIED !== ~expected_implied(op[7:0])) begin
				$display("FAIL opcode %02x: n_IMPLIED=%b, expected %b", op, n_IMPLIED, ~expected_implied(op[7:0]));
				errors = errors + 1;
			end
			if (n_TWOCYCLE !== expected_twocycle(op[7:0])) begin
				$display("FAIL opcode %02x: n_TWOCYCLE=%b, expected %b", op, n_TWOCYCLE, expected_twocycle(op[7:0]));
				errors = errors + 1;
			end
		end

		if (errors == 0)
			$display("predecode_test: TEST PASS (%0d checks)", tests);
		else
			$display("predecode_test: TEST FAIL (%0d of %0d)", errors, tests);
		$finish;
	end

endmodule // predecode_test
