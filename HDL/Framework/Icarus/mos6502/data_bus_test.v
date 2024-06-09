
`timescale 1ns/1ns

module data_bus_test ();

	reg CLK;
	always #1 CLK = ~CLK;

	initial begin

		$dumpfile("data_bus_test.vcd");
		$dumpvars(0, data_bus_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // data_bus_test
