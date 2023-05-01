// With this test we are trying to get the Sweep Unit to generate the DO_SWEEP signal as it should be for the Sweep process to work.

// Here is an excerpt from our wiki describing the rather intricate logic of the Sweep Unit:

// By carefully examining and understanding all the signals that are used in the Sweep Unit you can get a picture of what is going on:
// - The main driver of the Sweep process is the DO_SWEEP signal. When this signal is activated the frequency modulation process in the Freq Reg is started using the shift register and the adder
// - The Sweep counter iterates with the low frequency oscillation signal `/LFO2`
// - The Sweep counter is overloaded by itself with the value from the Sweep Reg register, at the same time the DO_SWEEP signal is triggered (if all conditions are met, see below)

// Sweep does NOT occur under the following conditions (in the schematic it is a large NOR):
// - Sweep is disabled by the appropriate control register (SWDIS)
// - A square channel length counter has finished counting or has been disabled (NOSQ)
// - The magnitude value of the Shift Reg is 0 (SRZ)
// - Frequency value led to an overflow of the adder, in the frequency increase mode (SW_OVF)
// - Frequency value is less than 4 (SW_UVF)
// - Sweep counter has not completed its work (SCO=0)
// - Low-frequency oscillation signal is not active (/LFO2=1)

// That is, we need to organize the artificial generation of /LFO2 signal (not too slow, as in real conditions, to speed up the process)
// and check that the DO_SWEEP signal is generated as it should be.

// For this test it does not matter what happens to the Freq Reg, shifter, adder and all other parts of the square wave generator.

// The simulation of LFO generation is artificially tweaked to trigger more frequently.

`timescale 1ns/1ns

`define CoreCyclesPerCLK 6

module Square_Sweep_Run ();

	reg CLK;
	reg RES;
	wire PHI1;
	wire ACLK1;
	wire nACLK2;

	// Tune CLK/ACLK timing according to 2A03
	always #23.28 CLK = ~CLK;

	reg WR_Reg1; 		// Used to simulate writing to the Sweep registers by the "processor" (RegDriver)
	wire [7:0] DataBus;

	wire n_LFO2;

	wire DO_SWEEP; 			// The signal for which it is all about

	AclkGenStandalone aclk (.CLK(CLK), .RES(RES), .PHI1(PHI1), .nACLK2(nACLK2), .ACLK1(ACLK1) );

	BogusLFO lfo (.CLK(CLK), .RES(RES), .nACLK2(nACLK2), .LFO(n_LFO2) );

	RegDriver reg_driver (.PHI1(PHI1), .WR_Reg1(WR_Reg1), .DataBus(DataBus) );

	SQUARE_Sweep sweep_unit (
		.ACLK1(ACLK1), 
		.RES(RES), 
		.WR1(WR_Reg1), 
		.SR(3'b111),  		// Make a convenient value of the frequency shift magnitude so that the SRZ signal does not occur
		.DEC(1'b1),  		// Make decrement mode to ignore overflow 
		.n_COUT(1'b1), 		// Set the Adder output carry to a convenient value
		.SW_UVF(1'b0),		// Pretend that the frequency is greater than the minimum value (>= 4) 
		.NOSQ(1'b0),		// Pretend that the length counter is not stopped 
		.n_LFO2(n_LFO2), 	// Dummy accelerated LFO signal
		.DB(DataBus), 
		.DO_SWEEP(DO_SWEEP) );

	initial begin

		$dumpfile("square_sweep.vcd");
		$dumpvars(0, aclk);
		$dumpvars(1, sweep_unit);
		$dumpvars(2, DO_SWEEP);

		CLK <= 1'b0;
		RES <= 1'b0;
		WR_Reg1 <= 1'b0;

		// Perform a reset to reset the counter to zero

		RES <= 1'b1;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		RES <= 1'b0;

		// Set the initial values of the Sweep registers

		WR_Reg1 <= 1'b1;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		WR_Reg1 <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);

		// Continue the Sweep Unit and see in the .vcd what you get 

		repeat (2048) @ (posedge CLK);
		$finish;
	end

endmodule // Square_Sweep_Run

// This module executes a "program" sequence of writes to the SweepUnit registers
module RegDriver (PHI1, WR_Reg1, DataBus);

	input PHI1;
	input WR_Reg1;
	inout [7:0] DataBus;

	assign DataBus = ~PHI1 ? (WR_Reg1 ? 8'b11110001 : 8'hzz) : 8'hzz;	// Enable=1; Period=7; Negative=0; Shift=1 

endmodule // RegDriver
