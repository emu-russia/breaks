`timescale 1ns/1ns

module addr_bus_test ();

	reg CLK;
	wire PHI1, PHI2;
	always #25 CLK = ~CLK;

	ClkGen clkgen (.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2) );

	reg ADX;
	reg ADX_ABX;
	wire ABus_out;

	AddrBusBit ab (
		.PHI1(PHI1), .PHI2(PHI2),
		.ADX(ADX), .ADX_ABX(ADX_ABX),
		.ABus_out(ABus_out) );

	initial begin

		$dumpfile("addr_bus_test.vcd");
		$dumpvars(0, addr_bus_test);

		CLK <= 1'b0;
		ADX <= 1'b0;
		ADX_ABX <= 1'b0;

		repeat (16) @ (posedge CLK);

		ADX_ABX <= 1'b1;
		ADX <= 1'b1;
		repeat (16) @ (posedge CLK);

		ADX_ABX <= 1'b0;
		repeat (16) @ (posedge CLK);

		ADX_ABX <= 1'b1;
		ADX <= 1'b0;
		repeat (16) @ (posedge CLK);

		ADX_ABX <= 1'b0;
		repeat (16) @ (posedge CLK);

		$finish;
	end

endmodule // addr_bus_test
