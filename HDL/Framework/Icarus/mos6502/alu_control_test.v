`timescale 1ns/1ns

module alu_control_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire INC_SB, SR, AND;

	ALU_Control alu_control (
		.PHI1(PHI1), 
		.PHI2(PHI2),
		.BRFW(1'b0), 
		.n_ready(1'b0), 
		.BRK6E(1'b0),
		.STKOP(1'b0), 
		.PGX(1'b0),
		.X({130{1'b0}}),
		.T0(1'b0),
		.T1(1'b0),
		.T6(1'b0),
		.T7(1'b0),
		.n_DOUT(1'b1),
		.n_COUT(1'b1),
		.INC_SB(INC_SB),
		.SR(SR),
		.AND(AND) );

	initial begin

		$dumpfile("alu_control_test.vcd");
		$dumpvars(0, alu_control_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // alu_control_test
