`timescale 1ns/1ns

module brk_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire BRK6E, BRK7, BRK5_RDY, DORES, n_DONMI, B_OUT;

	BRKProcessing brk (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.BRK5(1'b0), 
		.n_ready(1'b0), 
		.RESP(1'b0), 
		.n_NMIP(1'b1), 
		.BR2(1'b0), 
		.T0(1'b0), 
		.n_IRQP(1'b1), 
		.n_IOUT(1'b1),
		.BRK6E(BRK6E), 
		.BRK7(BRK7), 
		.BRK5_RDY(BRK5_RDY), 
		.DORES(DORES), 
		.n_DONMI(n_DONMI), 
		.B_OUT(B_OUT) );

	wire Z_ADL0, Z_ADL1, Z_ADL2;

	IntVector intaddr (
		.PHI2(PHI2),
		.BRK5_RDY(BRK5_RDY),
		.BRK7(BRK7),
		.DORES(DORES),
		.n_DONMI(n_DONMI),
		.Z_ADL0(Z_ADL0),
		.Z_ADL1(Z_ADL1),
		.Z_ADL2(Z_ADL2) );

	initial begin

		$dumpfile("brk_test.vcd");
		$dumpvars(0, brk_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // brk_test
