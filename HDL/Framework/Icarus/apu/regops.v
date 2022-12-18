// Testing register operations

// Simply go through the addresses in the APU address space and display the VCD of all RegOps signals.

`timescale 1ns/1ns

module RegOps_Run();

	reg [15:0] addr;
	reg rw;

	always #4 addr = addr + 1;

	ApuRegsDecoder regs (
		.PHI1(1'b0), 
		.Addr_fromcore(addr), .Addr_frommux(addr), .RnW_fromcore(rw), .DBG_frompad(1'b1) );

	initial begin

		$dumpfile("regops.vcd");
		$dumpvars(0, regs);

		// Register Read
		addr <= 16'h4000;
		rw <= 1'b1;
		repeat (17) @ (posedge addr);

		// Register Write
		addr <= 16'h4000;
		rw <= 1'b0;
		repeat (17) @ (posedge addr);

		$finish;
	end

endmodule // RegOps_Run
