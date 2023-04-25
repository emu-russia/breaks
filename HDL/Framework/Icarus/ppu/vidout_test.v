// Check the operation of the video signal generator (digital and analog part)

`timescale 1ns/1ns

module VidOut_Run ();

	reg CLK;
	reg RES;

	wire PCLK;
	wire n_PCLK;

	wire [8:0] HCnt;
	wire [8:0] VCnt;
	wire [23:0] HDecoder_out;
	wire [9:0] VDecoder_out;

	wire HC;
	wire VC;
	wire V_IN;
	wire VB;
	wire BLNK;

	// Tune CLK/PCLK timing according to 2C02/2C07
`ifdef RP2C02
	always #23.28 CLK = ~CLK;
`elsif RP2C07
	always #18.79 CLK = ~CLK;
`else
	always #1 CLK = ~CLK;
`endif

	PixelClock pclk (
		.n_CLK(~CLK), .CLK(CLK), .RES(RES),
		.n_PCLK(n_PCLK), .PCLK(PCLK) );

	HVCounters hv (
		.n_PCLK(n_PCLK), .PCLK(PCLK),
		.RES(RES), .HC(HC), .VC(VC), .V_IN(V_IN),
		.H_out(HCnt), .V_out(VCnt) );

	HVDecoder dec (
		.H_in(HCnt), .V_in(VCnt), .VB(VB), .BLNK(BLNK),
		.HPLA_out(HDecoder_out), .VPLA_out(VDecoder_out) );

	// VideoGen

	wire [10:0] RawVOut;

	VideoGen vidgen (
		.n_CLK(~CLK), .CLK(CLK), .n_PCLK(n_PCLK), .PCLK(PCLK), 
		.RES(RES),
		.n_CC(4'b0100), .n_LL(2'b00),
		.BURST(1'b0), .SYNC(1'b0), .n_PICTURE(1'b0), 
		.n_TR(1'b0), .n_TG(1'b0), .n_TB(1'b0), 
`ifdef RP2C07
		.V0(VCnt[0]),
`endif
		.RawVOut(RawVOut) );

	initial begin

		$dumpfile("vidout_test.vcd");
		$dumpvars(0, VidOut_Run);

		CLK <= 1'b0;
		RES <= 1'b0;

		// Run the number of cycles

		repeat (1000) @ (posedge CLK);
		$finish;
	end

endmodule // VidOut_Run
