// Full-core boot run, limited to 3000 cycles (issue #1337).
// The core is reset and then runs; every opcode fetch (SYNC && read) is
// logged so the reset/vector sequence and the first instructions can be
// checked. The memory image is instr_test.mem: the reset vector points to
// $0400 and a `JMP $0400` trampoline is placed at $04FF.
//
// Expected correct behaviour: after /RES the core reads the vector at
// $FFFC/$FFFD (00/04) and the first fetch happens at $0400.
//
// This test only RUNS the core for the diagnostic window; it reports the
// observed sequence and finishes after 3000 cycles.

`timescale 1ns/1ns

module core_boot_test ();

	reg CLK;
	reg n_RES;
	reg n_IRQ;
	reg n_NMI;
	reg SO;
	reg RDY;

	wire [15:0] addr_bus;
	wire [7:0] data_bus;
	wire PHI1, PHI2, SYNC, RnW;

	integer maxcyc = 3000;

	always #25 CLK = ~CLK;

	Core6502 core (
		.n_NMI(n_NMI), .n_IRQ(n_IRQ), .n_RES(n_RES),
		.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2),
		.RDY(RDY), .SO(SO), .RnW(RnW), .SYNC(SYNC),
		.A(addr_bus), .D(data_bus) );

	ExtMem mem0 (
		.M2(PHI2), .WE(~RnW), .OE(RnW),
		.Addr(addr_bus), .Data(data_bus) );

	integer cycles = 0;
	integer started = 0;
	integer fetches = 0;
	reg [15:0] fetch_pc [0:63];
	integer last_cycle = 0;

	always @(posedge CLK) begin
		#5;
		cycles = cycles + 1;
		if (SYNC && RnW) begin
			if (fetches < 64) fetch_pc[fetches] = addr_bus;
			fetches = fetches + 1;
			last_cycle = cycles;
		end
		if (SYNC && RnW && fetches == 1) begin
			$display("CORE_BOOT: first fetch PC=%04x (PCL=%02x PCH=%02x)", addr_bus, core.bot.pc.pc[7:0], core.bot.pc.pc[15:8]);
		end
		if (cycles >= maxcyc) begin
			$display("CORE_BOOT: done after %0d cycles, %0d fetches observed", cycles, fetches);
			for (integer ii = 0; ii < 16 && ii < fetches; ii = ii + 1)
				$display("  fetch %0d: PC=%04x", ii, fetch_pc[ii]);
			// PASS = the program at $0400 is reached (boot through the vector);
			// with the vector-low bug the core never gets past $04FF.
			started = 0;
			for (integer ii = 0; ii < 64 && ii < fetches; ii = ii + 1)
				if (fetch_pc[ii] === 16'h0400) started = 1;
			if (started)
				$display("core_boot_test: TEST PASS - execution reached $0400");
			else
				$display("core_boot_test: TEST FAIL - execution never reached $0400 (vector low byte was not loaded into PCL; stuck at $04FF)");
			$finish;
		end
	end

	initial begin
		$display("CORE_BOOT: full-core run, limit %0d cycles", maxcyc);

		$dumpfile("core_boot_test.vcd");
		$dumpvars(0, core_boot_test);

		RDY <= 1'b1;
		SO <= 1'b1;
		CLK <= 1'b0;
		n_IRQ <= 1'b1;
		n_NMI <= 1'b1;

		n_RES <= 1'b0;
		repeat (16) @ (posedge CLK);
		n_RES <= 1'b1;

		repeat (1) @ (negedge CLK);
	end

endmodule // core_boot_test

module ExtMem (M2, WE, OE, Addr, Data);

	input M2;
	input WE;
	input OE;
	input [15:0] Addr;
	inout [7:0] Data;

	reg [7:0] mem [0:65535];
	reg [7:0] temp;

	integer j;
	initial
	for(j = 0; j < 65536; j = j+1)
		mem[j] = 0;

	initial $readmemh("instr_test.mem", mem);

	always @(M2) begin
		if (OE)
			temp <= mem[Addr];
		else if (WE)
			mem[Addr] <= Data;
	end

	assign Data = (M2 & OE) ? temp : 'bz;

endmodule // ExtMem
