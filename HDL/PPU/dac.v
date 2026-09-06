
// Composite video DAC. Maps the 11-bit raw video word to a floating-point
// composite voltage (returned as IEEE-754 bits).

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

	assign CompositeOut = $realtobits(v);

endmodule // PPU_CompositeDAC
