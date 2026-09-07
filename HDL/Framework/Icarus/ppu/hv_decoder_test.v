// H/V decoder (HVDecoder) self-check against the documented PLA tables.
// Reference: BreakingNESWiki/PPU/hv_decoder.md (NTSC) and BreakingNESWiki/PPU/pal.md (PAL):
//   each HPLA output N fires on exactly the listed pixel numbers of a scanline
//   (with optional VB/BLNK "transistor" gating: the output is forced low while
//   VB=1 or BLNK=1), and each VPLA output fires on exactly the listed scanline.
// Compiled with -D RP2C02 (NTSC) or -D RP2C07 (PAL); both must pass.

`timescale 1ns/1ns

module hv_decoder_test ();

	reg [8:0] H;
	reg [8:0] V;
	reg VB;
	reg BLNK;

	wire [23:0] HPLA_out;
	wire [9:0] VPLA_out;

	HVDecoder uut (
		.H_in(H), .V_in(V), .VB(VB), .BLNK(BLNK),
		.HPLA_out(HPLA_out), .VPLA_out(VPLA_out) );

	integer errors = 0;
	integer checks = 0;
	integer h, v, i, g;

	// Does HPLA output `n` contain a VB gate / BLNK gate?
	function automatic bit h_vb_gated(input integer n);
		begin
			h_vb_gated = 1'b0;
`ifdef RP2C02
			if (n == 4 || n == 10) h_vb_gated = 1'b1;
`elsif RP2C07
			if (n == 4 || n == 10) h_vb_gated = 1'b1;
`else
`endif
		end
	endfunction

	function automatic bit h_blnk_gated(input integer n);
		begin
			h_blnk_gated = 1'b0;
`ifdef RP2C02
			if (n == 2 || n == 5 || n == 6 || n == 7 || n == 8 ||
			    n == 9 || n == 10 || n == 11 || n == 14 || n == 15)
				h_blnk_gated = 1'b1;
`elsif RP2C07
			if (n == 2 || n == 5 || n == 6 || n == 7 || n == 8 ||
			    n == 9 || n == 10 || n == 11 || n == 14 || n == 15)
				h_blnk_gated = 1'b1;
`else
`endif
		end
	endfunction

	// Which pixel numbers fire HPLA output `n` (VB=0, BLNK=0)?
	function automatic bit h_fires(input integer n, input integer h);
		begin
			h_fires = 1'b0;
`ifdef RP2C02
			case (n)
				0:  h_fires = (h == 279);
				1:  h_fires = (h == 256);
				2:  h_fires = (h == 65);
				3:  h_fires = ((h >= 0 && h <= 7) || (h >= 256 && h <= 263));
				4:  h_fires = (h <= 255);
				5:  h_fires = (h == 339);
				6:  h_fires = (h == 63);
				7:  h_fires = (h == 255);
				8:  h_fires = (h <= 63);
				9:  h_fires = (h >= 256 && h <= 319);
				10: h_fires = (h <= 255);
				11: h_fires = (h % 8 == 0 || h % 8 == 1);
				12: h_fires = (h % 8 == 6 || h % 8 == 7);
				13: h_fires = (h % 8 == 4 || h % 8 == 5);
				14: h_fires = (h >= 320 && h <= 335);
				15: h_fires = (h <= 255);
				16: h_fires = (h % 8 == 2 || h % 8 == 3);
				17: h_fires = (h == 270);
				18: h_fires = (h == 328);
				19: h_fires = (h == 279);
				20: h_fires = (h == 304);
				21: h_fires = (h == 323);
				22: h_fires = (h == 308);
				23: h_fires = (h == 340);
				default: h_fires = 1'b0;
			endcase
