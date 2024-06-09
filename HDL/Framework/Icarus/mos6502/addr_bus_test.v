
`timescale 1ns/1ns

module addr_bus_test ();

	reg CLK;
	always #1 CLK = ~CLK;

	initial begin

		$dumpfile("addr_bus_test.vcd");
		$dumpvars(0, AddrBus_Run);

		CLK <= 1'b0;

		repeat (256) @ (posedge CLK);
		$finish;
	end

endmodule // addr_bus_test
