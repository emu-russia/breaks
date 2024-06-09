
`timescale 1ns/1ns

module pc_control_test ();

	reg CLK;
	always #1 CLK = ~CLK;

	initial begin

		$dumpfile("pc_control_test.vcd");
		$dumpvars(0, pc_control_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // pc_control_test
