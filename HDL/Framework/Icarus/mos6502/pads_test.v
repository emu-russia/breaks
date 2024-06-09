`timescale 1ns/1ns

module pads_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	PadsLogic pads (
		.PHI1(PHI1), 
		.PHI2(PHI2),
		.n_NMI(1'b1), 
		.n_IRQ(1'b1), 
		.n_RES(1'b1), 
		.RDY(1'b1),  
		.T1_topad(1'b0),  
		.SO(1'b1), 
		.WR_topad(1'b0) );

	initial begin

		$dumpfile("pads_test.vcd");
		$dumpvars(0, pads_test);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // pads_test
