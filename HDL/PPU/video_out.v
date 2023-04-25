
module VideoGen(
	n_CLK, CLK, n_PCLK, PCLK, 
	RES, n_CC, n_LL, BURST, SYNC, n_PICTURE, n_TR, n_TG, n_TB, 
`ifdef RP2C07
	V0,
`endif
	RawVOut);

	input n_CLK;
	input CLK;
	input n_PCLK;
	input PCLK;

	input RES;
	input [3:0] n_CC;
	input [1:0] n_LL;
	input BURST;
	input SYNC;
	input n_PICTURE;
	input n_TR;
	input n_TG;
	input n_TB;

`ifdef RP2C07
	input V0; 				// For phase alteration (V-counter lsb)
`endif

	output [10:0] RawVOut;

	// Wires

	wire PBLACK;
`ifdef RP2C02
	wire [12:0] dec_out;
`elsif RP2C07
	wire [24:0] dec_out;
`endif
	wire n_POUT;
	wire [3:0] n_LU;
	wire n_PR;
	wire n_PG;
	wire n_PB;
	wire n_PZ;

	// Instantiate

	ChromaDecoder chroma (.PCLK(PCLK), .n_PCLK(n_PCLK), .BURST(BURST), .n_CC(n_CC), 
`ifdef RP2C07
		.V0(V0),
`endif
		.PBLACK(PBLACK), .dec_out(dec_out) );

	LumaDecoder luma (.n_LL(n_LL), .n_POUT(n_POUT), .n_LU(n_LU) );

	PhaseShifter phase (.CLK(CLK), .n_CLK(n_CLK), .RES(RES), .dec_out(dec_out), .n_PR(n_PR), .n_PG(n_PG), .n_PB(n_PB), .n_PZ(n_PZ) );

	Emphasis emphasis (.n_POUT(n_POUT), .n_PR(n_PR), .n_PG(n_PG), .n_PB(n_PB), .n_TR(n_TR), .n_TG(n_TG), .n_TB(n_TB), .TINT(TINT) );

	VidOut vout (.n_PCLK(n_PCLK), .SYNC(SYNC), .PBLACK(PBLACK), .n_PICTURE(n_PICTURE), .BURST(BURST), .TINT(TINT), .n_LU(n_LU), .n_PZ(n_PZ), 
		.RawVOut(RawVOut), .n_POUT(n_POUT) );

endmodule // VideoGen

module ChromaDecoder (PCLK, n_PCLK, BURST, n_CC, 
`ifdef RP2C07
	V0,
`endif
	PBLACK, dec_out);

	input PCLK;
	input n_PCLK;
	input BURST;
	input [3:0] n_CC;
`ifdef RP2C07
	input V0;
`endif
	output PBLACK;
`ifdef RP2C02
	output [12:0] dec_out;
`elsif RP2C07
	output [24:0] dec_out;
`endif

	wire [3:0] na;
	wire [3:0] a;

	wire cc0_latch1_nq;
	wire cc1_latch1_nq;
	wire cc2_latch1_nq;
	wire cc3_latch1_nq;
	wire cc3_latch2_q;
	wire burst_latch_q;

	dlatch cc0_latch1 (.d(n_CC[0]), .en(PCLK), .nq(cc0_latch1_nq) );
	dlatch cc1_latch1 (.d(n_CC[1]), .en(PCLK), .nq(cc1_latch1_nq) );
	dlatch cc2_latch1 (.d(n_CC[2]), .en(PCLK), .nq(cc2_latch1_nq) );
	dlatch cc3_latch1 (.d(n_CC[3]), .en(PCLK), .nq(cc3_latch1_nq) );

	dlatch cc0_latch2 (.d(cc0_latch1_nq), .en(n_PCLK), .nq(na[0]) );
	dlatch cc1_latch2 (.d(cc1_latch1_nq), .en(n_PCLK), .nq(na[1]) );
	dlatch cc2_latch2 (.d(cc2_latch1_nq), .en(n_PCLK), .nq(na[2]) );
	dlatch cc3_latch2 (.d(cc3_latch1_nq), .en(n_PCLK), .q(cc3_latch2_q) );

	dlatch burst_latch (.d(BURST), .en(n_PCLK), .q(burst_latch_q) );
	nor (na[3], cc3_latch2_q, burst_latch_q);
	nor (PBLACK, na[1], na[2], na[3]);

	assign a = ~na;

`ifdef RP2C02
	wire [7:0] d;
	assign d = {na[3],a[3],na[2],a[2],na[1],a[1],na[0],a[0]};
`elsif RP2C07
	wire [9:0] d;
	wire nV0d;
	wire V0d;
	dlatch v0_latch (.d(V0), .en(n_PCLK), .nq(nV0d) );
	assign V0d = ~nV0d;
	assign d = {na[3],a[3],na[2],a[2],na[1],a[1],na[0],a[0],V0d,nV0d};
