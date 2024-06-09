
`timescale 1ns/1ns

module brk_test ();

	reg CLK;
	always #1 CLK = ~CLK;

	initial begin

		$dumpfile("brk_test.vcd");
		$dumpvars(0, brk_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // brk_test
