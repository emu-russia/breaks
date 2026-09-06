// OAM (sprite RAM): 256 bytes organized as 64 sprites x 4 bytes.
//
// The transistor schematic models this as 8 bit-line lanes of a 4T-SRAM-like
// array plus a write/read buffer (OAM_Buffer). Here the storage is modelled as
// a behavioural 256x8 RAM; the sprite-fetch strobe logic is kept structural.

module OAMBlock(
	n_PCLK, PCLK,
	n_OAM, OAM8, BLNK, SPR_OV, OAMCTR2, H0_DD, n_VIS, I_OAM2, n_W4, n_R4, n_DBE, 
	CPU_DB,
	OB_Out, OFETCH);

	input n_PCLK;
	input PCLK;
	input [7:0] n_OAM;
	input OAM8;
	input BLNK;
	input SPR_OV;
	input OAMCTR2;
	input H0_DD;
	input n_VIS;
	input I_OAM2;
	input n_W4;
	input n_R4;
	input n_DBE;
	inout [7:0] CPU_DB;
	output [7:0] OB_Out;
	output OFETCH;

	reg [7:0] oam_ram [0:255];
	integer i;
	initial begin
		for (i = 0; i < 256; i = i + 1) oam_ram[i] = 8'h00;
	end

	wire [7:0] oam_addr = ~n_OAM;

	always @(posedge PCLK) begin
		if (n_W4 == 1'b0 && n_DBE == 1'b0)
			oam_ram[oam_addr] <= CPU_DB;
	end

	assign CPU_DB = (n_R4 == 1'b0 && n_DBE == 1'b0) ? oam_ram[oam_addr] : 8'bz;
	assign OB_Out = oam_ram[oam_addr];

	wire OB_OAM;
	wire n_WE;
	wire w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16,w17;

	assign w0 = ~(n_W4 | n_DBE);
	assign OB_OAM = ~(n_PCLK | BLNK);
	assign w2 = ~(w0 | w1);
	assign w1 = ~(w2 | w3);
	assign w5 = ~w4;
	assign w7 = ~w6;
	assign w8 = ~(w0 | w2);
	assign w9 = ~H0_DD;
	assign w10 = ~(BLNK | SPR_OV | PCLK | w9 | OAMCTR2 | n_VIS);
	assign OFETCH = ~(w11 | w12);
	assign n_WE = ~(OFETCH | w10);
	assign w6 = PCLK ? w8 : w5;
	dlatch u0 (.en(n_PCLK), .d(w7), .q(w13), .nq(w14));
	dlatch u1 (.en(PCLK), .d(w14), .q(w15), .nq(w12));
	dlatch u2 (.en(n_PCLK), .d(w12), .q(w16), .nq(w3));
	dlatch u3 (.en(PCLK), .d(w3), .q(w11), .nq(w17));

endmodule // OAMBlock
