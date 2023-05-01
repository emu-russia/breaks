// Synthetic Length Counter testing

// Doing a full run at the ACLK frequency for LFO2 would be too long, so we simulate more frequent triggering of LFO2

// The purpose of the test is to load the value through the decoder and see what happens before the NoCount signal is triggered.

`timescale 1ns/1ns

module LengthCounter_Run();

	reg CLK;
	wire RES;
	wire ACLK1;
	wire nACLK2;
	reg WriteEnable;			// Used to load the initial value ($400x)
	reg W4015; 				// Used to enable the LC
	wire [7:0] DataBus;
	reg nLFO2; 					// Low frequency signal for LC counting
	wire NotCount; 			// That's the signal we're after (LC stopped counting)
	reg LC_Carry;

	always #25 CLK = ~CLK;

	assign RES = 1'b0;
	assign DataBus = 8'b01001_001;		// Used both for the enable bit value and for selecting the initial LC value (val=9 -> decoded as 0x07)

	AclkGenStandalone aclk (.CLK(CLK), .RES(RES), .nACLK2(nACLK2), .ACLK1(ACLK1) );

	wire [7:0] LC;

	LengthCounter_PLA pla (
		.DB(DataBus),
		.LC_Out(LC) );

	LengthCounter lc (
		.nACLK2(nACLK2),
		.ACLK1(ACLK1),
		.RES(RES),
		.W400x_load(WriteEnable),
		.n_R4015(1'b1),
		.W4015(W4015),
		.LC(LC),
		.dbit_ena(DataBus[0]),
		.nLFO2(nLFO2),
		.NotCount(NotCount),
		.Carry_in(LC_Carry));

	initial begin

		$dumpfile("length_counter.vcd");
		$dumpvars(0, lc);
		$dumpvars(1, aclk);

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

	always @ (negedge nACLK2)
		nLFO2 <= LC_Carry ? 1'b0 : 1'b1;
	always @ (posedge CLK)
		nLFO2 <= 1'b1;

endmodule // LengthCounter_Run
