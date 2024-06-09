`timescale 1ns/1ns

module branch_logic_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire [7:0] DB;
	wire n_BRTAKEN, BRFW;

	BranchLogic branch_logic (
		.PHI1(PHI1), 
		.PHI2(PHI2),
		.n_IR5(1'b1), 
		.X({130{1'b0}}), 
		.n_COUT(1'b1), 
		.n_VOUT(1'b1), 
		.n_NOUT(1'b1), 
		.n_ZOUT(1'b1), 
		.DB(DB), 
		.BR2(1'b0),
		.n_BRTAKEN(n_BRTAKEN), 
		.BRFW(BRFW) );

	initial begin

		$dumpfile("branch_logic_test.vcd");
		$dumpvars(0, branch_logic_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // branch_logic_test
