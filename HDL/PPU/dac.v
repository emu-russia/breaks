
module PPU_CompositeDAC (RawIn, CompositeOut);

	input [10:0] RawIn;
	output [31:0] CompositeOut;

	assign CompositeOut = 32'b0;

endmodule // PPU_CompositeDAC
