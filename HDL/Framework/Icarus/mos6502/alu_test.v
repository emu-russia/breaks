`timescale 1ns/1ns

module alu_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	wire [7:0] SB, DB, ADL, ADH;
	wire ACR, AVR;

	ALU alu (
		.PHI2(PHI2),
		.NDB_ADD(1'b0), 
		.DB_ADD(1'b0), 
		.Z_ADD(1'b0), 
		.SB_ADD(1'b0), 
		.ADL_ADD(1'b0), 
		.ADD_SB06(1'b0), 
		.ADD_SB7(1'b0), 
		.ADD_ADL(1'b0),
		.ANDS(1'b0), 
		.EORS(1'b0), 
		.ORS(1'b0), 
		.SRS(1'b0), 
		.SUMS(1'b0), 
		.SB_AC(1'b0), 
		.AC_SB(1'b0), 
		.AC_DB(1'b0), 
		.SB_DB(1'b0), 
		.SB_ADH(1'b0), 
		.Z_ADH0(1'b0), 
		.Z_ADH17(1'b0),
		.n_ACIN(1'b1), 
		.n_DAA(1'b1), 
		.n_DSA(1'b1),
		.SB(SB), 
		.DB(DB), 
		.ADL(ADL), 
		.ADH(ADH),
		.ACR(ACR), 
		.AVR(AVR) );

	initial begin

		$dumpfile("alu_test.vcd");
		$dumpvars(0, alu_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // alu_test
