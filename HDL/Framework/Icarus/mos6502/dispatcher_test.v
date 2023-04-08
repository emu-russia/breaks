// Test opcode dispatch

`timescale 1ns/1ns

module Dispatcher_Run ();

	reg CLK;
	wire PHI1;
	wire PHI2;

	always #1 CLK = ~CLK;

	wire [7:0] DataBus;

	wire Z_IR;
	wire [7:0] n_PD;
	wire n_IMPLIED;
	wire n_TWOCYCLE;
	wire TRES2;
	wire n_ready;
	wire T0;
	wire T1;
	wire n_T2;
	wire n_T3;
	wire n_T4;
	wire n_T5;
	wire FETCH;
	wire IR01;
	wire [7:0] IR;
	wire [7:0] n_IR;
	wire [129:0] X;

	ClkGen clk (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2));

	PreDecode predecode (
		.PHI2(PHI2),
		.Z_IR(Z_IR),
		.Data_bus(DataBus), .n_PD(n_PD),
		.n_IMPLIED(n_IMPLIED), .n_TWOCYCLE(n_TWOCYCLE));

	ExtraCounter extra_counter (
		.PHI1(PHI1), .PHI2(PHI2), .TRES2(TRES2), .n_ready(n_ready), .T1(T1),
		.n_T2(n_T2), .n_T3(n_T3), .n_T4(n_T4), .n_T5(n_T5));

	IR ir (
		.PHI1(PHI1), .PHI2(PHI2),
		.n_PD(n_PD), .FETCH(FETCH),
		.IR01(IR01), .IR_out(IR), .n_IR_out(n_IR));

	Decoder decoder (
		.n_T0(n_T0), .n_T1X(n_T1X),
		.n_T2(n_T2), .n_T3(n_T3), .n_T4(n_T4), .n_T5(n_T5), 
		.IR01(IR01),
		.IR(IR), .n_IR(n_IR),
		.X(X));

	Dispatch dispatch (
		.PHI1(PHI1), .PHI2(PHI2),
		.BRK6E(1'b0), .RESP(1'b0), .ACR(1'b0), .DORES(1'b0), .PC_DB(1'b0), .RDY(1'b1), .B_OUT(1'b1), .BRFW(1'b0), .n_BRTAKEN(1'b0),
		.n_TWOCYCLE(n_TWOCYCLE), .n_IMPLIED(n_IMPLIED), .n_ADL_PCL(1'b0), 
		.X(X), 
		.TRES2(TRES2), .Z_IR(Z_IR), .FETCH(FETCH), .n_ready(n_ready), .T1(T1), .n_T0(n_T0), .T0(T0), .n_T1X(n_T1X));

	MemoryDevice mem (.DataBus(DataBus));

	initial begin

		$dumpfile("dispatcher_test.vcd");
		$dumpvars(0, Dispatcher_Run);

		CLK <= 1'b0;

		repeat (32) @ (posedge CLK);

		$finish;
	end

endmodule // Dispatcher_Run

module MemoryDevice (DataBus);

	inout [7:0] DataBus;

	assign DataBus = 8'h8D; 	// STA abs

endmodule // MemoryDevice
