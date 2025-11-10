// The test runs a PPU simulation in a "spherical vacuum"
// To test as many PPU components as possible, the registers are configured directly to enable rendering at the beginning of the test.

`timescale 1ns/1ns

module PPU_Run();

	reg CLK;
	wire [7:0] cpu_db;
	wire [3:0] ext;

	// Tune CLK/PCLK timing according to 2C02/2C07
`ifdef RP2C02
	always #23.28 CLK = ~CLK;
`elsif RP2C07
	always #18.79 CLK = ~CLK;
`else
	always #1 CLK = ~CLK;
`endif

	PPU ppu (
		.RnW(1'b1),
		.D(cpu_db),
		.RS(3'b0),
		.n_DBE(1'b1),
		.EXT(ext),
		.CLK(CLK),
		.n_RES(1'b1));

	initial begin

`ifdef RP2C02
		$dumpfile("ppu_ntsc.vcd");
`elsif RP2C07
		$dumpfile("ppu_pal.vcd");
`else
		$display("wtf?");
		$finish;
`endif
		$dumpvars(0, PPU_Run);

		CLK <= 1'b0;

		// Run the number of cycles sufficient to capture the full field.

`ifdef RP2C02
		//repeat (2048 * 262) @ (posedge CLK);
		repeat (2048 * 2) @ (posedge CLK);
`elsif RP2C07
		repeat (2048 * 312) @ (posedge CLK);
`else
`endif
		$finish;
	end

endmodule
