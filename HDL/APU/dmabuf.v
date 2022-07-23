
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

	wire PPU_SPR;
	assign PPU_SPR = ~SPR_PPU;

	nor (RW_topad, ~RnW_fromcore, SPR_PPU);
	assign RD_topad = RW_topad;
	nand (WR_topad, n_R4015, n_DBGRD, RW_topad);

	wire [7:0] spr_buf_out;

	dlatch spr_buf [7:0] (
		.d(DB),
		.en(PHI2),
		.nq(spr_buf_out) );

	bustris spr_tris [7:0] (
		.a(spr_buf_out),
		.n_x(DB),
		.n_en(PPU_SPR) );

endmodule // DMABuffer
