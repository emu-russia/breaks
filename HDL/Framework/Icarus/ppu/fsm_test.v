// Check if the FSM is working properly.

// From the base PPU sources only a minimalistic set is used: PCLK, H/V counters with decoders and the FSM itself.
// We call this setup: "PPU Zero"

`timescale 1ns/1ns

module FSM_Run ();

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

	// There is no need to connect all FSM output signals, they will be perfectly visible in the .vcd dump

	PPU_FSM fsm (
		.n_PCLK(n_PCLK), .PCLK(PCLK),
		.H_out(HCnt), .V_out(VCnt), .HPLA_out(HDecoder_out), .VPLA_out(VDecoder_out),
		.RES(RES), .VBL_EN(1'b0), .n_R2(1'b1), .n_DBE(1'b1), .n_OBCLIP(1'b0), .n_BGCLIP(1'b0), .BLACK(1'b0),
		.VB(VB), .BLNK(BLNK),
		.V_IN(V_IN), .HC(HC), .VC(VC) );

	initial begin

`ifdef RP2C02
		$dumpfile("fsm_test_ntsc.vcd");
`elsif RP2C07
		$dumpfile("fsm_test_pal.vcd");
`else
		$display("wtf?");
		$finish;
`endif
		$dumpvars(0, FSM_Run);

		CLK <= 1'b0;
		RES <= 1'b0;

		// Run the number of cycles sufficient to capture the full field.

`ifdef RP2C02
		repeat (2048 * 262) @ (posedge CLK);
`elsif RP2C07
		repeat (2048 * 312) @ (posedge CLK);
`else
`endif
		$finish;
	end

endmodule // FSM_Run
