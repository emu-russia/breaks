// APU Test Bench for iverilog

`timescale 1ns/1ns

module APU_Run();

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

	// Tune CLK/ACLK timing according to 2A03
	always #23.28 CLK = ~CLK;

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

		$display("Check that the APU is moving.");

		CLK <= 1'b0;
		n_RES <= 1'b1;
		n_IRQ <= 1'b1;
		n_NMI <= 1'b1;

		$dumpfile("apu.vcd");
		$dumpvars(0, apu);

		repeat (32768 * 16) @ (posedge CLK);
		$finish;
	end

endmodule // APU_Run
