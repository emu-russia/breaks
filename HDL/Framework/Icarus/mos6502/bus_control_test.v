
`timescale 1ns/1ns

module bus_control_test ();

	reg CLK;
	always #1 CLK = ~CLK;

	initial begin

		$dumpfile("bus_control_test.vcd");
		$dumpvars(0, bus_control_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // bus_control_test
