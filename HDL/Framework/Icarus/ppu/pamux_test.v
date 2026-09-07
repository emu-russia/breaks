// PAMUX (PPU address multiplexer) self-check.
// Reference: BreakingNESWiki/PPU/pamux.md and the fetch structure of the
// PPU_FSM (fsm.v): during rendering the PPU places one of three addresses
// on the external VRAM bus /PA0-13 for each fetch:
//   - name-table fetch          -> NT_ADR (tile counters)
//   - attribute-table fetch     -> AT_ADR (tile counters)
//   - pattern byte fetch (BG/OB)-> PAT_ADR (PAR)
// and when the CPU owns the VRAM port (DB_PAR) the low 8 bits come from the
// CPU data bus (CPU_DB).  The bus is active low: n_PA = ~selected_address.
//
// Fetch select decoding (PamuxControl + bit cells, active-high):
//   PARR = ~(n_H2_D | BLNK)   pattern-fetch window
//   PAH  = ~(PARR | F_AT)     name-table select
//   PAL  = PAH & ~DB_PAR      name-table select for the low bits
// Cell priority: DB_PAR > PARR(PAT) > PAH/PAL(NT) > F_AT(AT).
// While BLNK=1 (blanking / vblank) the PPU outputs the refresh address,
// which is the name-table (scroll) address NT_ADR.

`timescale 1ns/1ns

module pamux_test ();

	reg PCLK;
	reg n_H2_D;
	reg BLNK;
	reg F_AT;
	reg DB_PAR;
	reg [13:0] AT_ADR_in;
	reg [13:0] NT_ADR_in;
	reg [13:0] PAT_ADR_in;
	reg [7:0] CPU_DB;
	wire [13:0] n_PA;

	PAMUX uut (
		.PCLK(PCLK),
		.n_H2_D(n_H2_D),
		.BLNK(BLNK),
		.F_AT(F_AT),
		.DB_PAR(DB_PAR),
		.AT_ADR_in(AT_ADR_in),
		.NT_ADR_in(NT_ADR_in),
		.PAT_ADR_in(PAT_ADR_in),
		.CPU_DB(CPU_DB),
		.n_PA(n_PA) );

	integer errors = 0;
	integer checks = 0;

	// distinctive source values (bits well spread)
	localparam [13:0] NT = 14'b10_1010_1010_1010;  // 0x2AAA
	localparam [13:0] AT = 14'b01_0101_0101_0101;  // 0x1555
	localparam [13:0] PAT = 14'b00_1100_1100_1100; // 0x0CCC

	// Drive the controls for one pixel period so the output latch samples
	// the newly selected source, then sample n_PA during the hold phase.
	task apply_and_sample(input [99:0] what,
			input n_h2d, input blnk, input f_at, input db_par, input [13:0] exp);
		begin
			n_H2_D = n_h2d; BLNK = blnk; F_AT = f_at; DB_PAR = db_par;
			// let the mux settle and the PCLK output latch capture
			repeat (2) begin
				PCLK = 1'b1; #10;
				PCLK = 1'b0; #10;
			end
			checks = checks + 1;
			if (n_PA !== exp) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL: %s exp=%b got=%b", what, exp, n_PA);
			end
		end
	endtask

	initial begin
		$dumpfile("pamux_test.vcd");
		$dumpvars(0, pamux_test);

		PCLK = 1'b0;
		AT_ADR_in = AT;
		NT_ADR_in = NT;
		PAT_ADR_in = PAT;
		CPU_DB = 8'h5A;

		// ---- blanking: refresh addressing = name-table (scroll) address
		apply_and_sample("BLNK refresh -> NT_ADR",       1, 1, 0, 0, ~NT);

		// ---- rendering, name-table fetch (n_H2_D=1 => PARR=0)
		apply_and_sample("NT fetch -> NT_ADR",           1, 0, 0, 0, ~NT);
		apply_and_sample("AT fetch -> AT_ADR",           1, 0, 1, 0, ~AT);

		// ---- pattern fetch window: n_H2_D=0 => PARR=1 -> PAT_ADR
		//      (even if F_AT is also high, PARR has priority)
		apply_and_sample("pattern fetch -> PAT_ADR",     0, 0, 0, 0, ~PAT);
		apply_and_sample("PARR dominates F_AT -> PAT_ADR", 0, 0, 1, 0, ~PAT);

		// ---- CPU access: DB_PAR -> low 8 bits from CPU_DB
		//      (the active-low low byte equals ~CPU_DB)
		apply_and_sample("DB_PAR low8 <- CPU_DB",        1, 0, 0, 1, {~NT[13:8], ~CPU_DB});

		if (errors == 0)
			$display("pamux_test: TEST PASS (%0d checks)", checks);
		else
			$display("pamux_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // pamux_test
