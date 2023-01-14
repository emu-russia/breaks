// Check all possible values of the shifter used in square channels.

module Square_Barrel_Run ();

	reg [14:0] val; 	// {BS[11:0] || SR[2:0]}
	output [10:0] S;

	always #1 val = val + 1;

	SQUARE_BarrelShifter bs (.BS(val[14:3]), .SR(val[2:0]), .S(S));

	initial begin

		$dumpfile("square_barrel.vcd");
		$dumpvars(0, bs);

		val <= 0;

		repeat (32769) @ (val);
		$finish;
	end

endmodule // Square_Barrel_Run
