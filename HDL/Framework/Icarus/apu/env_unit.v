// Testing the Envelope Unit.

// The simulation of LFO generation is artificially tweaked to trigger more frequently.

`timescale 1ns/1ns

module EnvUnit_Run();

	reg CLK;
	reg RES;
	wire RnW;
	wire ACLK1;
	wire nACLK2;

	wire [7:0] DataBus;
	wire n_LFO1;
	wire [3:0] VolOut;

	reg WR_Reg;
	reg WR_LC;

	// Tune CLK/ACLK timing according to 2A03
	always #23.28 CLK = ~CLK;

	assign DataBus = 8'hf;

	AclkGenStandalone aclk (.CLK(CLK), .RES(RES), .nACLK2(nACLK2), .ACLK1(ACLK1) );

	BogusLFO lfo (.CLK(CLK), .RES(RES), .nACLK2(nACLK2), .LFO(n_LFO1) );

	Envelope_Unit env_unit (.ACLK1(ACLK1), .RES(RES), .WR_Reg(WR_Reg), .WR_LC(WR_LC), .n_LFO1(n_LFO1), .DB(DataBus), .V(VolOut) );

	initial begin

		$dumpfile("env_unit.vcd");
		$dumpvars(0, env_unit);
		$dumpvars(1, aclk);

		CLK <= 1'b0;
		RES <= 1'b0;
		WR_Reg <= 1'b0;
		WR_LC <= 1'b0;

		WR_LC <= 1'b1;
		repeat (1) @ (posedge CLK);
		WR_LC <= 1'b0;

		WR_Reg <= 1'b1;
		repeat (1) @ (posedge CLK);
		WR_Reg <= 1'b0;

		repeat (32768) @ (posedge CLK);
		$finish;
	end

endmodule // EnvUnit_Run
