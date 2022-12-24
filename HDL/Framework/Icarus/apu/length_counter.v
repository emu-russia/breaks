// Synthetic Length Counter testing

// Doing a full run at the ACLK frequency for LFO2 would be too long, so we simulate more frequent triggering of LFO2

// The purpose of the test is to load the value through the decoder and see what happens before the NoCount signal is triggered.

`timescale 1ns/1ns

module LengthCounter_Run();

	reg CLK;
	wire RES;
	wire PHI0;
	wire PHI1;
	wire PHI2;
	wire ACLK;
	wire n_ACLK;
	reg WriteEnable;			// Used to load the initial value ($400x)
	reg W4015; 				// Used to enable the LC
	wire [7:0] DataBus;
	reg nLFO2; 					// Low frequency signal for LC counting
	wire NotCount; 			// That's the signal we're after (LC stopped counting)
	reg LC_Carry;

	always #25 CLK = ~CLK;

	assign RES = 1'b0;
	assign DataBus = 8'b01001_001;		// Used both for the enable bit value and for selecting the initial LC value (val=9 -> decoded as 0x07)

	// The ACLK pattern requires all of these "spares".

	CLK_Divider div (
		.n_CLK_frompad(~CLK),
		.PHI0_tocore(PHI0));

	BogusCorePhi phi (.PHI0(PHI0), .PHI1(PHI1), .PHI2(PHI2));

	ACLKGen clkgen (
		.PHI1(PHI1),
		.PHI2(PHI2),
		.ACLK(ACLK),
		.n_ACLK(n_ACLK),
		.RES(RES));

	LengthCounter lc (
		.ACLK(ACLK),
		.n_ACLK(n_ACLK),
		.RES(RES),
		.W400x_load(WriteEnable),
		.n_R4015(1'b1),
		.W4015(W4015),
		.DB(DataBus[7:0]),
		.dbit_ena(DataBus[0]),
		.nLFO2(nLFO2),
		.NotCount(NotCount),
		.Carry_in(LC_Carry));

	initial begin

		$dumpfile("length_counter.vcd");
		$dumpvars(0, lc);
		$dumpvars(1, clkgen);
		$dumpvars(2, div);

		CLK <= 1'b0;
		LC_Carry <= 1'b0;
		W4015 <= 1'b0;
		nLFO2 <= 1'b1;

		// Load initial value

		WriteEnable <= 1'b1;
		repeat (1) @ (posedge CLK);
		WriteEnable <= 1'b0;

		// Enable LC

		W4015 <= 1'b1;
		repeat (1) @ (posedge CLK);
		W4015 <= 1'b0;

		// Start counting

		LC_Carry <= 1'b1;

		repeat (256) @ (posedge CLK);
		$finish;
	end

	always @ (negedge ACLK)
		nLFO2 <= LC_Carry ? 1'b0 : 1'b1;
	always @ (posedge CLK)
		nLFO2 <= 1'b1;

endmodule // LengthCounter_Run

module BogusCorePhi (PHI0, PHI1, PHI2);
	
	input PHI0;
	output PHI1;
	output PHI2;

	assign PHI1 = ~PHI0;
	assign PHI2 = PHI0;

endmodule // BogusCorePhi
