`timescale 1ns/1ns

module flags_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire [7:0] DB;

	Flags flags (
		.PHI1(PHI1), 
		.PHI2(PHI2),
		.P_DB(1'b0), 
		.DB_P(1'b0), 
		.DBZ_Z(1'b0), 
		.DB_N(1'b0), 
		.IR5_C(1'b0), 
		.DB_C(1'b0), 
		.ACR_C(1'b0), 
		.IR5_D(1'b0), 
		.IR5_I(1'b0), 
		.DB_V(1'b0), 
		.Z_V(1'b0),
		.ACR(1'b0), 
		.AVR(1'b0), 
		.B_OUT(1'b0), 
		.n_IR5(1'b0), 
		.BRK6E(1'b0), 
		.Dec112(1'b0), 
		.SO_frompad(1'b0), 
		.DB(DB) );

	initial begin

		$dumpfile("flags_test.vcd");
		$dumpvars(0, flags_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // flags_test
