`timescale 1ns/1ns

module bus_control_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire ZTST, PGX;

	Bus_Control bus_control (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.n_SBXY(1'b1), 
		.AND(1'b0), 
		.STOR(1'b0), 
		.Z_ADL0(1'b0), 
		.ACRL2(1'b0), 
		.DL_PCH(1'b0), 
		.n_ready(1'b0), 
		.INC_SB(1'b0), 
		.BRK6E(1'b0), 
		.STXY(1'b0), 
		.n_PCH_PCH(1'b1),
		.T0(1'b0), 
		.T1(1'b0), 
		.T6(1'b0), 
		.T7(1'b0), 
		.BR0(1'b0), 
		.X({130{1'b0}}),
		.ZTST(ZTST), 
		.PGX(PGX) );

	initial begin

		$dumpfile("bus_control_test.vcd");
		$dumpvars(0, bus_control_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // bus_control_test
