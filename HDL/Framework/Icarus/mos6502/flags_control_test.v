`timescale 1ns/1ns

module flags_control_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	Flags_Control flags_control (
		.PHI2(PHI2), 
		.X({130{1'b0}}),
		.T7(1'b0), 
		.ZTST(1'b0), 
		.n_ready(1'b1), 
		.SR(1'b0) );

	initial begin

		$dumpfile("flags_control_test.vcd");
		$dumpvars(0, flags_control_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // flags_control_test
