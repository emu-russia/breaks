
module NoiseChan(
	ACLK1, nACLK2, 
	RES, DB, W400C, W400E, W400F, nLFO1, RND_LC, NORND, LOCK, 
	RND_out);

	input ACLK1;
	input nACLK2;

	input RES;
	inout [7:0] DB;
	input W400C;
	input W400E;
	input W400F;
	input nLFO1;
	output RND_LC;
	input NORND;
	input LOCK;	

	output [3:0] RND_out;

	// Internal wires

	wire [3:0] NF;
	wire [10:0] NNF;
	wire RSTEP;
	wire RNDOUT;
	wire [3:0] Vol;

	// Instantiate

	NOISE_FreqReg freq_reg (.ACLK1(ACLK1), .RES(RES), .W400E(W400E), .DB(DB), .NF(NF) );

	NOISE_Decoder dec (.NF(NF), .NNF(NNF) );

	NOISE_FreqLFSR freq_lfsr (.nACLK2(nACLK2), .ACLK1(ACLK1), .RES(RES), .NNF(NNF), .RSTEP(RSTEP) );

	NOISE_RandomLFSR rnd_lfsr (.ACLK1(ACLK1), .RSTEP(RSTEP), .NORND(NORND), .LOCK(LOCK), .W400E(W400E), .DB(DB), .RNDOUT(RNDOUT) );

	Envelope_Unit env_unit (.ACLK1(ACLK1), .RES(RES), .WR_Reg(W400C), .WR_LC(W400F), .n_LFO1(nLFO1), .DB(DB), .V(Vol), .LC(RND_LC) );

	assign RND_out = ~(~Vol | {4{RNDOUT}});

endmodule // NoiseChan

module NOISE_FreqReg (ACLK1, RES, W400E, DB, NF);

	input ACLK1;
	input RES;
	input W400E;
	inout [7:0] DB;
	output [3:0] NF;

	RegisterBitRes freq_reg [3:0] (.ACLK1(ACLK1), .ena(W400E), .d(DB[3:0]), .res(RES), .q(NF) );

endmodule // NOISE_FreqReg

module NOISE_Decoder (NF, NNF);

	input [3:0] NF;
	output [10:0] NNF;

	wire [15:0] Dec1_out;

	NOISE_Decoder1 dec1 (.Dec1_in(NF), .Dec1_out(Dec1_out) );
	NOISE_Decoder2 dec2 (.Dec2_in(Dec1_out), .Dec2_out(NNF) );

endmodule // NOISE_Decoder

module NOISE_Decoder1 (Dec1_in, Dec1_out);

	input [3:0] Dec1_in;
	output [15:0] Dec1_out;

	wire [3:0] F;
	wire [3:0] nF;

	assign F = Dec1_in;
	assign nF = ~Dec1_in;

	nor (Dec1_out[0], F[0], F[1], F[2], F[3]);
	nor (Dec1_out[1], nF[0], F[1], F[2], F[3]);
	nor (Dec1_out[2], F[0], nF[1], F[2], F[3]);
	nor (Dec1_out[3], nF[0], nF[1], F[2], F[3]);
	nor (Dec1_out[4], F[0], F[1], nF[2], F[3]);
	nor (Dec1_out[5], nF[0], F[1], nF[2], F[3]);
	nor (Dec1_out[6], F[0], nF[1], nF[2], F[3]);
	nor (Dec1_out[7], nF[0], nF[1], nF[2], F[3]);

	nor (Dec1_out[8], F[0], F[1], F[2], nF[3]);
	nor (Dec1_out[9], nF[0], F[1], F[2], nF[3]);
	nor (Dec1_out[10], F[0], nF[1], F[2], nF[3]);
	nor (Dec1_out[11], nF[0], nF[1], F[2], nF[3]);
	nor (Dec1_out[12], F[0], F[1], nF[2], nF[3]);
	nor (Dec1_out[13], nF[0], F[1], nF[2], nF[3]);
	nor (Dec1_out[14], F[0], nF[1], nF[2], nF[3]);
	nor (Dec1_out[15], nF[0], nF[1], nF[2], nF[3]);

endmodule // NOISE_Decoder1

