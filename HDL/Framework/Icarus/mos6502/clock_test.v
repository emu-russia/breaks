
`timescale 1ns/1ns

module clock_test ();

	reg CLK;
	always #1 CLK = ~CLK;

	initial begin

		$dumpfile("clock_test.vcd");
		$dumpvars(0, clock_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // clock_test
