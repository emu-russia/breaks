`timescale 1ns/1ns

module clock_test ();

	reg CLK;
	always #25 CLK = ~CLK;

	wire PHI1, PHI2, PHI1_topad, PHI2_topad;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2), .PHI1_topad(PHI1_topad), .PHI2_topad(PHI2_topad) );

	initial begin

		$dumpfile("clock_test.vcd");
		$dumpvars(0, clock_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // clock_test
