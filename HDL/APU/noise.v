
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

endmodule // NOISE_Decoder

module NOISE_Decoder1 ();
endmodule // NOISE_Decoder1

module NOISE_Decoder2 ();
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
