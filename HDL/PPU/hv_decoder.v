
module HVDecoder (
	H_in, V_in, VB, BLNK,
	HPLA_out, VPLA_out);

	input [8:0] H_in;
	input [8:0] V_in;
	input VB;
	input BLNK;

	output [23:0] HPLA_out;
	output [9:0] VPLA_out;

	HDecoder hpla (.H(H_in), .VB(VB), .BLNK(BLNK), .dec_out(HPLA_out) );
	VDecoder vpla (.V(V_in), .dec_out(VPLA_out) );

endmodule // HVDecoder

module HDecoder (H, VB, BLNK, dec_out);

	input [8:0] H;
	input VB;
	input BLNK;

	output [23:0] dec_out;

	wire [8:0] nH;
	assign nH = ~H;

	wire [19:0] d;
	assign d = {H[8],nH[8],H[7],nH[7],H[6],nH[6],H[5],nH[5],H[4],nH[4],H[3],nH[3],H[2],nH[2],H[1],nH[1],H[0],nH[0],VB,BLNK};

`ifdef RP2C02

	assign dec_out[0] = ~|{d[2],d[4],d[6],d[9],d[10],d[13],d[15],d[17],d[18]};
	assign dec_out[1] = ~|{d[3],d[5],d[7],d[9],d[11],d[13],d[15],d[17],d[18]};
	assign dec_out[2] = ~|{d[0],d[2],d[5],d[7],d[9],d[11],d[13],d[14],d[17],d[19]};
	assign dec_out[3] = ~|{d[9],d[11],d[13],d[15],d[17]};
	assign dec_out[4] = ~|{d[1],d[19]};
	assign dec_out[5] = ~|{d[0],d[2],d[4],d[7],d[9],d[10],d[13],d[14],d[17],d[18]};
	assign dec_out[6] = ~|{d[0],d[2],d[4],d[6],d[8],d[10],d[12],d[15],d[17],d[19]};
	assign dec_out[7] = ~|{d[0],d[2],d[4],d[6],d[8],d[10],d[12],d[14],d[16]};
	assign dec_out[8] = ~|{d[0],d[15],d[17],d[19]};
	assign dec_out[9] = ~|{d[0],d[15],d[17],d[18]};
	assign dec_out[10] = ~|{d[0],d[1],d[19]};
	assign dec_out[11] = ~|{d[0],d[5],d[7]};
	assign dec_out[12] = ~|{d[4],d[6]};
	assign dec_out[13] = ~|{d[5],d[6]};
	assign dec_out[14] = ~|{d[0],d[11],d[13],d[14],d[18]};
	assign dec_out[15] = ~|{d[0],d[19]};
	assign dec_out[16] = ~|{d[4],d[7]};
	assign dec_out[17] = ~|{d[3],d[4],d[6],d[8],d[11],d[13],d[15],d[17],d[18]};
	assign dec_out[18] = ~|{d[3],d[5],d[7],d[8],d[11],d[13],d[14],d[17],d[18]};
	assign dec_out[19] = ~|{d[2],d[4],d[6],d[9],d[10],d[13],d[15],d[17],d[18]};
	assign dec_out[20] = ~|{d[3],d[5],d[7],d[9],d[10],d[12],d[15],d[17],d[18]};
	assign dec_out[21] = ~|{d[2],d[4],d[7],d[9],d[11],d[13],d[14],d[17],d[18]};
	assign dec_out[22] = ~|{d[3],d[5],d[6],d[9],d[10],d[12],d[15],d[17],d[18]};
	assign dec_out[23] = ~|{d[3],d[5],d[6],d[9],d[10],d[13],d[14],d[17],d[18]};

`elsif RP2C07

	assign dec_out[0] = ~|{d[2],d[5],d[6],d[9],d[10],d[13],d[15],d[17],d[18]};
	assign dec_out[1] = ~|{d[3],d[5],d[7],d[9],d[11],d[13],d[15],d[17],d[18]};
	assign dec_out[2] = ~|{d[0],d[2],d[5],d[7],d[9],d[11],d[13],d[14],d[17],d[19]};
	assign dec_out[3] = ~|{d[9],d[11],d[13],d[15],d[17]};
	assign dec_out[4] = ~|{d[1],d[19]};
	assign dec_out[5] = ~|{d[0],d[2],d[4],d[7],d[9],d[10],d[13],d[14],d[17],d[18]};
	assign dec_out[6] = ~|{d[0],d[2],d[4],d[6],d[8],d[10],d[12],d[15],d[17],d[19]};
	assign dec_out[7] = ~|{d[0],d[2],d[4],d[6],d[8],d[10],d[12],d[14],d[16]};
	assign dec_out[8] = ~|{d[0],d[15],d[17],d[19]};
	assign dec_out[9] = ~|{d[0],d[15],d[17],d[18]};
	assign dec_out[10] = ~|{d[0],d[1],d[19]};
	assign dec_out[11] = ~|{d[0],d[5],d[7]};
	assign dec_out[12] = ~|{d[4],d[6]};
	assign dec_out[13] = ~|{d[5],d[6]};
	assign dec_out[14] = ~|{d[0],d[11],d[13],d[14],d[18]};
	assign dec_out[15] = ~|{d[0],d[19]};
	assign dec_out[16] = ~|{d[4],d[7]};
	assign dec_out[17] = ~|{d[3],d[5],d[7],d[9],d[11],d[13],d[15],d[17],d[18]};
	assign dec_out[18] = ~|{d[3],d[5],d[6],d[9],d[11],d[13],d[15],d[17],d[19]};
	assign dec_out[19] = ~|{d[2],d[5],d[6],d[9],d[10],d[13],d[15],d[17],d[18]};
	assign dec_out[20] = ~|{d[3],d[4],d[6],d[8],d[11],d[12],d[15],d[17],d[18]};
	assign dec_out[21] = ~|{d[2],d[5],d[7],d[9],d[11],d[13],d[14],d[17],d[18]};
	assign dec_out[22] = ~|{d[3],d[4],d[7],d[9],d[10],d[12],d[15],d[17],d[18]};
	assign dec_out[23] = ~|{d[3],d[5],d[6],d[9],d[10],d[13],d[14],d[17],d[18]};

