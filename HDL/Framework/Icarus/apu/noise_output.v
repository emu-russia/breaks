// Testing the output of a noise generator.

// From the main APU "honestly" simulated: ACLK and LFO, the length counter and the whole sound channel block. 

//⚠️ The register write simulation (RegOps) takes place in a redundant mode, because no alignment cycles are required to write the registers of the audio generators.

`timescale 1ns/1ns

`define CoreCyclesPerCLK 6

module Noise_Run ();

	// Timing
	reg CLK;
	reg RES;
	wire PHI1;
	wire ACLK1;
	wire nACLK2;
	wire nLFO1;
	wire nLFO2;

	// Regs
	reg W400C;
	reg W400E;
	reg W400F;
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

	// Modules for the noise generator

	wire [7:0] LC;
	wire RND_LC;
	wire NORND;
	wire [3:0] RND_Out;

	LengthCounter_PLA pla (
		.DB(DataBus),
		.LC_Out(LC) );

	LengthCounter length (
		.nACLK2(nACLK2), .ACLK1(ACLK1),
		.RES(RES), .W400x_load(W400F), .n_R4015(n_R4015), .W4015(W4015), .LC(LC), .dbit_ena(DataBus[3]), .nLFO2(nLFO2),
		.Carry_in(RND_LC), .NotCount(NORND) );

	NoiseChan noise (
		.ACLK1(ACLK1), .nACLK2(nACLK2), 
		.RES(RES), .DB(DataBus), 
		.W400C(W400C), .W400E(W400E), .W400F(W400F), 
		.nLFO1(nLFO1), .RND_LC(RND_LC), .NORND(NORND), .LOCK(1'b0), 
		.RND_out(RND_Out) );

	AUX aux (.AUX_A(8'b0000_0000), .AUX_B({7'b0000000,RND_Out,4'b0000}), .BOut(AuxOut) );

	RegDriver reg_driver (.PHI1(PHI1), .W400C(W400C), .W400E(W400E), .W400F(W400F), .W4015(W4015), .DataBus(DataBus) );

	initial begin

		$dumpfile("noise_output.vcd");
		$dumpvars(0, div);
		$dumpvars(1, core);
		$dumpvars(2, aclk);
		$dumpvars(3, softclk);
		$dumpvars(4, pla);
		$dumpvars(5, length);
		$dumpvars(6, noise);
		$dumpvars(7, AuxOut);

		CLK <= 1'b0;
		RES <= 1'b0;

		W400C <= 1'b0;
		W400E <= 1'b0;
		W400F <= 1'b0;
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

		W400C <= 1'b1;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		W400C <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);

		W400E <= 1'b1;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		W400E <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);

		W400F <= 1'b1;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);
		W400F <= 1'b0;
		repeat (`CoreCyclesPerCLK) @ (posedge CLK);

		// Run the simulation in free flight to obtain sound

		repeat (32768 * 64) @ (posedge CLK);
		$finish;
	end

endmodule //  Noise_Run

// Simulation of the processor, to get a PHI1/2.
module BogusCPU (PHI0, PHI1, PHI2);

	input PHI0;
	output PHI1;
	output PHI2;

	assign PHI1 = ~PHI0;
	assign PHI2 = PHI0;

endmodule // BogusCPU

// This module executes a "program" sequence of writes to various registers
module RegDriver (PHI1, W400C, W400E, W400F, W4015, DataBus);

	input PHI1;
	input W400C;
	input W400E;
	input W400F;
	input W4015;
	inout [7:0] DataBus;

	// W4015 <= 0000 1 000  (Noise Length counter enable: 1)
	// W400C <= xx 0 0 0110 (Noise Length counter #carry: 0, Constant: 0, Env: 6)
	// W400E <= 0 xxx 0111 (Loop: 0, Period: 7)
	// W400F <= 11111 xxx (Length: 11111)

	assign DataBus = ~PHI1 ? (W400C ? 8'b00000110 : (W400E ? 8'b00000111 : (W400F ? 8'b11111000 : (W4015 ? 8'b00001000 : 8'hzz)))) : 8'hzz;

endmodule // RegDriver
