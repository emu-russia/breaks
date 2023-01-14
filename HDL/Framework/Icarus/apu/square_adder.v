// Testing of the adder of a square wave sound generator.

// This test runs a test vector exclusively for Adder and its single bit (full adder) circuitry.
// That is the testing is done abstractly from the APU - just to check that the adder... adds things up :-)

// A distinctive feature of the adder is the complementary wiring of the a/b signals and the carry chain and the inverse polarity of the result (#sum) and the output carry (#COUT).

module Square_Adder_Run ();

	// Counter for shaping the test vector of the single bit (Full Adder).
	reg [2:0] bit_counter;    // { c || b || a }
	always #1 bit_counter = bit_counter + 1;

	// FA outputs
	wire nc;
	wire c;
	wire ns;

	// Counters for enumerating Adder input values
	reg [21:0] ab_counter;		// { b[10:0] || a[10:0] }
	always #1 ab_counter = ab_counter + 1;

	wire [10:0] Fx; 		// Input A
	wire [10:0] S; 			// Input B  (or vice versa, since group)
	wire [10:0] n_sum;		// Output A + B (inverse polarity)
	wire [10:0] sum; 		// Just for convenience
	wire n_COUT; 			// Output carry (inverse polarity)
	wire COUT; 				// Just for convenience

	assign Fx = ab_counter[10:0]; 	// low half
	assign S = ab_counter[21:11];	// high half
	assign sum = ~n_sum;
	assign COUT = ~n_COUT;

	SQUARE_AdderBit adder_bit (
		.F(bit_counter[0]), .nF(~bit_counter[0]), 
		.S(bit_counter[1]), .nS(~bit_counter[1]), 
		.C(bit_counter[2]), .nC(~bit_counter[2]), 
		.n_cout(nc), .cout(c), .n_sum(ns) );

	// Using the input carry connection option for Square1 (n_carry=1 aka carry=0)
	SQUARE_Adder adder (.CarryMode(1'b1), .INC(1'b0), .nFx(~Fx), .Fx(Fx), .S(S), .n_sum(n_sum), .n_COUT(n_COUT) );

	initial begin

		$dumpfile("square_adder.vcd");
		$dumpvars(0, adder_bit);
		$dumpvars(1, adder);
		$dumpvars(2, sum);
		$dumpvars(3, COUT);

		bit_counter <= 0;
		ab_counter <= 0;

		// Run full adder
		repeat (8) @ (bit_counter);

		// Run whole
		repeat ((1 << 22) - 7) @ (ab_counter);

		$finish;
	end

endmodule // Square_Adder_Run
