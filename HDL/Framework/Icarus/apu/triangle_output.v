// Testing the output of a triangle wave generator.

// From the main APU "honestly" simulated: ACLK and LFO, the length counter and the whole sound channel block. 

`timescale 1ns/1ns

`define CoreCyclesPerCLK 6

module Triangle_Run ();

	// Timing
	reg CLK;
	reg RES;
	wire PHI1;
	wire ACLK;
	wire n_ACLK;
	wire nLFO1;
	wire nLFO2;

	// Regs
	reg W4008;
	reg W400A;
	reg W400B;
	reg W401A;
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

	// Modules for the triangle sound generator

	wire [7:0] LC;
	wire TRI_LC;
	wire NOTRI;
	wire [3:0] TRI_Out;

	LengthCounter_PLA pla (
		.DB(DataBus),
		.LC_Out(LC) );

	LengthCounter length (
		.ACLK(ACLK), .n_ACLK(n_ACLK),
		.RES(RES), .W400x_load(W400B), .n_R4015(n_R4015), .W4015(W4015), .LC(LC), .dbit_ena(DataBus[2]), .nLFO2(nLFO2),
		.Carry_in(TRI_LC), .NotCount(NOTRI) );

	TriangleChan triangle (
		.PHI1(PHI1), .n_ACLK(n_ACLK),
		.RES(RES), .DB(DataBus), 
		.W4008(W4008), .W400A(W400A), .W400B(W400B), .W401A(W401A), 
		.nLFO1(nLFO1), .TRI_LC(TRI_LC), .NOTRI(NOTRI), .LOCK(1'b0),
		.TRI_Out(TRI_Out) );

	initial begin

		$dumpfile("triangle_output.vcd");
		$dumpvars(0, div);
		$dumpvars(1, core);
		$dumpvars(2, aclk);
		$dumpvars(3, softclk);
		$dumpvars(4, pla);
		$dumpvars(5, length);
		$dumpvars(6, triangle);

		CLK <= 1'b0;
		RES <= 1'b0;

		W4008 <= 1'b0;
		W400A <= 1'b0;
		W400B <= 1'b0;
		W401A <= 1'b0;
		W4015 <= 1'b0;
		W4017 <= 1'b0;
		n_R4015 <= 1'b1;

		// Configure the registers of the entire system

		// Run the simulation in free flight to obtain sound

		repeat (32768 * 1) @ (posedge CLK);
		$finish;
	end

endmodule //  Triangle_Run

// Simulation of the processor, to get a PHI1/2.
module BogusCPU (PHI0, PHI1, PHI2);

	input PHI0;
	output PHI1;
	output PHI2;

	assign PHI1 = ~PHI0;
	assign PHI2 = PHI0;

endmodule // BogusCPU
