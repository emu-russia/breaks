
module DMABuffer(PHI2, SPR_PPU, DB, RnW_fromcore, RW_topad, n_R4015, n_DBGRD, WR_topad, RD_topad);

	input PHI2;
	input SPR_PPU;
	inout [7:0] DB;
	input RnW_fromcore;
	output RW_topad;
	input n_R4015;
	input n_DBGRD;
	output WR_topad;
	output RD_topad;

endmodule // DMABuffer
