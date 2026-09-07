module CB_Control (
  input n_DBE,
  input TH_MUX,
  input DB_PAR,
  input n_PICTURE,
  input BnW,
  input PCLK,
  input n_R7,
  output n_BW,
  output n_CB_DB,
  output n_DB_CB );
  wire w0;
  wire w1;
  wire w2;
  wire w3;
  wire w4;
  wire w5;

  assign w0 = ~TH_MUX;
  assign w1 = n_CB_DB & n_PICTURE;
  assign w2 = ~(n_R7 | n_DBE | w0);
  assign n_CB_DB = ~w2;
  assign n_BW = ~(w1 | BnW);
  assign w4 = ~(w3 & TH_MUX);
  assign n_DB_CB = w4;
  dlatch u0 (.en(PCLK), .d(DB_PAR), .q(w3), .nq(w5));
endmodule

module CRAM_Decoder (
  input PCLK,
  input [4:0] CGA,
  output COL2,
  output COL3,
  output COL0,
  output COL1,
  output ROW0_4,
  output ROW1,
  output ROW2,
  output ROW3,
  output ROW5,
  output ROW6,
  output ROW7 );
  wire [2:0] bus310_210;
  wire [1:0] bus310_110;
  wire w0;
  wire w1;
  wire w10;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  // The two demux data inputs are bare Logisim Constants in PPU_Evo.circ
  // (no value attribute => Logisim default = 1): with the data input high the
  // decoder asserts the addressed COL/ROW line (1-of-N), per the CRAM array
  // organisation in BreakingNESWiki/PPU/cram.md.  (Tied to 0, every decoder
  // output stayed permanently deasserted.)
  assign w0 = 1'd1;
  assign w1 = 1'd1;
  assign w4 = w2 | w3;
  assign ROW0_4 = w4 & (~PCLK);
  assign ROW1 = w5 & (~PCLK);
  assign ROW2 = w6 & (~PCLK);
  assign ROW3 = w7 & (~PCLK);
  assign ROW5 = w8 & (~PCLK);
  assign ROW6 = w9 & (~PCLK);
  assign ROW7 = w10 & (~PCLK);
  // The address decode follows the CRAM array organisation of cram.md:
  // columns = {CGA3(msb), CGA2}, rows = {CGA4(msb), CGA1, CGA0} (CGA4 is the
  // background/sprite palette select); physical rows 0 and 4 share the word
  // line ROW0_4. The select concatenations are kept msb-first to match.
  // demux sel=2
  assign COL0 = ({CGA[3], CGA[2]} == 2'd0) ? w0 : 1'b0;
  assign COL1 = ({CGA[3], CGA[2]} == 2'd1) ? w0 : 1'b0;
  assign COL2 = ({CGA[3], CGA[2]} == 2'd2) ? w0 : 1'b0;
  assign COL3 = ({CGA[3], CGA[2]} == 2'd3) ? w0 : 1'b0;
  // demux sel=3
  assign w2 = ({CGA[4], CGA[1], CGA[0]} == 3'd0) ? w1 : 1'b0;
  assign w5 = ({CGA[4], CGA[1], CGA[0]} == 3'd1) ? w1 : 1'b0;
  assign w6 = ({CGA[4], CGA[1], CGA[0]} == 3'd2) ? w1 : 1'b0;
  assign w7 = ({CGA[4], CGA[1], CGA[0]} == 3'd3) ? w1 : 1'b0;
  assign w3 = ({CGA[4], CGA[1], CGA[0]} == 3'd4) ? w1 : 1'b0;
  assign w8 = ({CGA[4], CGA[1], CGA[0]} == 3'd5) ? w1 : 1'b0;
  assign w9 = ({CGA[4], CGA[1], CGA[0]} == 3'd6) ? w1 : 1'b0;
  assign w10 = ({CGA[4], CGA[1], CGA[0]} == 3'd7) ? w1 : 1'b0;
endmodule

module CRAM_Block (
	n_PCLK, PCLK,
	n_R7, n_DBE, TH_MUX, DB_PAR, n_PICTURE, BnW,
	CGA,
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
	input [4:0] CGA;
	inout [7:0] CPU_DB;
	output [3:0] n_CC;
	output [1:0] n_LL;

	// palette storage
	reg [5:0] cram [0:31];
	integer i;
	initial begin
		for (i = 0; i < 32; i = i + 1) cram[i] = 6'b0;
	end

	wire n_BW;
	wire n_CB_DB;
	wire n_DB_CB;

	CB_Control cbctl(
		.PCLK(PCLK),
		.n_R7(n_R7),
		.n_DBE(n_DBE),
		.TH_MUX(TH_MUX),
		.DB_PAR(DB_PAR),
		.n_PICTURE(n_PICTURE),
		.BnW(BnW),
		.n_CB_DB(n_CB_DB),
		.n_BW(n_BW),
		.n_DB_CB(n_DB_CB) );

	// CPU write path: DB -> CB -> CRAM (n_DB_CB = 0, CPU drives DB: n_DBE = 0)
	always @(posedge PCLK) begin
		if (n_DB_CB == 1'b0 && n_DBE == 1'b0)
			cram[CGA] <= CPU_DB[5:0];
	end

	// CPU read path: CRAM -> CB -> DB (n_CB_DB = 0)
	assign CPU_DB = (n_CB_DB == 1'b0) ? {2'b00, cram[CGA]} : 8'bz;

	// Pixel output (inverted). n_BW (the chip's "/BW", node 1350 in
	// visual2c02.md: (in_draw_range | read_2007_output_palette) & ~mono) is
	// high exactly while a picture pixel is drawn (or a $2007 palette read is
	// output) with $2001[0]=0 (BnW=0, color mode); only then the chroma of the
	// addressed palette entry is let through: n_CC = ~cram[CGA][3:0]. In
	// monochrome mode or outside the picture n_CC is forced to 1111 (chroma
	// 0000), rendered as a gray shade by luma only.
	assign n_CC = (n_BW == 1'b1) ? ~cram[CGA][3:0] : 4'b1111;
	assign n_LL = ~cram[CGA][5:4];

endmodule // CRAM_Block
