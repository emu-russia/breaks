// Instruction-level core test: the core runs a small self-checking program
// loaded from instr_test.mem (assembled by Scripts/make_instr_test.py).
// The program stores a pass/fail marker at $0200 and then parks in a self-loop
// at $3800, so this harness detects the park and reports the result, then
// dumps the checked memory area.
//
// NOTE: this design's BRK/reset vector low-byte load is still buggy (PCL is
// loaded with the precharged FF instead of the vector low byte), so the reset
// vector is pointed at $04FF and a `JMP $0400` trampoline is placed there
// (see make_instr_test.py). Once the vector-load bug is fixed, the trampoline
// can be dropped.

`timescale 1ns/1ns

module instr_test ();

	reg CLK;
	reg n_RES;
	reg n_IRQ;
	reg n_NMI;
	reg SO;
	reg RDY;

	wire [15:0] addr_bus;
	wire [7:0] data_bus;
	wire PHI1, PHI2, SYNC, RnW;

	integer maxcyc = 20000000;
	integer parkcyc = 30000;	// cycles parked at one address -> program finished
	integer report  = 100000;

	always #25 CLK = ~CLK;

	Core6502 core (
		.n_NMI(n_NMI), .n_IRQ(n_IRQ), .n_RES(n_RES),
		.PHI0(CLK), .PHI1(PHI1), .PHI2(PHI2),
		.RDY(RDY), .SO(SO), .RnW(RnW), .SYNC(SYNC),
		.A(addr_bus), .D(data_bus) );

	ExtMem mem (
		.M2(PHI2), .WE(~RnW), .OE(RnW),
		.Addr(addr_bus), .Data(data_bus) );

	integer cycles = 0;
	integer park_cnt = 0;
	reg [15:0] last_pc = 0;
	integer pfile;

	initial pfile = $fopen("instr_test_progress.txt", "w");

	task report_line;
		input [255:0] tag;
		begin
			$fdisplay(pfile, "%0t ns %s cycles=%0d PC=%04x mem[0200]=%02x", $time, tag, cycles, addr_bus, mem.mem[16'h0200]);
			$fflush(pfile);
		end
	endtask

	always @(posedge CLK) begin
		cycles = cycles + 1;

		// Parked at the final self-loop ($3800) -> program finished
		if (addr_bus == 16'h3800 && RnW == 1'b1) begin
			park_cnt = park_cnt + 1;
			if (park_cnt > parkcyc) begin
				if (mem.mem[16'h0200] == 8'h77)
					report_line("PASS");
				else
					report_line("FAIL");
				$display("INSTR_TEST: %s marker=$%02x after %0d cycles", mem.mem[16'h0200]==8'h77 ? "PASS" : "FAIL", mem.mem[16'h0200], cycles);
				$display("INSTR_TEST: checked RAM $10..$20 = %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x",
					mem.mem[16'h10],mem.mem[16'h11],mem.mem[16'h12],mem.mem[16'h13],mem.mem[16'h14],mem.mem[16'h15],mem.mem[16'h16],
					mem.mem[16'h17],mem.mem[16'h18],mem.mem[16'h19],mem.mem[16'h1A],mem.mem[16'h1B],mem.mem[16'h1C],mem.mem[16'h1D],
					mem.mem[16'h1E],mem.mem[16'h1F],mem.mem[16'h20]);
				$finish;
			end
		end else begin
			park_cnt = 0;
		end

		if (cycles >= maxcyc) begin
			report_line("TIMEOUT");
			$display("INSTR_TEST: TIMEOUT cycles=%0d PC=%04x marker=%02x", cycles, addr_bus, mem.mem[16'h0200]);
			$finish;
		end
		if ((cycles % report) == 0)
			report_line("progress");
	end

	initial begin
		$display("INSTR_TEST: running instr_test.mem");
		RDY <= 1'b1;
		SO <= 1'b1;
		CLK <= 1'b0;
		n_IRQ <= 1'b1;
		n_NMI <= 1'b1;
		if (!$value$plusargs("maxcyc=%d", maxcyc)) maxcyc = 20000000;
		if (!$value$plusargs("parkcyc=%d", parkcyc)) parkcyc = 30000;
		if (!$value$plusargs("report=%d", report)) report = 100000;

		n_RES <= 1'b0;
		repeat (16) @ (posedge CLK);
		n_RES <= 1'b1;
		repeat (2) @ (negedge CLK);
	end

endmodule // instr_test

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
