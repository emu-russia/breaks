`timescale 1ns/1ns

module BusMux (PHI2, SB, DB, ADL, ADH, Z_ADL0, Z_ADL1, Z_ADL2, Z_ADH0, Z_ADH17, SB_DB, SB_ADH );

	input PHI2;
	inout [7:0] SB;
	inout [7:0] DB;
	inout [7:0] ADL;
	inout [7:0] ADH;

	input Z_ADL0;
	input Z_ADL1;
	input Z_ADL2;
	input Z_ADH0;
	input Z_ADH17;
	input SB_DB;
	input SB_ADH;

	BusPrecharge precharge (
		.PHI2(PHI2),
		.SB(SB),
		.DB(DB),
		.ADL(ADL),
		.ADH(ADH) );

	ConstGen constgen (
		.ADL(ADL),
		.ADH(ADH),
		.Z_ADL0(Z_ADL0),
		.Z_ADL1(Z_ADL1),
		.Z_ADL2(Z_ADL2),
		.Z_ADH0(Z_ADH0),
		.Z_ADH17(Z_ADH17) );

	BusVsBus busbus (
		.SB(SB),
		.DB(DB),
		.ADH(ADH),
		.SB_DB(SB_DB),
		.SB_ADH(SB_ADH) );

endmodule // BusMux

module BusPrecharge (PHI2, SB, DB, ADL, ADH );

	input PHI2;
	inout [7:0] SB;
	inout [7:0] DB;
	inout [7:0] ADL;
	inout [7:0] ADH;

	assign SB = PHI2 ? 8'b11111111 : 8'bzzzzzzzz;
	assign DB = PHI2 ? 8'b11111111 : 8'bzzzzzzzz;
	assign ADL = PHI2 ? 8'b11111111 : 8'bzzzzzzzz;
	assign ADH = PHI2 ? 8'b11111111 : 8'bzzzzzzzz;

endmodule // BusPrecharge

module ConstGen (ADL, ADH, Z_ADL0, Z_ADL1, Z_ADL2, Z_ADH0, Z_ADH17);

	inout [7:0] ADL;
	inout [7:0] ADH;
	input Z_ADL0;
	input Z_ADL1;
	input Z_ADL2;
	input Z_ADH0;
	input Z_ADH17;

	assign ADL[0] = Z_ADL0 ? 1'b0 : 1'bz;
	assign ADL[1] = Z_ADL1 ? 1'b0 : 1'bz;
	assign ADL[2] = Z_ADL2 ? 1'b0 : 1'bz;

	assign ADH[0] = Z_ADH0 ? 1'b0 : 1'bz;
	assign ADH[7:1] = Z_ADH17 ? 7'b0000000 : 7'bzzzzzzz;

endmodule // ConstGen

module BusVsBus (SB, DB, ADH, SB_DB, SB_ADH);

	inout [7:0] SB;
	inout [7:0] DB;
	inout [7:0] ADH;
	input SB_DB;
	input SB_ADH;

	tranif1 sb_db [7:0] (SB, DB, {8{SB_DB}});
	tranif1 sb_adh [7:0] (SB, ADH, {8{SB_ADH}});

endmodule // BusVsBus
