// PPU terminal pads (PpuPadsLogic) self-check.
//
// Reference: BreakingNESWiki/PPU/pads.md.  The pads translate the internal
// (often inverse) logic signals to/from the external chip terminals:
//   CPU D0-D7  - bidirectional. Internal CPU_DB drives the pad while the
//                internal read strobe n_CpuRD=0 ("read"), and the pad value
//                is driven onto CPU_DB while n_CpuWR=0 ("write"); with both
//                strobes inactive the bus is released (z).
//   VRAM I/F   - ALE = ~n_ALE_topad; A8-A13 = ~n_PA[13:8]; the low address
//                byte (~n_PA[7:0]) is placed on the multiplexed AD0-7 bus
//                whenever the controller is not reading (/RD asserted),
//                otherwise the AD bus floats and its value is mirrored to
//                PD_out (the internal data bus to the FIFOs/regs).
//                n_RD/n_WR pads are the complements of RD_topad/WR_topad.
//   EXT0-3     - inter-PPU "picture" bus. Master (n_SLAVE=1) drives the pads
//                with the (inverted) latched mux output n_EXT_out (latch
//                transparent while n_PCLK=1), slave (n_SLAVE=0) reads the
//                bus (EXT_in = EXTPads), master keeps EXT_in = 0.
//   CLK        - CLK_frompad = CLKPad, n_CLK_frompad = ~CLKPad.
//   /RES       - RES = ~n_RESPad.  RC ("Register Clear") = RES: the register
//                file is cleared while the /RES pad is asserted and becomes
//                writable (and persists) as soon as /RES is released.
//                RESCL (the VBlank-end "Reset FF Clear") must not affect RC.
//                NOTE: an earlier pads.v fed RC from the inverted Reset_FF
//                latch that RESCL clears every VBlank end - RC then went to 1
//                permanently after the first frame (register wipe every
//                frame, and 0 during reset).  That was the bug fixed in
//                pads.v (RC = RES, per real NES behaviour).
//   /INT       - open-drain style: pulled to 0 only while Int_topad=1,
//                otherwise z (external pull-up).
// Compiled with -D RP2C02 -D ICARUS (NTSC; nothing here is revision-specific).

