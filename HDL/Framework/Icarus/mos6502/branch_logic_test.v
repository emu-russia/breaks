
`timescale 1ns/1ns

module branch_logic_test ();

	reg CLK;
	always #1 CLK = ~CLK;

	initial begin

		$dumpfile("branch_logic_test.vcd");
		$dumpvars(0, branch_logic_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // branch_logic_test
