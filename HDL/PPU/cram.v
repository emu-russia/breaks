
module CRAM_Block (
	n_PCLK, PCLK,
	n_R7, n_DBE, TH_MUX, DB_PAR, n_PICTURE, BnW,
	PAL,
	CPU_DB, 
	n_CC, n_LL);

	input n_PCLK;
	input PCLK;

	input n_R7;
	input n_DBE;
	input TH_MUX;
	input DB_PAR;
	input n_PICTURE;
	input BnW;

	input [4:0] PAL;

	inout [7:0] CPU_DB;

	output [3:0] n_CC;
	output [1:0] n_LL;

	wire n_CB_DB;
	wire color_mode;
	wire n_DB_CB;

	wire [5:0] cram_val;
	wire [5:0] CB_Out;
	wire [3:0] COL;
	wire [6:0] ROW;

	CB_Control cbctl(
		.PCLK(PCLK),
		.n_R7(n_R7),
		.n_DBE(n_DBE),
		.TH_MUX(TH_MUX),
		.DB_PAR(DB_PAR),
		.n_PICTURE(n_PICTURE),
		.BnW(BnW),
		.n_CB_DB(n_CB_DB),
		.n_BW(color_mode),
		.n_DB_CB(n_DB_CB) );

	ColorBuf cb(
		.n_PCLK(n_PCLK),
		.PCLK(PCLK),
		.CPU_DB(CPU_DB),
		.n_DB_CB(n_DB_CB),
		.n_CB_DB(n_CB_DB),
		.n_OE(color_mode),
		.cram_val(cram_val),
		.CB_Out(CB_Out) );

	CRAM_Decoder cramdec(
		.PCLK(PCLK),
		.PAL(PAL),
		.COL(COL),
		.ROW(ROW) );

	CRAM cram(
		.PCLK(PCLK),
		.COL(COL),
		.ROW(ROW),
		.cram_val(cram_val) );

endmodule // CRAM_Block

module CB_Control(
	PCLK,
	n_R7, n_DBE, TH_MUX, DB_PAR, n_PICTURE, BnW,
	n_CB_DB, n_BW, n_DB_CB);

	input PCLK;

	input n_R7;
	input n_DBE;
	input TH_MUX;
	input DB_PAR;
	input n_PICTURE;
	input BnW;

	output n_CB_DB;
	output n_BW;
	output n_DB_CB;

endmodule // CB_Control

module ColorBuf(
	n_PCLK, PCLK,
	CPU_DB,
	n_DB_CB, n_CB_DB, n_OE, cram_val,
	CB_Out );

	input n_PCLK;
	input PCLK;

	inout [7:0] CPU_DB;

	input n_DB_CB;
	input n_CB_DB;
	input n_OE;
	inout [5:0] cram_val;

	output [5:0] CB_Out;

endmodule // ColorBuf

module CRAM_Decoder(PCLK, PAL, COL, ROW);

	input PCLK;
	input [4:0] PAL;
	output [3:0] COL;
	output [6:0] ROW;

endmodule // CRAM_Decoder

module CRAM(PCLK, COL, ROW, cram_val);

	input PCLK;
	input [3:0] COL;
	input [6:0] ROW;
	inout [5:0] cram_val;

endmodule // CRAM
