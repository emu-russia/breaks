
`timescale 1ns/1ns

module flags_test ();

	reg CLK;
	always #1 CLK = ~CLK;

	initial begin

		$dumpfile("flags_test.vcd");
		$dumpvars(0, flags_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // flags_test
