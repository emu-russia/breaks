// Address bus output terminal + AB register self-check.
// AddrBusBit samples ADX when ADX_ABX=1 during PHI1 and holds the value
// through the rest of the cycle (PHI2). The register itself is a dynamic
// NMOS FF: transparent while (ADX_ABX & PHI1), otherwise holding.
//
// Checks both the load and the hold phases, i.e. it also guards the
// behavioral ICARUS model of AddrBusFF. Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module addr_bus_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	reg ADX;
	reg ADX_ABX;
	wire ABus_out;

	AddrBusBit ab (
		.PHI1(PHI1), .PHI2(PHI2),
		.ADX(ADX), .ADX_ABX(ADX_ABX),
		.ABus_out(ABus_out) );

	integer errors = 0;

	task expect;
		input [159:0] what;
		input exp;
		begin
			if (ABus_out !== exp) begin
				$display("FAIL %0s: ABus_out=%b, expected %b", what, ABus_out, exp);
				errors = errors + 1;
			end
		end
	endtask

	initial begin
		$dumpfile("addr_bus_test.vcd");
		$dumpvars(0, addr_bus_test);

		CLK <= 1'b0;
		ADX <= 1'b0;
		ADX_ABX <= 1'b0;
		repeat (2) @(posedge CLK);

		// 1) Load 1: enable during PHI1 with ADX=1
		@(negedge CLK);
		ADX_ABX <= 1'b1;
		ADX <= 1'b1;
		@(posedge CLK) #10;
		expect("load 1", 1'b1);

		// 2) Load 0
		@(negedge CLK);
		ADX <= 1'b0;
		@(posedge CLK) #10;
		expect("load 0", 1'b0);

		// 3) Hold 0 while ADX=1 (en off during the whole PHI1)
		@(negedge CLK);
		ADX_ABX <= 1'b0;
		ADX <= 1'b1;
		#5;		// mid-PHI1: no load should have happened
		expect("hold PHI1", 1'b0);
		@(posedge CLK) #10;
		expect("hold PHI2", 1'b0);

		// 4) Hold 0 while ADX=0
		@(negedge CLK);
		ADX <= 1'b0;
		@(posedge CLK) #10;
		expect("hold 0b", 1'b0);

		// 5) Load 1 again
		@(negedge CLK);
		ADX_ABX <= 1'b1;
		ADX <= 1'b1;
		@(posedge CLK) #10;
		expect("load 1 again", 1'b1);

		// 6) Load 0 again
		@(negedge CLK);
		ADX <= 1'b0;
		@(posedge CLK) #10;
		expect("load 0 again", 1'b0);

		if (errors == 0)
			$display("addr_bus_test: TEST PASS");
		else
			$display("addr_bus_test: TEST FAIL (%0d errors)", errors);
		$finish;
	end

endmodule // addr_bus_test