`endif

`ifdef RP2C02
	assign dec_out[0] = ~|{d[0],d[2],d[5],d[7]};
	assign dec_out[1] = ~|{d[1],d[2],d[5],d[6]};
	assign dec_out[2] = ~|{d[0],d[3],d[4],d[7]};
	assign dec_out[3] = ~|{d[1],d[3],d[4],d[6]};
	assign dec_out[4] = ~|{d[0],d[2],d[4],d[6]};
	assign dec_out[5] = ~|{d[0],d[2],d[4],d[7]};
	assign dec_out[6] = ~|{d[1],d[2],d[4],d[6]};
	assign dec_out[7] = ~|{d[0],d[3],d[5],d[6]};
	assign dec_out[8] = ~|{d[1],d[3],d[4],d[7]};
	assign dec_out[9] = ~|{d[0],d[2],d[5],d[6]};
	assign dec_out[10] = ~|{d[1],d[2],d[4],d[7]};
	assign dec_out[11] = ~|{d[0],d[3],d[4],d[6]};
	assign dec_out[12] = ~|{d[1],d[3],d[5],d[6]};
`elsif RP2C07
	assign dec_out[0] = ~|{d[0],d[3],d[4],d[7],d[8]};
	assign dec_out[1] = ~|{d[1],d[2],d[4],d[7],d[9]};
	assign dec_out[2] = ~|{d[0],d[2],d[4],d[7],d[9]};
	assign dec_out[3] = ~|{d[1],d[3],d[4],d[7],d[8]};
	assign dec_out[4] = ~|{d[0],d[3],d[5],d[7],d[8]};
	assign dec_out[5] = ~|{d[1],d[2],d[5],d[6],d[9]};
	assign dec_out[6] = ~|{d[0],d[2],d[5],d[6],d[8]};
	assign dec_out[7] = ~|{d[1],d[3],d[5],d[6],d[8]};
	assign dec_out[8] = ~|{d[0],d[3],d[4],d[6],d[9]};
	assign dec_out[9] = ~|{d[1],d[2],d[4],d[6],d[9]};
	assign dec_out[10] = ~|{d[2],d[4],d[6],d[8]};
	assign dec_out[11] = ~|{d[0],d[2],d[4],d[7],d[8]};
	assign dec_out[12] = ~|{d[1],d[3],d[4],d[6],d[8]};
	assign dec_out[13] = ~|{d[0],d[3],d[5],d[6],d[9]};
	assign dec_out[14] = ~|{d[1],d[2],d[5],d[7],d[8]};
	assign dec_out[15] = ~|{d[0],d[2],d[5],d[7],d[8]};
	assign dec_out[16] = ~|{d[1],d[3],d[5],d[6],d[9]};
	assign dec_out[17] = ~|{d[0],d[3],d[4],d[6],d[8]};
	assign dec_out[18] = ~|{d[1],d[2],d[4],d[7],d[8]};
	assign dec_out[19] = ~|{d[0],d[2],d[4],d[6],d[9]};
	assign dec_out[20] = ~|{d[1],d[3],d[4],d[6],d[9]};
	assign dec_out[21] = ~|{d[0],d[3],d[5],d[6],d[8]};
	assign dec_out[22] = ~|{d[1],d[2],d[5],d[6],d[8]};
	assign dec_out[23] = ~|{d[0],d[2],d[5],d[6],d[9]};
	assign dec_out[24] = ~|{d[1],d[3],d[5],d[7],d[8]};
`endif

endmodule // ChromaDecoder

module LumaDecoder (n_LL, n_POUT, n_LU);

	input [1:0] n_LL;
	input n_POUT;
	output [3:0] n_LU;

	wire [1:0] LL;
	assign LL = ~n_LL;

	or (n_LU[3], n_LL[0], n_LL[1], n_POUT);
	or (n_LU[2], LL[0], n_LL[1], n_POUT);
	or (n_LU[1], n_LL[0], LL[1], n_POUT);
	or (n_LU[0], LL[0], LL[1], n_POUT);

endmodule // LumaDecoder

module PhaseShifter (CLK, n_CLK, RES, dec_out, n_PR, n_PG, n_PB, n_PZ);

	input CLK;
	input n_CLK;
	input RES;
`ifdef RP2C02
	input [12:0] dec_out;
`elsif RP2C07
	input [24:0] dec_out;
