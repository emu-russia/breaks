`timescale 1ns/1ns

module pc_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire [7:0] ADL, ADH, DB;

	PC pc (
		.PHI2(PHI2),
		.n_IPC(1'b0),
		.ADL_PCL(1'b0), 
		.PCL_PCL(1'b1), 
		.PCL_ADL(1'b0), 
		.PCL_DB(1'b0), 
		.ADH_PCH(1'b0), 
		.PCH_PCH(1'b1), 
		.PCH_ADH(1'b0), 
		.PCH_DB(1'b0),
		.ADL(ADL), 
		.ADH(ADH), 
		.DB(DB) );

	initial begin

		$dumpfile("pc_test.vcd");
		$dumpvars(0, pc_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // pc_test
