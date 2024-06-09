`timescale 1ns/1ns

module regs_control_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire STXY, n_SBXY, STKOP;

	Regs_Control regs_control (
		.PHI1(PHI1), 
		.PHI2(PHI2), 
		.STOR(1'b0), 
		.n_ready(1'b0), 
		.X({130{1'b0}}),
		.STXY(STXY), 
		.n_SBXY(n_SBXY), 
		.STKOP(STKOP) );

	initial begin

		$dumpfile("regs_control_test.vcd");
		$dumpvars(0, regs_control_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // regs_control_test
