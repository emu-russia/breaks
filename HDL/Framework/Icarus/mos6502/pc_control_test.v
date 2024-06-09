`timescale 1ns/1ns

module pc_control_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	PC_Control pc_control (
		.PHI1(PHI1), 
		.PHI2(PHI2),
		.n_ready(1'b0), 
		.T0(1'b0), 
		.T1(1'b0), 
		.BR0(1'b0),
		.X({130{1'b0}}) );

	initial begin

		$dumpfile("pc_control_test.vcd");
		$dumpvars(0, pc_control_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // pc_control_test
