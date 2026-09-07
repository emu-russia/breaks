// OAM (OAMBlock, HDL/PPU/oam.v) self-check.
//
// The behavioural model is a 256x8 OAM array addressed by the inverted bus
// n_OAM (oam_addr = ~n_OAM), written only from the CPU port ($2004):
//   oam_ram[oam_addr] <= CPU_DB  at every posedge PCLK while n_W4=0 and n_DBE=0
// (see HDL/PPU/oam.v). Read side:
//   - $2004 read: CPU_DB = oam_ram[oam_addr] while n_R4=0 and n_DBE=0,
//     otherwise CPU_DB is tri-stated;
//   - OB_Out follows oam_ram[oam_addr] asynchronously (this is the port the
//     sprite-evaluation comparators consume during evaluation, per the wiring
//     in ppu_top.v: Eval_Cmp compares OB_Out against the V counter).
//
// Checks (BreakingNESWiki/PPU/oam.md + module):
//   1. All 256 bytes are zeroed after power-on (no x/z on OB_Out).
//   2. Write-then-read round trip over every address via the $2004 port
//      (write is edge-triggered on posedge PCLK; read is asynchronous).
//   3. Write enable gating: no capture when n_DBE=1 or n_W4=1, or when the
//      strobes are low only during PCLK=1 (no rising edge).
//   4. CPU_DB read output is tri-state unless n_R4=0 && n_DBE=0.
//   5. OB_Out mirrors the addressed byte for both written and untouched
//      (still zero) addresses.
// Prints TEST PASS/FAIL.

