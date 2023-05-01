// Testing the output of a square wave generator.

// From the main APU "honestly" simulated: ACLK and LFO, the length counter and the whole sound channel block.

//⚠️ The register write simulation (RegOps) takes place in a redundant mode, because no alignment cycles are required to write the registers of the audio generators.

`timescale 1ns/1ns

`define CoreCyclesPerCLK 6

module Square_Run ();

	// Timing
	reg CLK;
	reg RES;
	wire PHI1;
	wire ACLK1;
	wire nACLK2;
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

	wire [31:0] AuxOut;

	// Tune CLK/ACLK timing according to 2A03
	always #23.28 CLK = ~CLK;

	// Modules for organizing the correct operation of ACLK and LFO

	CLK_Divider div (.n_CLK_frompad(~CLK), .PHI0_tocore(PHI0), .PHI2_fromcore(PHI2) );
	
	BogusCPU core (.PHI0(PHI0), .PHI1(PHI1), .PHI2(PHI2) );

	ACLKGen aclk (.PHI1(PHI1), .PHI2(PHI2), .nACLK2(nACLK2), .ACLK1(ACLK1), .RES(RES) );

	SoftTimer softclk (
		.PHI1(PHI1), .ACLK1(ACLK1), .nACLK2(nACLK2),
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
		.nACLK2(nACLK2), .ACLK1(ACLK1),
		.RES(RES), .W400x_load(W4003), .n_R4015(n_R4015), .W4015(W4015), .LC(LC), .dbit_ena(DataBus[0]), .nLFO2(nLFO2),
		.Carry_in(SQ_LC), .NotCount(NOSQ) );

	SquareChan square (
		.nACLK2(nACLK2), .ACLK1(ACLK1), 
		.RES(RES), .DB(DataBus), .WR0(W4000), .WR1(W4001), .WR2(W4002), .WR3(W4003),
		.nLFO1(nLFO1), .nLFO2(nLFO2), .SQ_LC(SQ_LC), .NOSQ(NOSQ), .LOCK(1'b0),
		.AdderCarryMode(1'b0),			// Adder n_carry = INC
		.SQ_Out(SQ_Out) );

	AUX aux (.AUX_A({4'b0000,SQ_Out}), .AUX_B(15'b0000000_0000_0000), .AOut(AuxOut) );

	RegDriver reg_driver (.PHI1(PHI1), .W4000(W4000), .W4001(W4001), .W4002(W4002), .W4003(W4003), .W4015(W4015), .DataBus(DataBus) );

	initial begin

		$dumpfile("square_output.vcd");
		$dumpvars(0, div);
		$dumpvars(1, core);
		$dumpvars(2, aclk);
		$dumpvars(3, softclk);
		$dumpvars(4, pla);
		$dumpvars(5, length);
		$dumpvars(6, square);
		$dumpvars(7, AuxOut);

		CLK <= 1'b0;
		RES <= 1'b0;

		W4000 <= 1'b0;
		W4001 <= 1'b0;
		W4002 <= 1'b0;
		W4003 <= 1'b0;
		W4015 <= 1'b0;
		W4017 <= 1'b0;
		n_R4015 <= 1'b1;

		// Reset

		RES <= 1'b1;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		RES <= 1'b0;

		// Configure the registers of the entire system

		W4015 <= 1'b1;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		W4015 <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);

		W4000 <= 1'b1;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		W4000 <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);

		W4001 <= 1'b1;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		W4001 <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);

		W4002 <= 1'b1;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		W4002 <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);

		W4003 <= 1'b1;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		W4003 <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);

		// Run the simulation in free flight to obtain sound

		repeat (32768 * 128) @ (posedge CLK);
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

// This module executes a "program" sequence of writes to various registers
module RegDriver (PHI1, W4000, W4001, W4002, W4003, W4015, DataBus);

	input PHI1;
	input W4000;
	input W4001;
	input W4002;
	input W4003;
	input W4015;
	inout [7:0] DataBus;

	// W4015 <= 0000000 1  (SQA Length counter enable: 1)
	// W4000 <= 10 0 0 0110 (D=2, Length Counter #carry in=0, ConstVol=0, Vol=6)
	// W4001 <= 1 001 0 010 (Sweep=1, Period=1, Negative=0, Magnitude=2^2)
	// W4002 <= 0110 1001  (Freq Lo=0x69)
	// W4003 <= 11111 010  (Length=11111, Freq Hi=2)

	assign DataBus = ~PHI1 ? (W4000 ? 8'b10000110 : (W4001 ? 8'b10010010 : (W4002 ? 8'b01101001 : (W4003 ? 8'b11111010 : (W4015 ? 8'b00000001 : 8'hzz))))) : 8'hzz;

endmodule // RegDriver
