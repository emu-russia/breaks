// Check the operation of the DAC.

module AUX_Run ();

	integer i;
	integer fd;

	reg [7:0] a;
	reg [14:0] b;
	reg [23:0] addr;

	always #1 a = a + 1;
	always #1 b = b + 1;
	always #1 addr = addr + 1;

	wire [31:0] aout;
	wire [31:0] bout;

	AUX aux (.AUX_A(a), .AUX_B(b), .AOut(aout), .BOut(bout) );

	AUX_Dumper dump_a (.addr(addr), .val(aout));
	AUX_Dumper dump_b (.addr(addr), .val(bout));

	initial begin

		$dumpfile("aux_test.vcd");
		$dumpvars(0, a);
		$dumpvars(1, b);
		$dumpvars(2, aout);
		$dumpvars(3, bout);

		a <= 0;
		b <= 0;
		addr <= 0;

		repeat (32769) @ (b);

		// Save to file

		fd = $fopen("auxa_dump.bin", "wb");
		for (i = 0; i<16777216; i=i+1) begin
			$fwrite (fd, "%u", dump_a.mem[i]);
		end
		$fclose (fd);

		fd = $fopen("auxb_dump.bin", "wb");
		for (i = 0; i<16777216; i=i+1) begin
			$fwrite (fd, "%u", dump_b.mem[i]);
		end
		$fclose (fd);

		$finish;
	end

endmodule // AUX_Run