`endif
	output n_PR;
	output n_PG;
	output n_PB;
	output n_PZ;

	wire [12:0] PZ;
	wire bit_5_sout;
	wire bit_5_nsin;
	wire tmp;

	nor (tmp, bit_5_nsin, PZ[3]);
	nor (PZ[1], bit_5_sout, tmp);
	assign bit_5_nsin = ~PZ[6];
	assign PZ[4] = 1'b0; 			// ignored

	PhaseShifterSR bit_5 (.CLK(CLK), .n_CLK(n_CLK), .RES(RES), .nsin(bit_5_nsin), .sout(bit_5_sout), .vout(PZ[0]));
	PhaseShifterSR bit_4 (.CLK(CLK), .n_CLK(n_CLK), .RES(RES), .nsin(PZ[1]), .nsout(PZ[3]), .vout(PZ[2]));
	PhaseShifterSR bit_3 (.CLK(CLK), .n_CLK(n_CLK), .RES(RES), .nsin(PZ[3]), .nsout(PZ[6]), .vout(PZ[5]));
	PhaseShifterSR bit_2 (.CLK(CLK), .n_CLK(n_CLK), .RES(RES), .nsin(PZ[6]), .nsout(PZ[8]), .vout(PZ[7]));
	PhaseShifterSR bit_1 (.CLK(CLK), .n_CLK(n_CLK), .RES(RES), .nsin(PZ[8]), .nsout(PZ[10]), .vout(PZ[9]));
	PhaseShifterSR bit_0 (.CLK(CLK), .n_CLK(n_CLK), .RES(RES), .nsin(PZ[10]), .nsout(PZ[12]), .vout(PZ[11]));

	assign n_PR = PZ[0];
	assign n_PG = PZ[9];
	assign n_PB = PZ[5];

	nor (n_PZ, 
		(dec_out[0]&~PZ[0]), 
		(dec_out[1]&~PZ[1]), 
		(dec_out[2]&~PZ[2]), 
		(dec_out[3]&~PZ[3]), 
		dec_out[4],
		(dec_out[5]&~PZ[5]), 
		(dec_out[6]&~PZ[6]), 
		(dec_out[7]&~PZ[7]), 
		(dec_out[8]&~PZ[8]), 
		(dec_out[9]&~PZ[9]), 
		(dec_out[10]&~PZ[10]), 
		(dec_out[11]&~PZ[11]), 
		(dec_out[12]&~PZ[12]) );

endmodule // PhaseShifter

module PhaseShifterSR (CLK, n_CLK, RES, nsin, sout, nsout, vout);

	input CLK;
	input n_CLK;
	input RES;
	input nsin;
	output sout;
	output nsout;
	output vout;

	wire in_latch_q;

	dlatch in_latch (.d(nsin), .en(CLK), .q(in_latch_q) );
	nor (vout, in_latch_q, RES);
	dlatch out_latch (.d(vout), .en(n_CLK), .q(sout), .nq(nsout) );

endmodule // PhaseShifterSR

module Emphasis (n_POUT, n_PR, n_PG, n_PB, n_TR, n_TG, n_TB, TINT);

	input n_POUT;
	input n_PR;
	input n_PG;
	input n_PB;
	input n_TR;
	input n_TG;
	input n_TB;
	output TINT;

	wire r;
	wire g;
	wire b;

	nor (r, n_TR, n_PR, n_POUT);
	nor (g, n_TG, n_PG, n_POUT);
	nor (b, n_TB, n_PB, n_POUT);
	or (TINT, r, g, b);

endmodule // Emphasis

module VidOut (n_PCLK, SYNC, PBLACK, n_PICTURE, BURST, TINT, n_LU, n_PZ, RawVOut, n_POUT);

	input n_PCLK;
	input SYNC;
	input PBLACK;
	input n_PICTURE;
	input BURST;
	input TINT;
	input [3:0] n_LU;
	input n_PZ;
	output [10:0] RawVOut;
	output n_POUT;

	wire pic_out_latch_d;
	wire black_latch_d;
	wire black_latch_nq;
	wire cb_latch_nq;
	wire luma3_h;
	wire luma1_l;
	wire luma2_h;

	nor (pic_out_latch_d, PBLACK, n_PICTURE);
	or (black_latch_d, pic_out_latch_d, SYNC, BURST);

	dlatch sync_latch (.d(~SYNC), .en(n_PCLK), .nq(RawVOut[0]) );
	dlatch pic_out_latch (.d(pic_out_latch_d), .en(n_PCLK), .nq(n_POUT) );
	dlatch black_latch (.d(black_latch_d), .en(n_PCLK), .nq(black_latch_nq) );
	dlatch cb_latch (.d(BURST), .en(n_PCLK), .nq(cb_latch_nq) );

	PhaseSwing burst (.n_PZ(n_PZ), .n_v(cb_latch_nq), .l(RawVOut[1]), .h(RawVOut[4]) );
	PhaseSwing luma0 (.n_PZ(n_PZ), .n_v(n_LU[0]), .l(RawVOut[2]), .h(RawVOut[6]) );
	PhaseSwing luma3 (.n_PZ(n_PZ), .n_v(n_LU[3]), .l(RawVOut[8]), .h(luma3_h) );
	PhaseSwing luma1 (.n_PZ(n_PZ), .n_v(n_LU[1]), .l(luma1_l), .h(RawVOut[7]) );
	PhaseSwing luma2 (.n_PZ(n_PZ), .n_v(n_LU[2]), .l(RawVOut[5]), .h(luma2_h) );

	or (RawVOut[3], black_latch_nq, luma1_l);
	or (RawVOut[9], luma2_h, luma3_h);
	assign RawVOut[10] = TINT;

endmodule // VidOut

module PhaseSwing (n_PZ, n_v, l, h);

	input n_PZ;
	input n_v;
	output l;
	output h;

	nor (h, n_PZ, n_v);
	nor (l, h, n_v);

endmodule // PhaseSwing