module NOISE_Decoder2 (Dec2_in, Dec2_out);

	input [15:0] Dec2_in;
	output [10:0] Dec2_out;

	wire [15:0] d;
	assign d = Dec2_in;

	nor (Dec2_out[0], d[0], d[1], d[2], d[9], d[11], d[12], d[14], d[15]); 	// nor-8
	nor (Dec2_out[1], d[4], d[8], d[14], d[15]);  // nor-4
	nor (Dec2_out[2], d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[8], d[11], d[12], d[14], d[15]);  // nor-12
	nor (Dec2_out[3], d[0], d[5], d[6], d[7], d[9], d[10], d[11], d[12], d[14], d[15]);  // nor-10
	nor (Dec2_out[4], d[0], d[1], d[2], d[6], d[7], d[8], d[9], d[10], d[11], d[12], d[13], d[14], d[15]);  // nor-13
	nor (Dec2_out[5], d[0], d[1], d[9], d[12], d[13], d[14], d[15]);  // nor-7
	nor (Dec2_out[6], d[0], d[1], d[2], d[3], d[4], d[8], d[9], d[10], d[13], d[14]);  // nor-10
	nor (Dec2_out[7], d[0], d[1], d[4], d[5], d[6], d[7], d[9], d[10], d[11], d[12], d[13], d[14], d[15]);  // nor-13
	nor (Dec2_out[8], d[0], d[1], d[2], d[3], d[6], d[7], d[10], d[11], d[12], d[13]);  // nor-10
	nor (Dec2_out[9], d[0], d[1], d[2], d[4], d[5], d[6], d[7], d[8], d[9], d[11], d[15]);  // nor-11
	nor (Dec2_out[10], d[0], d[1], d[2], d[3], d[4], d[5], d[6], d[7], d[8], d[9], d[10], d[11], d[13], d[14], d[15]);  // nor-15

endmodule // NOISE_Decoder2

module NOISE_FreqLFSR (nACLK2, ACLK1, RES, NNF, RSTEP);

	input nACLK2;
	input ACLK1;
	input RES;
	input [10:0] NNF;
	output RSTEP;

	wire ACLK4;
	wire [10:0] sout;
	wire step_load;
	wire NFLOAD;
	wire NFSTEP;
	wire NSIN;
	wire NFZ;
	wire NFOUT;

	assign ACLK4 = ~nACLK2;

	NOISE_FreqLFSRBit freq_lfsr [10:0] (.ACLK1(ACLK1), .load(NFLOAD), .step(NFSTEP), .val(NNF), .sin({NSIN,sout[10:1]}), .sout(sout) );

	nor (NFZ, sout[0], sout[1], sout[2], sout[3], sout[4], sout[5], sout[6], sout[7], sout[8], sout[9], sout[10]);
	nor (NFOUT, ~sout[0], sout[1], sout[2], sout[3], sout[4], sout[5], sout[6], sout[7], sout[8], sout[9], sout[10]);
	nor (step_load, ~NFOUT, RES);
	nor (NFLOAD, ~ACLK4, ~step_load);
	nor (NFSTEP, ~ACLK4, step_load);
	nor (NSIN, (sout[0] & sout[2]), ~(sout[0] | sout[2] | NFZ), RES);
	assign RSTEP = NFLOAD;

endmodule // NOISE_FreqLFSR

module NOISE_FreqLFSRBit (ACLK1, load, step, val, sin, sout);

	input ACLK1;
	input load;
	input step;
	input val;
	input sin;
	output sout;

	wire d;
	wire in_latch_nq;

	assign d = load ? val : (step ? sin : 1'bz);

	dlatch in_latch (.d(d), .en(1'b1), .nq(in_latch_nq) );
	dlatch out_latch (.d(in_latch_nq), .en(ACLK1), .nq(sout) );

endmodule // NOISE_FreqLFSRBit

module NOISE_RandomLFSR (ACLK1, RSTEP, NORND, LOCK, W400E, DB, RNDOUT);

	input ACLK1;
	input RSTEP;
	input NORND;
	input LOCK;
	input W400E;
	inout [7:0] DB;
	output RNDOUT;

	wire rmod_q;
	wire [14:0] sout;
	wire RIN;
	wire RSOZ;
	wire mux_out;

	RegisterBit rmod_reg (.ACLK1(ACLK1), .ena(W400E), .d(DB[7]), .q(rmod_q) );

	NOISE_RandomLFSRBit rnd_lfsr [14:0] (.ACLK1(ACLK1), .load(RSTEP), .sin({RIN,sout[14:1]}), .sout(sout) );

	nor (RSOZ, sout[0], sout[1], sout[2], sout[3], sout[4], sout[5], sout[6], sout[7], sout[8], sout[9], sout[10], sout[11], sout[12], sout[13], sout[14]);
	assign mux_out = rmod_q ? sout[6] : sout[1];
	nor (RIN, LOCK, ~(RSOZ | sout[0] | mux_out), (sout[0] & mux_out));
	nor (RNDOUT, ~(sout[0] | NORND), LOCK);

endmodule // NOISE_RandomLFSR

module NOISE_RandomLFSRBit (ACLK1, load, sin, sout);

	input ACLK1;
	input load;
	input sin;
	output sout;

	wire in_reg_nq;

	RegisterBit in_reg (.ACLK1(ACLK1), .ena(load), .d(sin), .nq(in_reg_nq) );
	dlatch out_latch (.d(in_reg_nq), .en(ACLK1), .nq(sout) );

endmodule // NOISE_RandomLFSRBit
