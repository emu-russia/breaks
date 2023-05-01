// Check the DUTY signal generation, depending on the different Duty register settings and Duty counter values

// The generation of the FLOAD signal (to iterate the Duty counter) is artificially accelerated.

`timescale 1ns/1ns

`define CoreCyclesPerCLK 6

module Square_Duty_Run ();

	reg CLK;
	reg RES;
	wire PHI1;
	wire ACLK1;
	wire nACLK2;

	// Tune CLK/ACLK timing according to 2A03
	always #23.28 CLK = ~CLK;

	reg WR0;				// Used to load the Duty setting into the appropriate register
	wire [7:0] DataBus;
	reg [1:0] duty_mode;

	wire DUTY; 		// The signal for which the test is performed

	AclkGenStandalone aclk (.CLK(CLK), .RES(RES), .PHI1(PHI1), .nACLK2(nACLK2), .ACLK1(ACLK1) );

	RegDriver reg_driver (.PHI1(PHI1), .WR0(WR0), .duty_mode(duty_mode), .DataBus(DataBus) );

	SQUARE_Duty duty_unit (
		.ACLK1(ACLK1), 
		.RES(RES), 
		.FLOAD(~ACLK1 & ~WR0), 	// Make the counter always step complementary to the Keep state (ACLK1)
		.FCO(1'b1), 			// Make the input carry always active for continuous counting. In reality the carry is activated only when the frequency counter counts are completed.
		.WR0(WR0), 
		.WR3(1'b0), 			// This test does not check the clearing of the Duty counter when writing to the length counter
		.DB(DataBus), 
		.DUTY(DUTY) );

	initial begin

		$dumpfile("square_duty.vcd");
		$dumpvars(0, aclk);
		$dumpvars(1, duty_unit);
		$dumpvars(2, DUTY);
		$dumpvars(3, duty_mode);

		CLK <= 1'b0;
		RES <= 1'b0;
		WR0 <= 1'b0;

		// Check Duty = 2

		duty_mode <= 2'b10;
		WR0 <= 1'b1;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		WR0 <= 1'b0;
		repeat (192) @ (posedge CLK);

		$finish;
	end

endmodule // Square_Duty_Run

// This module executes a "program" sequence of writes to the Duty register
module RegDriver (PHI1, WR0, duty_mode, DataBus);

	input PHI1;
	input WR0;
	input [1:0] duty_mode;
	inout [7:0] DataBus;

	assign DataBus = ~PHI1 ? (WR0 ? {duty_mode[1:0],6'b000000} : 8'hzz) : 8'hzz;

endmodule // RegDriver
