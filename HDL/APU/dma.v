
module Sprite_DMA(
	n_ACLK, ACLK, PHI1, PHI2,
	RES, RnW, W4014, DB, 
	RUNDMC, n_DMCAB, DMCRDY, DMC_Addr, CPU_Addr,
	Addr, RDY_tocore, SPR_PPU);

	input n_ACLK;
	input ACLK;
	input PHI1;
	input PHI2;

	input RES;
	input RnW;
	input W4014;
	inout [7:0] DB;

	input RUNDMC;
	input n_DMCAB;
	input DMCRDY;
	input [15:0] DMC_Addr;
	input [15:0] CPU_Addr;

	output [15:0] Addr;
	output RDY_tocore;
	output SPR_PPU;

endmodule // Sprite_DMA
