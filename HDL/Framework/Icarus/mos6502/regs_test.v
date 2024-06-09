`timescale 1ns/1ns

module regs_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire [7:0] SB, ADL;

	Regs regs (
		.PHI2(PHI2),
		.Y_SB(1'b0),
		.SB_Y(1'b0), 
		.X_SB(1'b0), 
		.SB_X(1'b0), 
		.S_SB(1'b0), 
		.S_ADL(1'b0), 
		.S_S(1'b1), 
		.SB_S(1'b0), 
		.SB(SB), 
		.ADL(ADL) );

	initial begin

		$dumpfile("regs_test.vcd");
		$dumpvars(0, regs_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // regs_test
