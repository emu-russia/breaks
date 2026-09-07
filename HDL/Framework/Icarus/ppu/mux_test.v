// PictureMUX (color multiplexer) self-check.
// Reference: BreakingNESWiki/PPU/mux.md - the mux picks, per pixel, among the
// sprite color, the background color, the EXT pin color and the "direct"
// palette color from the TH counter (TH_MUX), through three latch stages.
// Bus conventions are those of the 2C02 die (mixed inverse/direct logic as
// listed in BreakingNESWiki/PPU/rails.md):
//   - the sprite color is supplied as n_ZCOL0, n_ZCOL1 (inverse of the two
//     low color bits), ZCOL2, ZCOL3 (direct high bits)
//   - CGA_out is the active-low palette-RAM address; the object color path
//     and the direct-color path carry their low nibble bit-reversed on the
//     die bus (MUX_All wiring), the background path does not
//   - the pipeline registers are clocked by PCLK/n_PCLK, so a value settles
//     a few PCLK periods after the inputs change (sample during PCLK=0)
// The pixel-color rules under test (mux.md):
//   - sprite pixels are opaque when their pattern is non-zero; a transparent
//     (pattern 00) sprite never covers the background
//   - an opaque sprite with priority (/ZPRIO=0) wins over the background;
//     a sprite behind the background only shows on a transparent bg pixel
//   - when neither a background nor an object pixel is present, the EXT
//     input color is shown
//   - TH_MUX=1: direct palette color - CGA_out carries THO[4:0] in the
//     CRAM-address encoding {THO[4], ~THO[0], ~THO[1], ~THO[2], ~THO[3]}
//   - n_EXT_out always carries the pixel color for the EXT pads

