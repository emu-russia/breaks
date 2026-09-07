// Full-core verification run: MOS6502 Core executes the Klaus Dormann functional test.
// Memory image: Klaus/6502_funstional_test.mem (reset vector -> 0x0400, start of tests).
//
// The suite takes about 96 million cycles (~30 million instructions) on a working core.
// Pass condition: the CPU parks on the self-loop `JMP $3469` (address bus stuck at 0x3469).
// Failures usually hang the CPU earlier in a tight loop and/or leave an error byte in $0200.
//
// Usage:
//   iverilog -D ICARUS -o klaus_test.run ../../../Common/*.v ../../../Core6502/*.v klaus_test.v
//   vvp klaus_test.run [+maxcyc=<N>] [+report=<M>]

`timescale 1ns/1ns

module Klaus_Run ();

	reg CLK;
	reg n_RES;
	reg n_IRQ;
	reg n_NMI;
	reg SO;
	reg RDY;

	wire [15:0] addr_bus;
	wire [7:0] data_bus;

	wire PHI1;
	wire PHI2;
	wire SYNC;
	wire RnW;

	integer maxcyc = 500000000;		// safety valve, way past the 96M-cycle suite
	integer report  = 5000000;		// progress report interval

	always #25 CLK = ~CLK;

	Core6502 core (
		.n_NMI(n_NMI),
		.n_IRQ(n_IRQ),
		.n_RES(n_RES),
		.PHI0(CLK),
		.PHI1(PHI1),
		.PHI2(PHI2),
		.RDY(RDY),
		.SO(SO),
		.RnW(RnW),
		.SYNC(SYNC),
		.A(addr_bus),
		.D(data_bus) );

	ExtMem mem (
		.M2(PHI2),
		.WE(~RnW),
		.OE(RnW),
		.Addr(addr_bus),
		.Data(data_bus) );

	integer cycles = 0;
	integer succ_cnt = 0;
	integer hang_cnt = 0;
	reg [15:0] last_pc = 0;
	reg [15:0] hang_pc = 0;
	integer pfile;

	initial pfile = $fopen("klaus_progress.txt", "w");

	task write_progress;
		input [255:0] tag;
		begin
			$fdisplay(pfile, "%0t ns  %s  cycles=%0d PC=%04x RnW=%b SYNC=%b mem[0200]=%02x mem[0201]=%02x",
				$time, tag, cycles, addr_bus, RnW, SYNC, mem.mem[16'h0200], mem.mem[16'h0201]);
			$fflush(pfile);
		end
	endtask

	always @(posedge CLK) begin
		cycles = cycles + 1;

		// Success: address bus parked at the final self-loop (0x3469), reading.
		if (addr_bus == 16'h3469 && RnW == 1'b1) begin
			succ_cnt = succ_cnt + 1;
			if (succ_cnt > 20000) begin
				write_progress("PASS");
				$display("KLAUS_TEST: PASS  (CPU parked on JMP $3469 after %0d cycles)", cycles);
				$finish;
			end
		end else begin
			succ_cnt = 0;
		end

		// Detect a CPU hang (any address bus frozen for a long time, except the pass loop).
		if (addr_bus == last_pc) begin
			hang_cnt = hang_cnt + 1;
			if (hang_cnt > 3000000 && addr_bus != 16'h3469) begin
				write_progress("HANG");
				$display("KLAUS_TEST: HANG  PC=$%04x frozen for %0d cycles (cycles=%0d, mem[0200]=%02x)",
					addr_bus, hang_cnt, cycles, mem.mem[16'h0200]);
				$display("KLAUS_TEST: ZP state: %02x %02x %02x %02x %02x %02x %02x %02x", mem.mem[0],mem.mem[1],mem.mem[2],mem.mem[3],mem.mem[4],mem.mem[5],mem.mem[6],mem.mem[7]);
				$finish;
			end
		end else begin
			hang_cnt = 0;
			last_pc = addr_bus;
		end

		if (cycles >= maxcyc) begin
			write_progress("TIMEOUT");
			$display("KLAUS_TEST: TIMEOUT after %0d cycles, PC=$%04x mem[0200]=%02x", cycles, addr_bus, mem.mem[16'h0200]);
			$finish;
		end

		if ((cycles % report) == 0)
			write_progress("progress");
	end

	initial begin
		$display("KLAUS_TEST: MOS6502 Core vs Klaus functional test (Klaus/6502_funstional_test.mem)");

		RDY <= 1'b1;		// Always ready
		SO <= 1'b1;			// SO held high: no overflow-set pulses

		CLK <= 1'b0;
		n_IRQ <= 1'b1;
		n_NMI <= 1'b1;

		if (!$value$plusargs("maxcyc=%d", maxcyc)) maxcyc = 500000000;
		if (!$value$plusargs("report=%d", report)) report = 5000000;

		// Perform reset
		n_RES <= 1'b0;
		repeat (16) @ (posedge CLK);
		n_RES <= 1'b1;

		repeat (2) @ (negedge CLK);
	end

endmodule // Klaus_Run

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

	initial $readmemh("Klaus/6502_funstional_test.mem", mem);

	always @(M2) begin
		if (OE)
			temp <= mem[Addr];
		else if (WE)
			mem[Addr] <= Data;
	end

	assign Data = (M2 & OE) ? temp : 'bz;

endmodule // ExtMem
