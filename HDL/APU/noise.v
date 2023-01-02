
module NoiseChan(
	n_ACLK, ACLK, 
	RES, DB, W400A, W400B, W400C, W400E, W400F, nLFO1, RND_LC, NORND, LOCK, 
	RND_out);

	input n_ACLK;
	input ACLK;

	input RES;
	inout [7:0] DB;
	input W400A;
	input W400B;
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

	NOISE_FreqReg freq_reg (.n_ACLK(n_ACLK), .RES(RES), .W400E(W400E), .DB(DB), .NF(NF) );

	NOISE_Decoder dec (.NF(NF), .NNF(NNF) );

	NOISE_FreqLFSR freq_lfsr (.ACLK(ACLK), .n_ACLK(n_ACLK), .RES(RES), .NNF(NNF), .RSTEP(RSTEP) );

	NOISE_RandomLFSR rnd_lfsr (.n_ACLK(n_ACLK), .RSTEP(RSTEP), .NORND(NORND), .LOCK(LOCK), .W400E(W400E), .DB(DB), .RNDOUT(RNDOUT) );

	Envelope_Unit env_unit (.n_ACLK(n_ACLK), .RES(RES), .WR_Reg(W400C), .WR_LC(W400F), .n_LFO1(nLFO1), .DB(DB), .V(Vol), .LC(RND_LC) );

	assign RND_out = ~(~Vol | {4{RNDOUT}});

endmodule // NoiseChan

module NOISE_FreqReg (n_ACLK, RES, W400E, DB, NF);

	input n_ACLK;
	input RES;
	input W400E;
	inout [7:0] DB;
	output [3:0] NF;

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

module NOISE_FreqLFSR (ACLK, n_ACLK, RES, NNF, RSTEP);

	input ACLK;
	input n_ACLK;
	input RES;
	input [10:0] NNF;
	output RSTEP;

endmodule // NOISE_FreqLFSR

module NOISE_FreqLFSRBit (n_ACLK, load, step, val, sin, sout);

	input n_ACLK;
	input load;
	input step;
	input val;
	input sin;
	output sout;

endmodule // NOISE_FreqLFSRBit

module NOISE_RandomLFSR (n_ACLK, RSTEP, NORND, LOCK, W400E, DB, RNDOUT);

	input n_ACLK;
	input RSTEP;
	input NORND;
	input LOCK;
	input W400E;
	inout [7:0] DB;
	output RNDOUT;

endmodule // NOISE_RandomLFSR

module NOISE_RandomLFSRBit (n_ACLK, load, sin, sout);

	input n_ACLK;
	input load;
	input sin;
	output sout;

endmodule // NOISE_RandomLFSRBit