`elsif RP2C07
			case (n)
				0:  h_fires = (h == 277);
				1:  h_fires = (h == 256);
				2:  h_fires = (h == 65);
				3:  h_fires = ((h >= 0 && h <= 7) || (h >= 256 && h <= 263));
				4:  h_fires = (h <= 255);
				5:  h_fires = (h == 339);
				6:  h_fires = (h == 63);
				7:  h_fires = (h == 255);
				8:  h_fires = (h <= 63);
				9:  h_fires = (h >= 256 && h <= 319);
				10: h_fires = (h <= 255);
				11: h_fires = (h % 8 == 0 || h % 8 == 1);
				12: h_fires = (h % 8 == 6 || h % 8 == 7);
				13: h_fires = (h % 8 == 4 || h % 8 == 5);
				14: h_fires = (h >= 320 && h <= 335);
				15: h_fires = (h <= 255);
				16: h_fires = (h % 8 == 2 || h % 8 == 3);
				17: h_fires = (h == 256);
				18: h_fires = (h == 4);
				19: h_fires = (h == 277);
				20: h_fires = (h == 302);
				21: h_fires = (h == 321);
				22: h_fires = (h == 306);
				23: h_fires = (h == 340);
				default: h_fires = 1'b0;
			endcase
`else
`endif
		end
	endfunction

	// Which scanlines fire VPLA output `n`?
	function automatic bit v_fires(input integer n, input integer v);
		begin
			v_fires = 1'b0;
`ifdef RP2C02
			case (n)
				0: v_fires = (v == 247);
				1: v_fires = (v == 244);
				2: v_fires = (v == 261);
				3: v_fires = (v == 241);
				4: v_fires = (v == 241);
				5: v_fires = (v == 0);
				6: v_fires = (v == 240);
				7: v_fires = (v == 261);
				8: v_fires = (v == 261);
				9: v_fires = 1'b0;		// not present in NTSC PPUs
				default: v_fires = 1'b0;
			endcase
`elsif RP2C07
			case (n)
				0: v_fires = (v == 272);
				1: v_fires = (v == 269);
				2: v_fires = (v == 1);
				3: v_fires = (v == 240);
				4: v_fires = (v == 241);
				5: v_fires = (v == 0);
				6: v_fires = (v == 240);
				7: v_fires = (v == 311);
				8: v_fires = (v == 311);
				9: v_fires = (v == 265);
				default: v_fires = 1'b0;
			endcase
`else
`endif
		end
	endfunction

	integer hmax, vmax;

	initial begin
`ifdef RP2C02
		$dumpfile("hv_decoder_test_ntsc.vcd");
`elsif RP2C07
		$dumpfile("hv_decoder_test_pal.vcd");
`else
		$dumpfile("hv_decoder_test.vcd");
`endif
		$dumpvars(0, hv_decoder_test);

`ifdef RP2C02
		hmax = 340;
		vmax = 261;
`elsif RP2C07
		hmax = 340;
		vmax = 311;
`else
		hmax = 340;
		vmax = 261;
`endif

		// H decoder: sweep every pixel, every VB/BLNK combination.
		for (h = 0; h <= hmax; h = h + 1) begin
			H = h[8:0];
			for (g = 0; g < 4; g = g + 1) begin
				VB = g[1];
				BLNK = g[0];
				#1;
				for (i = 0; i < 24; i = i + 1) begin
					checks = checks + 1;
					if (HPLA_out[i] !== (h_fires(i, h) && (!h_vb_gated(i) || ~VB) && (!h_blnk_gated(i) || ~BLNK))) begin
						errors = errors + 1;
						if (errors <= 20)
							$display("FAIL: HPLA[%0d] H=%0d VB=%b BLNK=%b got=%b", i, h, VB, BLNK, HPLA_out[i]);
					end
				end
			end
		end

		// V decoder: sweep every scanline.
		for (v = 0; v <= vmax; v = v + 1) begin
			V = v[8:0];
			#1;
			for (i = 0; i < 10; i = i + 1) begin
				checks = checks + 1;
				if (VPLA_out[i] !== v_fires(i, v)) begin
					errors = errors + 1;
					if (errors <= 20)
						$display("FAIL: VPLA[%0d] V=%0d got=%b", i, v, VPLA_out[i]);
				end
			end
		end

		if (errors == 0)
			$display("hv_decoder_test: TEST PASS (%0d checks)", checks);
		else
			$display("hv_decoder_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // hv_decoder_test
