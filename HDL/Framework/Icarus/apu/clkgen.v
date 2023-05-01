// A unit test for checking APU Clock Trees.

// The idea is simple. We start a negedge counter for the CLK and check the transit of child clocks.

`timescale 1ns/1ns

module APU_ClkGen_Run();

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

	reg [7:0] clk_cnt;

	initial begin

		$display("Test APU clocks");

		CLK <= 1'b0;
		n_RES <= 1'b1;
		n_IRQ <= 1'b1;
		n_NMI <= 1'b1;

		clk_cnt <= 0;

		$dumpfile("clkgen.vcd");
		$dumpvars(0, apu);

		repeat (32) @ (posedge CLK);
		$display("All pass");
		$finish(0);
	end

	// Clock boundary scan

	always @(posedge CLK) begin
		clk_cnt = clk_cnt + 1;
	end

	always @(negedge CLK) begin

		// PHI first half-cycle

		if (clk_cnt == 6 && apu.PHI0 != 1) begin
			$display("PHI0 failed!");
			$finish(1);
		end
		if (clk_cnt == 7 && apu.PHI0 != 0) begin
			$display("PHI0 failed!");
			$finish(1);
		end

		if (clk_cnt == 6 && apu.PHI1 != 0) begin
			$display("PHI1 failed!");
			$finish(1);
		end
		if (clk_cnt == 7 && apu.PHI1 != 1) begin
			$display("PHI1 failed!");
			$finish(1);
		end

		if (clk_cnt == 6 && apu.PHI2 != 1) begin
			$display("PHI2 failed!");
			$finish(1);
		end
		if (clk_cnt == 7 && apu.PHI2 != 0) begin
			$display("PHI2 failed!");
			$finish(1);
		end

		// PHI second half-cycle

		if (clk_cnt == 12 && apu.PHI0 != 0) begin
			$display("PHI0 failed!");
			$finish(1);
		end
		if (clk_cnt == 13 && apu.PHI0 != 1) begin
			$display("PHI0 failed!");
			$finish(1);
		end

		if (clk_cnt == 12 && apu.PHI1 != 1) begin
			$display("PHI1 failed!");
			$finish(1);
		end
		if (clk_cnt == 13 && apu.PHI1 != 0) begin
			$display("PHI1 failed!");
			$finish(1);
		end

		if (clk_cnt == 12 && apu.PHI2 != 0) begin
			$display("PHI2 failed!");
			$finish(1);
		end
		if (clk_cnt == 13 && apu.PHI2 != 1) begin
			$display("PHI2 failed!");
			$finish(1);
		end

		// ACLK1 Low->High 1st

		if (clk_cnt == 6 && apu.ACLK1 != 0) begin
			$display("ACLK1 failed!");
			$finish(1);
		end
		if (clk_cnt == 7 && apu.ACLK1 != 1) begin
			$display("ACLK1 failed!");
			$finish(1);
		end

		// ACLK1 High->Low

		if (clk_cnt == 12 && apu.ACLK1 != 1) begin
			$display("ACLK1 failed!");
			$finish(1);
		end
		if (clk_cnt == 13 && apu.ACLK1 != 0) begin
			$display("ACLK1 failed!");
			$finish(1);
		end

		// ACLK1 Low->High 2nd

		if (clk_cnt == 30 && apu.ACLK1 != 0) begin
			$display("ACLK1 failed!");
			$finish(1);
		end
		if (clk_cnt == 31 && apu.ACLK1 != 1) begin
			$display("ACLK1 failed!");
			$finish(1);
		end

		// #ACLK2 High->Low

		if (clk_cnt == 18 && apu.nACLK2 != 1) begin
			$display("#ACLK2 failed!");
			$finish(1);
		end
		if (clk_cnt == 19 && apu.nACLK2 != 0) begin
			$display("#ACLK2 failed!");
			$finish(1);
		end

		// #ACLK2 Low->High

		if (clk_cnt == 24 && apu.nACLK2 != 0) begin
			$display("#ACLK2 failed!");
			$finish(1);
		end
		if (clk_cnt == 25 && apu.nACLK2 != 1) begin
			$display("#ACLK2 failed!");
			$finish(1);
		end

	end	

	//always @(CLK)
	//	$display("CLK=%b, clkcnt=%d, PHI0=%b, PHI1=%b, PHI2=%b, ACLK1=%b, nACLK2=%b",
	//		CLK, clk_cnt, apu.PHI0, apu.PHI0, apu.PHI1, apu.ACLK1, apu.nACLK2);	

endmodule // APU_ClkGen_Run
