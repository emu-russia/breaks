// Composite video DAC (PPU_CompositeDAC) self-check against the documented
// level table.
//
// Reference: BreakingNESWiki/PPU/video_out.md ("ЦАП" section): the unloaded
// composite voltage for each level L is
//     L0  0.781  Sync            L5  1.743  Color 2D
//     L1  1.000  Colorburst L    L6  1.875  Color 00
//     L2  1.131  Color 0D        L7  2.287  Color 10
//     L3  1.300  Color 1D(black) L8  2.331  Color 3D
//     L4  1.712  Colorburst H    L9  2.743  Color 20/30
// TINT (RawIn[10], "emphasis") multiplies the level by ~0.746 and the sync
// bit (RawIn[0]) forces the sync level (0.781).  The phase-swing level L is
// the highest asserted bit of RawIn[9:1] (resistor-ladder model).
//
// The DAC returns the voltage as IEEE-754 single precision on a 32-bit bus,
// so the test decodes the bits back to a real and compares with the
// documented values (tolerance well above the float32 ulp).
// Compiled with -D RP2C02 -D ICARUS.

`timescale 1ns/1ns

module dac_test ();

	reg [10:0] RawIn;
	wire [31:0] CompositeOut;

	PPU_CompositeDAC uut (.RawIn(RawIn), .CompositeOut(CompositeOut));

	integer errors = 0;
	integer checks = 0;
	integer raw, i, L;

	// Decode an IEEE-754 single (32-bit) value to a real.
	function automatic real f32toreal(input [31:0] bits);
		integer e;
		integer k;
		real val;
		begin
			e = bits[30:23];
			if (e == 8'd255) begin
				f32toreal = 0.0;		// inf/NaN: not expected in this test
			end else begin
				val = 1.0 + (bits[22:0] / 8388608.0);
				if (e > 127) begin
					for (k = 0; k < e - 127; k = k + 1) val = val * 2.0;
				end else if (e < 127) begin
					for (k = 0; k < 127 - e; k = k + 1) val = val / 2.0;
				end
				if (bits[31]) val = -val;
				f32toreal = val;
			end
		end
	endfunction

	// Reference level table (documented in the wiki, not taken from the module).
	function automatic real doc_level(input integer L);
		begin
			case (L)
				0: doc_level = 0.781;	// sync
				1: doc_level = 1.000;	// colorburst L
				2: doc_level = 1.131;	// color 0D
				3: doc_level = 1.300;	// color 1D (black)
				4: doc_level = 1.712;	// colorburst H
				5: doc_level = 1.743;	// color 2D
				6: doc_level = 1.875;	// color 00
				7: doc_level = 2.287;	// color 10
				8: doc_level = 2.331;	// color 3D
				9: doc_level = 2.743;	// color 20/30
				default: doc_level = -1.0;
			endcase
		end
	endfunction

	// The documented level table itself must be strictly increasing: more
	// current through the ladder always yields a higher voltage.
	function automatic bit doc_level_monotonic;
		begin
			doc_level_monotonic = 1'b1;
			for (i = 1; i <= 9; i = i + 1)
				if (!(doc_level(i) > doc_level(i - 1))) doc_level_monotonic = 1'b0;
		end
	endfunction

	real got;
	real exp_v;

	initial begin
		$dumpfile("dac_test.vcd");
		$dumpvars(0, dac_test);

		// --- sanity of the test's own reference ---------------------------
		checks = checks + 1;
		if (!doc_level_monotonic()) begin
			errors = errors + 1;
			$display("FAIL: internal doc_level table is not strictly increasing");
		end

		// --- canonical spot checks: RawIn = 1<<L (level L, no tint/sync) ---
		for (L = 0; L <= 9; L = L + 1) begin
			RawIn = (L == 0) ? 11'b0 : (11'd1 << L);
			#1;
			got = f32toreal(CompositeOut);
			checks = checks + 1;
			if (got > doc_level(L) + 1.0e-6 || got < doc_level(L) - 1.0e-6) begin
				errors = errors + 1;
				$display("FAIL: level %0d raw=%b got=%0.9f exp=%0.9f", L, RawIn, got, doc_level(L));
			end
		end

		// --- full sweep of the whole 11-bit space (2048 values) -----------
		// The expected voltage for each raw word is built from the documented
		// table + the documented override semantics:
		//   level L = highest asserted bit of RawIn[9:1];
		//   TINT (RawIn[10]) scales by 0.746;
		//   sync (RawIn[0]) overrides everything to 0.781.
		for (raw = 0; raw < 2048; raw = raw + 1) begin
			// top level among the phase-swing bits
			L = 0;
			for (i = 9; i >= 1; i = i - 1)
				if (raw[i]) begin L = i; i = 1; end	// take the highest set bit
			RawIn = raw[10:0];
			#1;
			got = f32toreal(CompositeOut);
			exp_v = doc_level(L);
			if (raw[10]) exp_v = exp_v * 0.746;
			if (raw[0])  exp_v = 0.781;
			checks = checks + 1;
			if (got > exp_v + 1.0e-6 || got < exp_v - 1.0e-6) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL: raw=%04b_%b L=%0d got=%0.9f exp=%0.9f", raw[10:4], raw[0], L, got, exp_v);
			end
		end

		// --- emphasis factor (documented ~0.746) at each level -------------
		for (L = 0; L <= 9; L = L + 1) begin
			RawIn = (L == 0) ? 11'b0 : (11'd1 << L);
			#1;
			got = f32toreal(CompositeOut);
			RawIn = RawIn | 11'h400;			// TINT
			#1;
			checks = checks + 1;
			if (f32toreal(CompositeOut) > got * 0.746 + 2.0e-5 ||
			    f32toreal(CompositeOut) < got * 0.746 - 2.0e-5) begin
				errors = errors + 1;
				$display("FAIL: emphasis ratio at L=%0d: %0.9f vs %0.9f*0.746", L, f32toreal(CompositeOut), got);
			end
		end

		// --- sync override is absolute ------------------------------------
		for (raw = 1; raw < 2048; raw = raw + 1) begin
			if (raw[0]) begin
				RawIn = raw[10:0];
				#1;
				checks = checks + 1;
				got = f32toreal(CompositeOut);
				if (got > 0.781 + 1.0e-6 || got < 0.781 - 1.0e-6) begin
					errors = errors + 1;
					if (errors <= 20)
						$display("FAIL: sync override raw=%o got=%0.9f", raw, got);
				end
			end
		end

		if (errors == 0)
			$display("dac_test: TEST PASS (%0d checks)", checks);
		else
			$display("dac_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // dac_test
