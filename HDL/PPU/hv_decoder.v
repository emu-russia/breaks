
module HVDecoder (
	H_in, V_in, VB, BLNK,
	HPLA_out, VPLA_out);

	input [8:0] H_in;
	input [8:0] V_in;
	input VB;
	input BLNK;

	output [23:0] HPLA_out;
	output [8:0] VPLA_out;

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

	assign dec_out[0] = ~(nH[0] | nH[1] | nH[2] | H[3] | nH[4] | H[5] | H[6] | H[7] | nH[8]);

	assign dec_out[1] = ~(H[0] | H[1] | H[2] | H[3] | H[4] | H[5] | H[6] | H[7] | nH[8]);
	assign dec_out[2] = ~(nH[0] | H[1] | H[2] | H[3] | H[4] | H[5] | nH[6] | H[7] | H[8] | BLNK);
	assign dec_out[3] = ~(H[3] | H[4] | H[5] | H[6] | H[7]);

	assign dec_out[4] = ~(H[8] | VB);
	assign dec_out[5] = ~(nH[0] | nH[1] | H[2] | H[3] | nH[4] | H[5] | nH[6] | H[7] | nH[8] | BLNK);

	assign dec_out[6] = ~(nH[0] | nH[1] | nH[2] | nH[3] | nH[4] | nH[5] | H[6] | H[7] | H[8] | BLNK);
	assign dec_out[7] = ~(nH[0] | nH[1] | nH[2] | nH[3] | nH[4] | nH[5] | nH[6] | nH[7] | BLNK);
	assign dec_out[8] = ~(H[6] | H[7] | H[8] | BLNK);

	assign dec_out[9] = ~(H[6] | H[7] | nH[8] | BLNK);
	assign dec_out[10] = ~(H[8] | VB | BLNK);
	assign dec_out[11] = ~(H[1] | H[2] | BLNK);
	assign dec_out[12] = ~(nH[1] | nH[2]);
	assign dec_out[13] = ~(H[1] | nH[2]);

	assign dec_out[14] = ~(H[4] | H[5] | nH[6] | nH[8] | BLNK);
	assign dec_out[15] = ~(H[8] | BLNK);
	assign dec_out[16] = ~(nH[1] | H[2]);
	assign dec_out[17] = ~(H[0] | nH[1] | nH[2] | nH[3] | H[4] | H[5] | H[6] | H[7] | nH[8]);
	assign dec_out[18] = ~(H[0] | H[1] | H[2] | nH[3] | H[4] | H[5] | nH[6] | H[7] | nH[8]);

	assign dec_out[19] = ~(nH[0] | nH[1] | nH[2] | H[3] | nH[4] | H[5] | H[6] | H[7] | nH[8]);
	assign dec_out[20] = ~(H[0] | H[1] | H[2] | H[3] | nH[4] | nH[5] | H[6] | H[7] | nH[8]);
	assign dec_out[21] = ~(nH[0] | nH[1] | H[2] | H[3] | H[4] | H[5] | nH[6] | H[7] | nH[8]);
	assign dec_out[22] = ~(H[0] | H[1] | nH[2] | H[3] | nH[4] | nH[5] | H[6] | H[7] | nH[8]);
	assign dec_out[23] = ~(H[0] | H[1] | nH[2] | H[3] | nH[4] | H[5] | nH[6] | H[7] | nH[8]);

endmodule // HDecoder

module VDecoder (V, dec_out);

	input [8:0] V;
	output [8:0] dec_out;

	wire [8:0] nV;
	assign nV = ~V;

	assign dec_out[0] = ~(nV[0] | nV[1] | nV[2] | V[3] | nV[4] | nV[5] | nV[6] | nV[7]);
	assign dec_out[1] = ~(V[0] | V[1] | nV[2] | V[3] | nV[4] | nV[5] | nV[6] | nV[7]);
	assign dec_out[2] = ~(nV[0] | V[1] | nV[2] | V[3] | V[4] | V[5] | V[6] | V[7] | nV[8]);

	assign dec_out[3] = ~(nV[0] | V[1] | V[2] | V[3] | nV[4] | nV[5] | nV[6] | nV[7]);
	assign dec_out[4] = ~(nV[0] | V[1] | V[2] | V[3] | nV[4] | nV[5] | nV[6] | nV[7]);
	assign dec_out[5] = ~(V[0] | V[1] | V[2] | V[3] | V[4] | V[5] | V[6] | V[7] | V[8]);
	assign dec_out[6] = ~(V[0] | V[1] | V[2] | V[3] | nV[4] | nV[5] | nV[6] | nV[7]);
	assign dec_out[7] = ~(nV[0] | V[1] | nV[2] | V[3] | V[4] | V[5] | V[6] | V[7] | nV[8]);

	assign dec_out[8] = ~(nV[0] | V[1] | nV[2] | V[3] | V[4] | V[5] | V[6] | V[7] | nV[8]);

endmodule // VDecoder
