// A unit test for checking APU Clock Trees.

// Just do a few iterations with reset, then no reset.

`timescale 1ns/1ns

module APU_ClkGen_WithReset_Run();

	reg CLK;
	reg n_RES;
	reg n_IRQ;
	reg n_NMI;
	wire [15:0] AddrPads;
	wire [7:0] DataPads;
	wire M2_Out;
	wire RnW_fromapu;
	wire [1:0] nIN_Ports;
	wire [2:0] OUT_Ports;

	always #25 CLK = ~CLK;

	APU apu (
		.n_RES(n_RES),
		.A(AddrPads),
		.D(DataPads),
		.CLK(CLK),
		.DBG(1'b0),
		.M2(M2_Out),
		.n_IRQ(n_IRQ),
		.n_NMI(n_NMI),
		.RnW(RnW_fromapu),
		.n_IN0(nIN_Ports[0]),
		.n_IN1(nIN_Ports[1]),
		.OUT0(OUT_Ports[0]),
		.OUT1(OUT_Ports[1]),
		.OUT2(OUT_Ports[2]) );

	initial begin

		$display("Test APU clocks with reset");

		$dumpfile("clkgen_with_reset.vcd");
		$dumpvars(0, apu);

		CLK <= 1'b0;
		n_IRQ <= 1'b1;
		n_NMI <= 1'b1;

		n_RES <= 1'b0;
		repeat (32) @ (posedge CLK);

		n_RES <= 1'b1;
		repeat (32) @ (posedge CLK);

		$finish(0);
	end

	//always @(CLK)
	//	$display("CLK=%b, PHI0=%b, PHI1=%b, PHI2=%b, ACLK1=%b, nACLK2=%b",
	//		CLK, apu.PHI0, apu.PHI0, apu.PHI1, apu.ACLK1, apu.nACLK2);	

endmodule // APU_ClkGen_WithReset_Run
