
// Composite video DAC. Maps the 11-bit raw video word to a floating-point
// composite voltage.
//
// The voltage is returned as an IEEE-754 single-precision (32-bit) value:
// the CompositeOut port is 32 bits wide and the levels only need the
// precision of a float.  A plain `$realtobits(v)` would produce the 64-bit
// double bit pattern, which does not fit the port (Icarus truncates it to
// the low 32 bits - an encoding that matches neither float32 nor float64),
// so the value is converted explicitly (round to nearest even).

module PPU_CompositeDAC (RawIn, CompositeOut);

	input [10:0] RawIn;
	output [31:0] CompositeOut;

	// Level L is the highest asserted phase-swing bit (a simplified model of
	// the resistor ladder in the transistor schematic).
	wire [3:0] L = RawIn[9] ? 4'd9 : RawIn[8] ? 4'd8 : RawIn[7] ? 4'd7 :
	               RawIn[6] ? 4'd6 : RawIn[5] ? 4'd5 : RawIn[4] ? 4'd4 :
	               RawIn[3] ? 4'd3 : RawIn[2] ? 4'd2 : RawIn[1] ? 4'd1 : 4'd0;

	real v;
	always @(*) begin
		case (L)
			4'd0: v = 0.781; // sync
			4'd1: v = 1.000; // colorburst L
			4'd2: v = 1.131; // color 0D
			4'd3: v = 1.300; // color 1D (black)
			4'd4: v = 1.712; // colorburst H
			4'd5: v = 1.743; // color 2D
			4'd6: v = 1.875; // color 00
			4'd7: v = 2.287; // color 10
			4'd8: v = 2.331; // color 3D
			4'd9: v = 2.743; // color 20/30
			default: v = 1.300;
		endcase
		if (RawIn[10]) v = v * 0.746; // emphasis (TINT)
		if (RawIn[0])  v = 0.781;     // sync pulse overrides
	end

	// ---- real (double) -> IEEE-754 single conversion ---------------------

	reg [63:0] d;
	reg [10:0] d_exp;
	reg [51:0] d_man;
	reg [22:0] f23;
	reg [7:0]  e8;
	reg round_up;
	reg [31:0] out;

	always @(*) begin
		d = $realtobits(v);
		d_exp = d[62:52];
		d_man = d[51:0];
		f23   = d_man[51:29];

		if (d_exp == 11'h7FF) begin
			// inf/NaN: pass through (kept for completeness, not reachable here)
			e8 = 8'hFF;
		end else if (d_exp > 11'h47E) begin
			// |v| >= 2^128: overflow to +/-inf (not reachable here)
			e8 = 8'hFF;
			f23 = 23'b0;
		end else if (d_exp < 11'h381) begin
			// |v| < 2^-126: would need a single denormal - clamp to zero
			// (not reachable for video levels)
			e8 = 8'h00;
			f23 = 23'b0;
		end else begin
			// normal range:  single exponent = double exponent - 1023 + 127
			e8 = d_exp - 11'h380;
			// round to nearest even on the 29 dropped low mantissa bits
			round_up = d_man[28] && (|d_man[27:0] || f23[0]);
			if (round_up) begin
				if (f23 == 23'h7FFFFF) begin
					f23 = 23'b0;
					e8  = e8 + 1'b1;
				end else
					f23 = f23 + 1'b1;
			end
		end

		out = {d[63], e8, f23};
	end

	assign CompositeOut = out;

endmodule // PPU_CompositeDAC
