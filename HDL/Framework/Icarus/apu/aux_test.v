// Check the operation of the DAC.

module AUX_Run ();

	reg [7:0] a;
	reg [14:0] b;

	always #1 a = a + 1;
	always #1 b = b + 1;

	wire [31:0] aout;
	wire [31:0] bout;

	AUX aux (.AUX_A(a), .AUX_B(b), .AOut(aout), .BOut(bout) );

	initial begin

		$dumpfile("aux_test.vcd");
		$dumpvars(0, a);
		$dumpvars(1, b);
		$dumpvars(2, aout);
		$dumpvars(3, bout);

		a <= 0;
		b <= 0;

		repeat (32769) @ (b);
		$finish;
	end

endmodule // AUX_Run
