
`timescale 1ns/1ns

module pads_test ();

	reg CLK;
	always #1 CLK = ~CLK;

	initial begin

		$dumpfile("pads_test.vcd");
		$dumpvars(0, pads_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // pads_test
