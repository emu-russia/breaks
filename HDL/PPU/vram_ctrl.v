module VRAM_Control (
  input PCLK,
  input n_PCLK,
  input n_R7,
  input n_W7,
  input n_DBE,
  input H0_D,
  input BLNK,
  input [5:0] nPA,
  output n_ALE,
  output TH_MUX,
  output XRB,
  output DB_PAR,
  output TSTEP,
  output WR,
  output PD_RB,
  output RD );
  wire w0;
  wire w1;
  wire w10;
  wire w11;
  wire w12;
  wire w13;
  wire w14;
  wire w15;
  wire w16;
  wire w17;
  wire w18;
  wire w19;
  wire w2;
  wire w20;
  wire w21;
  wire w22;
  wire w23;
  wire w24;
  wire w25;
  wire w26;
  wire w27;
  wire w28;
  wire w29;
  wire w3;
  wire w30;
  wire w31;
  wire w32;
  wire w33;
  wire w34;
  wire w35;
  wire w36;
  wire w37;
  wire w38;
  wire w39;
  wire w4;
  wire w40;
  wire w41;
  wire w42;
  wire w43;
  wire w44;
  wire w45;
  wire w46;
  wire w47;
  wire w48;
  wire w49;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w3 = ~(H0_D | BLNK | n_PCLK);
  assign w2 = ~(n_R7 | n_DBE);
  assign w4 = ~(n_W7 | n_DBE);
  assign w5 = ~(w3 | w0 | w1);
  assign w7 = ~(w4 | w6);
  assign w6 = ~(w7 | w8);
  assign w10 = ~(w2 | w9);
  assign w9 = ~(w10 | w11);
  assign n_ALE = w5;
  assign w13 = ~(w12 | nPA[0] | nPA[1] | nPA[2] | nPA[3] | nPA[4] | nPA[5]);
  assign w14 = ~(w4 | w7);
  assign w15 = ~(w2 | w10);
  assign TH_MUX = w13;
  assign DB_PAR = ~(w16 | w17);
  assign w1 = ~(w18 | w19);
  assign w21 = ~w20;
  assign w23 = ~w22;
  assign w25 = ~w24;
  assign w27 = ~w26;
  assign w28 = ~DB_PAR;
  assign w0 = ~(w29 | w30);
  assign PD_RB = ~(w31 | w32);
  assign w33 = ~w2;
  assign w34 = ~BLNK;
  assign w35 = ~(w33 | TH_MUX);
  assign w37 = ~(w36 | PD_RB);
  assign WR = ~(w28 | TH_MUX);
  assign w39 = w38 & w34;
  assign TSTEP = ~w37;
  assign XRB = ~w35;
  assign w40 = ~(w39 | PD_RB);
  assign RD = ~w40;
  assign w24 = PCLK ? w15 : w23;
  assign w26 = PCLK ? w14 : w21;
  dlatch u0 (.en(PCLK), .d(BLNK), .q(w41), .nq(w12));
  dlatch u1 (.en(PCLK), .d(w17), .q(w42), .nq(w30));
  dlatch u2 (.en(PCLK), .d(w43), .q(w32), .nq(w19));
  dlatch u3 (.en(n_PCLK), .d(w30), .q(w16), .nq(w8));
  dlatch u4 (.en(n_PCLK), .d(w19), .q(w44), .nq(w11));
  dlatch u5 (.en(PCLK), .d(w8), .q(w29), .nq(w45));
  dlatch u6 (.en(PCLK), .d(w11), .q(w18), .nq(w31));
  dlatch u7 (.en(PCLK), .d(DB_PAR), .q(w36), .nq(w46));
  dlatch u8 (.en(n_PCLK), .d(w25), .q(w47), .nq(w43));
  dlatch u9 (.en(n_PCLK), .d(w27), .q(w48), .nq(w17));
  dlatch u10 (.en(PCLK), .d(H0_D), .q(w38), .nq(w49));
endmodule

module ReadBuffer(XRB, RC, PD_RB, PD_in, CPU_DB);

	input XRB;
	input RC;
	input PD_RB;
	input [7:0] PD_in;
	inout [7:0] CPU_DB;

	wire [7:0] rb_q;

	sdffr rb [7:0] (.d(PD_in), .res(RC), .phi_keep(~PD_RB), .q(rb_q), .nq());

	// The read buffer sits on the internal DB bus only while the CPU is
	// actually reading $2007 (VRAM data port). VRAM_Control asserts XRB for
	// every *other* bus state (register writes, idle, fetch cycles), so the
	// buffer must isolate itself (Z) then and open onto DB only when XRB=0.
	// (Previously the polarity was inverted: the buffer fought the CPU write
	// path on DB and corrupted every register/OAM write and $2002 read.)
	assign CPU_DB = XRB ? 8'bz : rb_q;

endmodule // ReadBuffer