`timescale 1ns/1ns

module pads_test ();

	// ---- module inputs ----------------------------------------------------
	reg n_PCLK;
	reg n_CpuRD;
	reg n_CpuWR;
	reg n_ALE_topad;
	reg [13:0] n_PA;
	reg RD_topad;
	reg WR_topad;
	reg n_SLAVE;
	reg [3:0] n_EXT_out;
	reg CLKPad;
	reg n_RESPad;
	reg RESCL;
	reg Int_topad;

	// ---- inouts -----------------------------------------------------------
	wire [7:0] CPU_DB;
	wire [7:0] DPads;
	wire [7:0] ADPads;
	wire [3:0] EXTPads;

	// controlled drivers emulating the internal logic / external bus masters
	reg [7:0] cpu_db_val;	reg cpu_db_drv;
	reg [7:0] dpads_val;	reg dpads_drv;
	reg [7:0] adpads_val;	reg adpads_drv;
	reg [3:0] extpads_val;	reg extpads_drv;

	assign CPU_DB  = cpu_db_drv  ? cpu_db_val  : 8'bz;
	assign DPads   = dpads_drv   ? dpads_val   : 8'bz;
	assign ADPads  = adpads_drv  ? adpads_val  : 8'bz;
	assign EXTPads = extpads_drv ? extpads_val : 4'bz;

	// ---- outputs ----------------------------------------------------------
	wire ALE;
	wire [7:0] PD_out;
	wire [5:0] PAPads;
	wire n_RDPad;
	wire n_WRPad;
	wire [3:0] EXT_in;
	wire n_CLK_frompad;
	wire CLK_frompad;
	wire RES;
	wire RC;
	wire n_INTPad;

	PpuPadsLogic uut (
		.n_PCLK(n_PCLK),
		.n_CpuRD(n_CpuRD), .n_CpuWR(n_CpuWR), .CPU_DB(CPU_DB), .DPads(DPads),
		.n_ALE_topad(n_ALE_topad), .ALE(ALE),
		.PD_out(PD_out), .n_PA(n_PA), .PAPads(PAPads), .ADPads(ADPads),
		.RD_topad(RD_topad), .WR_topad(WR_topad), .n_RDPad(n_RDPad), .n_WRPad(n_WRPad),
		.EXTPads(EXTPads), .n_SLAVE(n_SLAVE), .EXT_in(EXT_in), .n_EXT_out(n_EXT_out),
		.CLKPad(CLKPad), .n_CLK_frompad(n_CLK_frompad), .CLK_frompad(CLK_frompad),
		.n_RESPad(n_RESPad), .RES(RES), .RESCL(RESCL), .RC(RC),
		.Int_topad(Int_topad), .n_INTPad(n_INTPad) );

	integer errors = 0;
	integer checks = 0;
	integer k, v;

	// ----------------------------------------------------------------
	// Individual checks
	task chk(input [127:0] what, input cond);
		begin
			checks = checks + 1;
			if (!cond) begin
				errors = errors + 1;
				$display("FAIL: %0s (t=%0t)", what, $time);
			end
		end
	endtask

	// drive nothing anywhere
	task all_z;
		begin
			cpu_db_drv = 0; dpads_drv = 0; adpads_drv = 0; extpads_drv = 0;
		end
	endtask

	initial begin
		$dumpfile("pads_test.vcd");
		$dumpvars(0, pads_test);

		// defaults
		n_PCLK = 1'b0;
		n_CpuRD = 1'b1; n_CpuWR = 1'b1;
		n_ALE_topad = 1'b1;
		n_PA = 14'b0;
		RD_topad = 1'b1; WR_topad = 1'b1;		// VRAM idle (/RD=/WR=1)
		n_SLAVE = 1'b1;							// master by default
		n_EXT_out = 4'b0000;
		CLKPad = 1'b0;
		n_RESPad = 1'b1;						// no reset
		RESCL = 1'b0;
		Int_topad = 1'b0;
		all_z();
		#10;

		// ============ CLK pads: plain buffer + inverter ====================
		CLKPad = 1'b0; #1;
		chk("CLK 0 -> CLK_frompad 0", CLK_frompad === 1'b0);
		chk("CLK 0 -> n_CLK_frompad 1", n_CLK_frompad === 1'b1);
		CLKPad = 1'b1; #1;
		chk("CLK 1 -> CLK_frompad 1", CLK_frompad === 1'b1);
		chk("CLK 1 -> n_CLK_frompad 0", n_CLK_frompad === 1'b0);

		// ============ ALE ===================================================
		n_ALE_topad = 1'b0; #1; chk("ALE = ~n_ALE (0->1)", ALE === 1'b1);
		n_ALE_topad = 1'b1; #1; chk("ALE = ~n_ALE (1->0)", ALE === 1'b0);

		// ============ address pads ==========================================
		n_PA = 14'b11_1111_0000_0000;			// PA13..8 = 111111
		#1;
		chk("PAPads = ~n_PA[13:8] (all ones)", PAPads === 6'b000000);
		n_PA = 14'b00_0000_1111_1111;			// PA13..8 = 000000
		#1;
		chk("PAPads = ~n_PA[13:8] (all zeros)", PAPads === 6'b111111);
		n_PA = 14'b10_1010_1010_1010;
		#1;
		chk("PAPads = ~n_PA[13:8] (alternating)", PAPads === ~n_PA[13:8]);

		// ============ /RD /WR pads ==========================================
		RD_topad = 1'b0; WR_topad = 1'b1; #1;
		chk("n_RDPad = ~RD_topad", n_RDPad === 1'b1);
		chk("n_WRPad = ~WR_topad", n_WRPad === 1'b0);
		RD_topad = 1'b1; WR_topad = 1'b0; #1;
		chk("n_RDPad = ~RD_topad (2)", n_RDPad === 1'b0);
		chk("n_WRPad = ~WR_topad (2)", n_WRPad === 1'b1);
		RD_topad = 1'b0; WR_topad = 1'b0; #1;
		chk("n_RDPad = ~RD_topad (3)", n_RDPad === 1'b1);
		chk("n_WRPad = ~WR_topad (3)", n_WRPad === 1'b1);
		RD_topad = 1'b1; WR_topad = 1'b1;		// restore idle

		// ============ AD bus ================================================
		// AD carries ~n_PA[7:0] while the controller is not reading the VRAM
		// (RD_topad=0 means /RD pad=1).  It floats when RD_topad=1.
		n_PA[7:0] = 8'hA5; RD_topad = 1'b0;
		adpads_drv = 0;							// let the PPU drive
		#1;
		chk("ADPads = ~n_PA[7:0] (read strobe inactive)", ADPads === 8'h5A);
		chk("PD_out mirrors AD bus while PPU drives", PD_out === 8'h5A);

		RD_topad = 1'b1;						// /RD asserted: PPU releases AD
		#1;
		chk("ADPads floats when RD_topad=1", ADPads === 8'bz);

		// external VRAM drives data; PD_out must follow
		adpads_drv = 1; adpads_val = 8'h3C;
		#1;
		chk("ADPads reads external data", ADPads === 8'h3C);
		chk("PD_out = AD bus (external data)", PD_out === 8'h3C);
		adpads_val = 8'h00; #1;
		chk("PD_out = AD bus (0x00)", PD_out === 8'h00);
		adpads_val = 8'hFF; #1;
		chk("PD_out = AD bus (0xFF)", PD_out === 8'hFF);
		adpads_drv = 0;

		// ============ RES / RC ==============================================
		// RC (register clear) follows the /RES pad: RC = RES = ~n_RESPad.
		// The register file is cleared only while /RES is asserted and
		// becomes writable (and persists across frames) as soon as /RES is
		// released.  RESCL (VBlank-end "Reset FF Clear") must have no effect
		// on RC (the old RC=~latch behaviour wiped the registers at every
		// VBlank end - fixed in pads.v).
		n_RESPad = 1'b1; RESCL = 1'b0; #1;		// idle
		chk("RES = ~n_RESPad (idle)", RES === 1'b0);
		chk("RC = 0 while not resetting", RC === 1'b0);
		n_RESPad = 1'b0; RESCL = 1'b0; #1;		// /RES asserted
		chk("RES = ~n_RESPad (asserted)", RES === 1'b1);
		chk("RC = 1 while /RES is asserted", RC === 1'b1);
		// RESCL while resetting: still clearing
		RESCL = 1'b1; #1;
		chk("RC stays 1 with RESCL during reset", RC === 1'b1);
		n_RESPad = 1'b1; #1;					// /RES released
		chk("RES follows pad (released)", RES === 1'b0);
		chk("RC = 0 once /RES is released", RC === 1'b0);
		// RESCL after release must not re-assert RC (no VBlank-end wipe)
		RESCL = 1'b0; #1;
		chk("RC stays 0 after RESCL pulse", RC === 1'b0);
		RESCL = 1'b1; #1;
		chk("RC stays 0 while RESCL=1 after release", RC === 1'b0);
		RESCL = 1'b0; #1;
		// a new /RES pulse clears again, still independent of RESCL
		n_RESPad = 1'b0; #1;
		chk("new /RES pulse clears again (RC=1)", RC === 1'b1);
		RESCL = 1'b1; #1;
		chk("RC=1 regardless of RESCL during reset", RC === 1'b1);
		n_RESPad = 1'b1; RESCL = 1'b0; #1;
		chk("idle: RC=0", RC === 1'b0);
		// identity RC === RES for all pad/RESCL combinations
		for (v = 0; v < 4; v = v + 1) begin
			n_RESPad = v[0];
			RESCL = v[1];
			#1;
			chk("RES = ~n_RESPad (identity)", RES === ~n_RESPad);
			chk("RC = RES (identity)", RC === RES);
			chk("RC = ~n_RESPad (identity)", RC === ~n_RESPad);
		end
		n_RESPad = 1'b1; RESCL = 1'b0; #1;

		// ============ CPU D0-D7 pads ========================================
		// --- read: internal CPU_DB -> DPads while n_CpuRD=0 ---------------
		n_CpuRD = 1'b0; n_CpuWR = 1'b1;
		cpu_db_drv = 1; dpads_drv = 0;
		for (v = 0; v < 4; v = v + 1) begin
			case (v)
				0: cpu_db_val = 8'h00;
				1: cpu_db_val = 8'hA5;
				2: cpu_db_val = 8'hFF;
				3: cpu_db_val = 8'h55;
			endcase
			#1;
			chk("read: DPads mirrors CPU_DB", DPads === cpu_db_val);
		end
		cpu_db_drv = 0;

		// --- write: external DPads -> CPU_DB while n_CpuWR=0 ---------------
		n_CpuRD = 1'b1; n_CpuWR = 1'b0;
		dpads_drv = 1; cpu_db_drv = 0;
		for (v = 0; v < 4; v = v + 1) begin
			case (v)
				0: dpads_val = 8'hFF;
				1: dpads_val = 8'h0F;
				2: dpads_val = 8'h00;
				3: dpads_val = 8'hAA;
			endcase
			#1;
			chk("write: CPU_DB mirrors DPads", CPU_DB === dpads_val);
		end
		dpads_drv = 0;

		// --- idle: both strobes high, nothing drives anything ---------------
		n_CpuRD = 1'b1; n_CpuWR = 1'b1;
		#1;
		chk("idle: DPads floating", DPads === 8'bz);
		chk("idle: CPU_DB floating", CPU_DB === 8'bz);

		// --- strobes are exclusive: read never drives CPU_DB ---------------
		// (module must not fight the internal logic on CPU_DB during read)
		n_CpuRD = 1'b0; n_CpuWR = 1'b1;
		cpu_db_drv = 0;							// nothing drives CPU_DB
		#1;
		chk("read w/o internal driver: CPU_DB stays z", CPU_DB === 8'bz);
		cpu_db_drv = 1; cpu_db_val = 8'h80; #1;
		chk("read: DPads = CPU_DB again", DPads === 8'h80);
		cpu_db_drv = 0;
		n_CpuRD = 1'b1;

		// ============ EXT pads ==============================================
		// --- slave mode (n_SLAVE=0): reads the external picture -----------
		n_SLAVE = 1'b0;
		extpads_drv = 1; extpads_val = 4'b0110;
		#1;
		chk("slave: EXT_in = EXTPads", EXT_in === 4'b0110);
		extpads_val = 4'b1001; #1;
		chk("slave: EXT_in = EXTPads (2)", EXT_in === 4'b1001);
		extpads_drv = 0; #1;
		chk("slave: EXTPads not driven (z)", EXTPads === 4'bz);

		// --- master mode (n_SLAVE=1): drives EXTPads from latched n_EXT_out
		n_SLAVE = 1'b1;
		n_PCLK = 1'b1;							// output latch transparent
		n_EXT_out = 4'b1010;					// inverted picture from the mux
		#1;
		chk("master: EXTPads = ~n_EXT_out", EXTPads === 4'b0101);
		chk("master: EXT_in forced to 0", EXT_in === 4'b0000);
		// hold phase (n_PCLK=0): the value is latched
		n_PCLK = 1'b0;
		n_EXT_out = 4'b0000;					// mux output changes
		#1;
		chk("master: EXTPads holds during n_PCLK=0", EXTPads === 4'b0101);
		n_PCLK = 1'b1;							// transparent again
		#1;
		chk("master: EXTPads updates when n_PCLK=1", EXTPads === 4'b1111);
		n_EXT_out = 4'b1111; #1;
		chk("master: EXTPads = ~n_EXT_out (2)", EXTPads === 4'b0000);
		// alternate latch edge again
		n_PCLK = 1'b0; #1;
		n_EXT_out = 4'b1100; #1;
		chk("master: latch holds 0000", EXTPads === 4'b0000);
		n_PCLK = 1'b1; #1;
		chk("master: EXTPads = ~1100 = 0011", EXTPads === 4'b0011);

		// ============ /INT (open-drain) =====================================
		Int_topad = 1'b0; #1;
		chk("n_INTPad is z while no interrupt", n_INTPad === 1'bz);
		Int_topad = 1'b1; #1;
		chk("n_INTPad pulled low on interrupt", n_INTPad === 1'b0);
		Int_topad = 1'b0; #1;
		chk("n_INTPad back to z", n_INTPad === 1'bz);

		if (errors == 0)
			$display("pads_test: TEST PASS (%0d checks)", checks);
		else
			$display("pads_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // pads_test
