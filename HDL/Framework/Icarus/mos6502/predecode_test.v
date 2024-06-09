
`timescale 1ns/1ns

module predecode_test ();

	reg CLK;
	always #1 CLK = ~CLK;

	initial begin

		$dumpfile("predecode_test.vcd");
		$dumpvars(0, predecode_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // predecode_test
