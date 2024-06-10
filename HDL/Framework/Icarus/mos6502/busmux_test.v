`timescale 1ns/1ns

module busmux_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire [7:0] SB, DB, ADL, ADH;

	BusMux busmux (
		.PHI2(PHI2),
		.SB(SB),
		.DB(DB),
		.ADL(ADL),
		.ADH(ADH),
		.Z_ADL0(1'b0),
		.Z_ADL1(1'b0),
		.Z_ADL2(1'b0),
		.Z_ADH0(1'b0),
		.Z_ADH17(1'b0),
		.SB_DB(1'b0),
		.SB_ADH(1'b0) );

	initial begin

		$dumpfile("busmux_test.vcd");
		$dumpvars(0, busmux_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // busmux_test