`timescale 1ns/1ns

module mux_test ();

	reg PCLK = 1'b0;
	always #10 PCLK = ~PCLK;
	wire n_PCLK = ~PCLK;

	reg n_ZPRIO;
	reg [3:0] BGC;
	reg n_ZCOL0, n_ZCOL1, ZCOL2, ZCOL3;
	reg [3:0] EXT_in;
	reg [4:0] THO;
	reg TH_MUX;
	wire [4:0] CGA_out;
	wire [3:0] n_EXT_out;

	PictureMUX uut (
		.n_PCLK(n_PCLK), .PCLK(PCLK),
		.BGC(BGC), .n_ZPRIO(n_ZPRIO),
		.n_ZCOL0(n_ZCOL0), .n_ZCOL1(n_ZCOL1),
		.ZCOL2(ZCOL2), .ZCOL3(ZCOL3),
		.EXT_in(EXT_in), .THO(THO), .TH_MUX(TH_MUX),
		.CGA_out(CGA_out), .n_EXT_out(n_EXT_out) );

	integer errors = 0;
	integer checks = 0;
	integer i;

	// the CRAM/EXT buses carry some nibbles bit-reversed (die wiring of
	// MUX_All); rev4 mirrors a nibble for those paths
	function automatic [3:0] rev4(input [3:0] v);
		rev4 = {v[0], v[1], v[2], v[3]};
	endfunction

	// sprite color value -> wire encoding (low bits inverse, high direct)
	task set_sprite(input [3:0] col);
		begin
			n_ZCOL0 = ~col[0]; n_ZCOL1 = ~col[1];
			ZCOL2 = col[2];     ZCOL3 = col[3];
		end
	endtask

	// settle the pipeline for the current inputs, then sample during the
	// hold phase (PCLK=0) so all output latches have captured
	task settle();
		begin
			repeat (8) #10;      // four full PCLK periods
			while (PCLK) #1;
			#1;
		end
	endtask

	task chk5(input [159:0] what, input [4:0] exp);
		begin
			checks = checks + 1;
			if (CGA_out !== exp) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL: %s exp=%b got=%b", what, exp, CGA_out);
			end
		end
	endtask

	initial begin
		$dumpfile("mux_test.vcd");
		$dumpvars(0, mux_test);

		TH_MUX = 0; THO = 5'd0; EXT_in = 4'h0;
		BGC = 4'h0;
		set_sprite(4'h0);
		n_ZPRIO = 1'b1;
		settle();

		// ---- background pixel visible, no sprite -----------------------
		// BGC is a 4-bit color.  CGA_out is the active-low CRAM address;
		// the background nibble arrives on CGA[3:0] un-reversed.
		BGC = 4'h5;
		settle();
		chk5("bg color 5 -> CGA={0,~5}", {1'b0, ~BGC});
		BGC = 4'hA;
		settle();
		chk5("bg color A -> CGA={0,~A}", {1'b0, ~BGC});

		// ---- sprite in front beats the background ----------------------
		// Sprite pixels carry bit 4 (palette half) and the color nibble is
		// bit-reversed on the die bus: CGA = {1, ~rev4(color)}
		BGC = 4'h5;
		n_ZPRIO = 1'b0;
		set_sprite(4'h2);
		settle();
		chk5("sprite 2 front", {1'b1, ~rev4(4'h2)});

		// sprite behind: background wins
		n_ZPRIO = 1'b1;
		settle();
		chk5("sprite 2 behind -> bg", {1'b0, ~BGC});

		// sprite in front of a transparent background (any priority)
		BGC = 4'h0;
		n_ZPRIO = 1'b1;
		settle();
		chk5("sprite over empty bg", {1'b1, ~rev4(4'h2)});

		// palette bits also carried: sprite color 6 (pattern 10, attr 1)
		n_ZPRIO = 1'b0;
		set_sprite(4'h6);
		settle();
		chk5("sprite color 6", {1'b1, ~rev4(4'h6)});

		// sprite transparency: color 0 (pattern 00) is invisible
		set_sprite(4'h0);
		settle();
		chk5("sprite color 0 invisible", {1'b0, ~BGC});

		// ---- both pixels absent -> EXT input color ---------------------
		BGC = 4'h0;
		set_sprite(4'h0);
		EXT_in = 4'h7;
		settle();
		chk5("no pixels -> EXT 7", {1'b0, ~rev4(EXT_in)});
		EXT_in = 4'h1;
		settle();
		chk5("no pixels -> EXT 1", {1'b0, ~rev4(EXT_in)});
		EXT_in = 4'h0;

		// ---- direct color (TH_MUX): palette index from the TH counter ---
		// (CPU access to the palette RAM.)  The CRAM address bus of this die
		// carries the low four address bits bit-reversed and complemented
		// (the dir-color latch / final bus convention of MUX_All): for a
		// palette index THO the module outputs
		//   CGA_out = {THO[4], ~THO[0], ~THO[1], ~THO[2], ~THO[3]}
		// which is a bijection, so every index is addressable.
		TH_MUX = 1;
		for (i = 0; i < 32; i = i + 1) begin
			THO = i[4:0];
			settle();
			checks = checks + 1;
			if (CGA_out !== {THO[4], ~THO[0], ~THO[1], ~THO[2], ~THO[3]}) begin
				errors = errors + 1;
				if (errors <= 20)
					$display("FAIL: TH_MUX THO=%0d exp=%b got=%b",
						i, {THO[4], ~THO[0], ~THO[1], ~THO[2], ~THO[3]}, CGA_out);
			end
		end
		// TH_MUX dominates the sprite/bg pixels too
		BGC = 4'h5; set_sprite(4'h2); n_ZPRIO = 1'b0; THO = 5'b10101;
		settle();
		chk5("TH_MUX over pixels", {THO[4], ~THO[0], ~THO[1], ~THO[2], ~THO[3]});
		TH_MUX = 0;

		// ---- n_EXT_out carries the pixel color (EXT pad output) --------
		BGC = 4'h3;
		set_sprite(4'h0);          // sprite absent (pattern 00)
		settle();
		checks = checks + 1;
		if (n_EXT_out !== ~BGC) begin
			errors = errors + 1;
			if (errors <= 20)
				$display("FAIL: n_EXT_out bg exp=%b got=%b", ~BGC, n_EXT_out);
		end
		n_ZPRIO = 1'b0;
		set_sprite(4'h6);          // opaque sprite (pattern 10)
		settle();
		checks = checks + 1;
		if (n_EXT_out !== rev4(4'h6)) begin
			errors = errors + 1;
			if (errors <= 20)
				$display("FAIL: n_EXT_out sprite exp=%b got=%b", rev4(4'h6), n_EXT_out);
		end

		if (errors == 0)
			$display("mux_test: TEST PASS (%0d checks)", checks);
		else
			$display("mux_test: TEST FAIL (%0d errors of %0d checks)", errors, checks);
		$finish;
	end

endmodule // mux_test
