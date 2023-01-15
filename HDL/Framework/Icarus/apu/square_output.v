// Testing the output of a square wave generator.

// From the main APU "honestly" simulated: ACLK and LFO, the length counter and the whole Square block. 

`timescale 1ns/1ns

`define CoreCyclesPerCLK 6

module Square_Run ();

	// Timing
	reg CLK;
	reg RES;
	wire PHI1;
	wire ACLK;
	wire n_ACLK;
	wire nLFO1;
	wire nLFO2;

	// Regs
	reg W4000;
	reg W4001;
	reg W4002;
	reg W4003;
	reg W4015;
	reg W4017;
	reg n_R4015;
	wire [7:0] DataBus;

	// Tune CLK/ACLK timing according to 2A03
	always #23.28 CLK = ~CLK;

	// Modules for organizing the correct operation of ACLK and LFO

	CLK_Divider div (.n_CLK_frompad(~CLK), .PHI0_tocore(PHI0), .PHI2_fromcore(PHI2) );
	
	BogusCPU core (.PHI0(PHI0), .PHI1(PHI1), .PHI2(PHI2) );

	ACLKGen aclk (.PHI1(PHI1), .PHI2(PHI2), .ACLK(ACLK), .n_ACLK(n_ACLK), .RES(RES) );

	SoftTimer softclk (
		.PHI1(PHI1), .n_ACLK(n_ACLK), .ACLK(ACLK),
		.RES(RES), .n_R4015(n_R4015), .W4017(W4017), .DB(DataBus), .DMCINT(1'b0), .nLFO1(nLFO1), .nLFO2(nLFO2) );

	// Modules for the square sound generator (simulate Square0 channel for Adder carry mode)

	wire [7:0] LC;
	wire SQ_LC;
	wire NOSQ;
	wire [3:0] SQ_Out;

	LengthCounter_PLA pla (
		.DB(DataBus),
		.LC_Out(LC) );

	LengthCounter length (
		.ACLK(ACLK), .n_ACLK(n_ACLK),
		.RES(RES), .W400x_load(W4003), .n_R4015(n_R4015), .W4015(W4015), .LC(LC), .dbit_ena(DataBus[0]), .nLFO2(nLFO2),
		.Carry_in(SQ_LC), .NotCount(NOSQ) );

	SquareChan square (
		.ACLK(ACLK), .n_ACLK(n_ACLK), 
		.RES(RES), .DB(DataBus), .WR0(W4000), .WR1(W4001), .WR2(W4002), .WR3(W4003),
		.nLFO1(nLFO1), .nLFO2(nLFO2), .SQ_LC(SQ_LC), .NOSQ(NOSQ), .LOCK(1'b0),
		.AdderCarryMode(1'b0),			// Adder n_carry = INC
		.SQ_Out(SQ_Out) );

	initial begin

		$dumpfile("square_output.vcd");
		$dumpvars(0, div);
		$dumpvars(1, core);
		$dumpvars(2, aclk);
		$dumpvars(3, softclk);
		$dumpvars(4, pla);
		$dumpvars(5, length);
		$dumpvars(6, square);

		CLK <= 1'b0;
		RES <= 1'b0;

		W4000 <= 1'b0;
		W4001 <= 1'b0;
		W4002 <= 1'b0;
		W4003 <= 1'b0;
		W4015 <= 1'b0;
		W4017 <= 1'b0;
		n_R4015 <= 1'b1;

		// Configure the registers of the entire system

		// Run the simulation in free flight to obtain sound

		repeat (32768 * 1) @ (posedge CLK);
		$finish;
	end

endmodule //  Square_Run

// Simulation of the processor, to get a PHI1/2.
module BogusCPU (PHI0, PHI1, PHI2);

	input PHI0;
	output PHI1;
	output PHI2;

	assign PHI1 = ~PHI0;
	assign PHI2 = PHI0;

endmodule // BogusCPU