`else
`endif

endmodule // HDecoder

module VDecoder (V, dec_out);

	input [8:0] V;
	output [9:0] dec_out;

	wire [8:0] nV;
	assign nV = ~V;

	wire [17:0] d;
	assign d = {V[8],nV[8],V[7],nV[7],V[6],nV[6],V[5],nV[5],V[4],nV[4],V[3],nV[3],V[2],nV[2],V[1],nV[1],V[0],nV[0]};

`ifdef RP2C02

	assign dec_out[0] = ~|{d[0],d[2],d[4],d[7],d[8],d[10],d[12],d[14]};
	assign dec_out[1] = ~|{d[1],d[3],d[4],d[7],d[8],d[10],d[12],d[14]};
	assign dec_out[2] = ~|{d[0],d[3],d[4],d[7],d[9],d[11],d[13],d[15],d[16]};
	assign dec_out[3] = ~|{d[0],d[3],d[5],d[7],d[8],d[10],d[12],d[14]};
	assign dec_out[4] = ~|{d[0],d[3],d[5],d[7],d[8],d[10],d[12],d[14]};
	assign dec_out[5] = ~|{d[1],d[3],d[5],d[7],d[9],d[11],d[13],d[15],d[17]};
	assign dec_out[6] = ~|{d[1],d[3],d[5],d[7],d[8],d[10],d[12],d[14]};
	assign dec_out[7] = ~|{d[0],d[3],d[4],d[7],d[9],d[11],d[13],d[15],d[16]};
	assign dec_out[8] = ~|{d[0],d[3],d[4],d[7],d[9],d[11],d[13],d[15],d[16]};
	assign dec_out[9] = 1'b0; 		// Not present in NTSC PPUs

`elsif RP2C07

	assign dec_out[0] = ~|{d[1],d[3],d[5],d[7],d[8],d[11],d[13],d[15],d[16]};
	assign dec_out[1] = ~|{d[0],d[3],d[4],d[6],d[9],d[11],d[13],d[15],d[16]};
	assign dec_out[2] = ~|{d[0],d[3],d[5],d[7],d[9],d[11],d[13],d[15],d[17]};
	assign dec_out[3] = ~|{d[1],d[3],d[5],d[7],d[8],d[10],d[12],d[14]};
	assign dec_out[4] = ~|{d[0],d[3],d[5],d[7],d[8],d[10],d[12],d[14]};
	assign dec_out[5] = ~|{d[1],d[3],d[5],d[7],d[9],d[11],d[13],d[15],d[17]};
	assign dec_out[6] = ~|{d[1],d[3],d[5],d[7],d[8],d[10],d[12],d[14]};
	assign dec_out[7] = ~|{d[0],d[2],d[4],d[7],d[8],d[10],d[13],d[15],d[16]};
	assign dec_out[8] = ~|{d[0],d[2],d[4],d[7],d[8],d[10],d[13],d[15],d[16]};
	assign dec_out[9] = ~|{d[0],d[3],d[5],d[6],d[9],d[11],d[13],d[15],d[16]};

`else
`endif

endmodule // VDecoder
