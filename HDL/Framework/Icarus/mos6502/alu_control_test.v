
`timescale 1ns/1ns

module alu_control_test ();

	reg CLK;
	always #1 CLK = ~CLK;

	initial begin

		$dumpfile("alu_control_test.vcd");
		$dumpvars(0, alu_control_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // alu_control_test
