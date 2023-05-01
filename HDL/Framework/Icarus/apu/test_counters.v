`timescale 1ns/1ns

// Run the counters and see how they work.

module TestCounters_Run();

	reg CLK;
	reg DownCount;

	always #25 CLK = ~CLK;

	UpCounterTest up_counter (.CLK(CLK));
	DownCounterTest down_counter (.CLK(CLK));
	RevCounterTest rev_counter (.CLK(CLK), .DownCount(DownCount));

	initial begin

		CLK <= 1'b0;

		$dumpfile("test_counters.vcd");
		$dumpvars(0, up_counter);
		$dumpvars(1, down_counter);
		$dumpvars(2, rev_counter);

		DownCount <= 1'b0;
		repeat (256) @ (posedge CLK);

		DownCount <= 1'b1;
		repeat (256) @ (posedge CLK);

		$finish;
	end

endmodule // TestCounters_Run

module UpCounterTest(CLK);
	input CLK;

	wire [7:0] carry_chain;
	wire [7:0] q;

	CounterBit cnt [7:0] (
		.ACLK1(~CLK),
		.clear(1'b0),
		.step(CLK),
		.load(1'b0),
		.q(q),
		.cin({carry_chain[6:0], 1'b1}),
		.cout(carry_chain) );

endmodule // UpCounterTest

module DownCounterTest(CLK);
	input CLK;

	wire [7:0] carry_chain;
	wire [7:0] q;

	DownCounterBit cnt [7:0] (
		.ACLK1(~CLK),
		.clear(1'b0),
		.step(CLK),
		.load(1'b0),
		.q(q),
		.cin({carry_chain[6:0], 1'b1}),
		.cout(carry_chain) );

endmodule // UpCounterTest

module RevCounterTest(CLK, DownCount);
	input CLK;
	input DownCount;

	wire [7:0] carry_chain;
	wire [7:0] q;

	RevCounterBit cnt [7:0] (
		.ACLK1(~CLK),
		.clear(1'b0),
		.step(CLK),
		.load(1'b0),
		.q(q),
		.dec(DownCount),
		.cin({carry_chain[6:0], 1'b1}),
		.cout(carry_chain) );

endmodule // UpCounterTest