`timescale 1ns/1ns

module oam_test ();

	reg n_PCLK;
	reg PCLK;
	always #25 begin PCLK = ~PCLK; n_PCLK = ~PCLK; end

	reg [7:0] n_OAM;
	reg OAM8;
	reg BLNK;
	reg SPR_OV;
	reg OAMCTR2;
	reg H0_DD;
	reg n_VIS;
	reg I_OAM2;
	reg n_W4;
	reg n_R4;
	reg n_DBE;

	// CPU_DB is an inout: the test drives it only during writes (n_R4 kept 1).
	reg [7:0] db_val;
	reg db_drv;
	wire [7:0] CPU_DB = db_drv ? db_val : 8'bz;

	wire [7:0] OB_Out;
	wire OFETCH;

	OAMBlock uut (
		.n_PCLK(n_PCLK), .PCLK(PCLK),
		.n_OAM(n_OAM), .OAM8(OAM8), .BLNK(BLNK), .SPR_OV(SPR_OV),
		.OAMCTR2(OAMCTR2), .H0_DD(H0_DD), .n_VIS(n_VIS), .I_OAM2(I_OAM2),
		.n_W4(n_W4), .n_R4(n_R4), .n_DBE(n_DBE),
		.CPU_DB(CPU_DB),
		.OB_Out(OB_Out), .OFETCH(OFETCH) );

	integer errors = 0;
	integer checks = 0;
	integer addr;
	reg [7:0] expect_byte;

	// Drive inputs, sample OB_Out after settling.
	task sample_ob;
		input [159:0] what;
		input [7:0] oam_addr;
		input [7:0] exp;
		begin
			n_OAM = ~oam_addr;
			#1;
			checks = checks + 1;
			if (OB_Out !== exp) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL %0s: addr=%02x OB_Out=%02x, expected %02x", what, oam_addr, OB_Out, exp);
			end
		end
	endtask

	// $2004 write: drive data and strobes low across one posedge PCLK.
	task cpu_write_oam;
		input [159:0] what;
		input [7:0] oam_addr;
		input [7:0] data;
		begin
			@(negedge PCLK);
			n_OAM = ~oam_addr;
			db_drv = 1; db_val = data;
			n_W4 = 1'b0; n_DBE = 1'b0;
			@(posedge PCLK);
			#1;
			n_W4 = 1'b1; n_DBE = 1'b1;
			db_drv = 0;
			@(negedge PCLK);
		end
	endtask

	// $2004 read: async; clock may be frozen.
	task cpu_read_oam;
		input [159:0] what;
		input [7:0] oam_addr;
		input [7:0] exp;
		begin
			n_OAM = ~oam_addr;
			n_R4 = 1'b0; n_DBE = 1'b0;
			#1;
			checks = checks + 1;
			if (CPU_DB !== exp) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL %0s: addr=%02x CPU_DB=%02x, expected %02x", what, oam_addr, CPU_DB, exp);
			end
			n_R4 = 1'b1; n_DBE = 1'b1;
			#1;
		end
	endtask

	initial begin
		$dumpfile("oam_test.vcd");
		$dumpvars(0, oam_test);

		PCLK = 1'b0; n_PCLK = 1'b1;
		n_OAM = 8'hFF; OAM8 = 0; BLNK = 0; SPR_OV = 0; OAMCTR2 = 0;
		H0_DD = 0; n_VIS = 0; I_OAM2 = 0;
		n_W4 = 1; n_R4 = 1; n_DBE = 1;
		db_drv = 0; db_val = 0;
		repeat (2) @(posedge PCLK);

		// 1) Power-on: every byte is zero; OB_Out never x/z.
		for (addr = 0; addr < 256; addr = addr + 1) begin
			sample_ob("power-on zero", addr[7:0], 8'h00);
		end
		checks = checks + 1;
		if (OFETCH === 1'bx || OFETCH === 1'bz) begin
			$display("FAIL OFETCH not driven: %b", OFETCH);
			errors = errors + 1;
		end

		// 2) Write-then-read round trip over all addresses.
		for (addr = 0; addr < 256; addr = addr + 1) begin
			cpu_write_oam("round trip write", addr[7:0], (addr[7:0] * 8'd7 + 8'd13));
		end
		for (addr = 0; addr < 256; addr = addr + 1) begin
			expect_byte = addr[7:0] * 8'd7 + 8'd13;
			sample_ob("written back", addr[7:0], expect_byte);
			cpu_read_oam("round trip read", addr[7:0], expect_byte);
		end

		// 3) Write gating. All 256 bytes hold sweep value (a*7+13)&0xFF from the
		//    round trip above; blocked writes must leave that value intact.
		//    Strobes are only ever asserted well away from a posedge PCLK, so the
		//    edge-sensitive RAM write can never sample a half-driven bus.
		addr = 8'hA5;
		expect_byte = addr[7:0] * 8'd7 + 8'd13;   // current content = 0x90

		// n_DBE=1 blocks the write.
		@(negedge PCLK);
		n_OAM = ~addr[7:0];
		db_drv = 1; db_val = 8'hFF;
		n_W4 = 1'b0; n_DBE = 1'b1;      // data bus not enabled
		@(posedge PCLK); #1;
		n_W4 = 1'b1; db_drv = 0;
		@(negedge PCLK);
		cpu_read_oam("n_DBE=1 blocks", addr[7:0], expect_byte);

		// n_W4=1 blocks the write.
		@(negedge PCLK);
		db_drv = 1; db_val = 8'hFF;
		n_W4 = 1'b1; n_DBE = 1'b0;      // no write strobe
		@(posedge PCLK); #1;
		n_DBE = 1'b1; db_drv = 0;
		@(negedge PCLK);
		cpu_read_oam("n_W4=1 blocks", addr[7:0], expect_byte);

		// Strobe low only while PCLK is already high (no rising edge occurs with
		// the strobes low): no write. Strobes are asserted #1 after the posedge
		// and dropped before the negedge, so no posedge ever sees them low.
		@(posedge PCLK); #1;
		n_OAM = ~addr[7:0];
		db_drv = 1; db_val = 8'hFF;
		n_W4 = 1'b0; n_DBE = 1'b0;      // begins after the rising edge
		@(negedge PCLK); #1;
		n_W4 = 1'b1; n_DBE = 1'b1; db_drv = 0;
		@(negedge PCLK);
		cpu_read_oam("no posedge wr", addr[7:0], expect_byte);

		// 4) Tri-state: CPU_DB only driven on $2004 read.
		n_R4 = 1'b1; n_DBE = 1'b1;
		#1;
		checks = checks + 1;
		if (CPU_DB !== 8'bz) begin
			$display("FAIL CPU_DB not z with n_R4/n_DBE high: %b", CPU_DB);
			errors = errors + 1;
		end
		n_R4 = 1'b0; n_DBE = 1'b1;      // DBE high blocks output too
		#1;
		checks = checks + 1;
		if (CPU_DB !== 8'bz) begin
			$display("FAIL CPU_DB not z with n_DBE=1: %b", CPU_DB);
			errors = errors + 1;
		end
		n_R4 = 1'b1; n_DBE = 1'b1;

		// 5) Read is asynchronous: value available with the clock frozen.
		//    Freeze PCLK low and verify contents at two addresses.
		@(negedge PCLK);
		n_OAM = ~8'h00; n_R4 = 1'b0; n_DBE = 1'b0;
		#1;
		checks = checks + 1;
		if (CPU_DB !== 8'h0D) begin
			$display("FAIL async read addr 0: %02x, expected 0D", CPU_DB);
			errors = errors + 1;
		end
		n_OAM = ~8'hFF;                 // addr 255: 255*7+13 = 1786+13 ... low byte
		#1;
		expect_byte = 8'hFF * 8'd7 + 8'd13;
		checks = checks + 1;
		if (CPU_DB !== expect_byte) begin
			$display("FAIL async read addr FF: %02x, expected %02x", CPU_DB, expect_byte);
			errors = errors + 1;
		end
		n_R4 = 1'b1; n_DBE = 1'b1;
		#1;

		// 6) Overwrite works; neighbours keep their sweep values.
		cpu_write_oam("overwrite", 8'h7F, 8'h3C);
		cpu_write_oam("overwrite", 8'h7F, 8'hC3);
		cpu_read_oam("overwritten", 8'h7F, 8'hC3);
		cpu_read_oam("neighbor intact", 8'h80, 8'h8D);   // 0x80 sweep value

		if (errors == 0)
			$display("oam_test: TEST PASS (%0d checks)", checks);
		else
			$display("oam_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // oam_test
