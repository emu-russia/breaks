// Envelope Unit
// Shared between the square channels and the noise generator.

module Envelope_Unit (n_ACLK, RES, WR_Reg, WR_LC, n_LFO1, DB, V, LC);

	input n_ACLK;
	input RES;
	input WR_Reg;
	input WR_LC;
	input n_LFO1;
	inout [7:0] DB;
	output [3:0] V;
	output LC;

endmodule // Envelope_Unit
