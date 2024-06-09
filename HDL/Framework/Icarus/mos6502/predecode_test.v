`timescale 1ns/1ns

module predecode_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire [7:0] Data_bus, n_PD;
	wire n_IMPLIED, n_TWOCYCLE;

	PreDecode predecode (
		.PHI2(PHI2),
		.Z_IR(1'b0),
		.Data_bus(Data_bus), 
		.n_PD(n_PD),
		.n_IMPLIED(n_IMPLIED), 
		.n_TWOCYCLE(n_TWOCYCLE) );

	initial begin

		$dumpfile("predecode_test.vcd");
		$dumpvars(0, predecode_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // predecode_test
