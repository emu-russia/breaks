module V_Inversion (
  input n_PCLK,
  input n_OBJ_RD_ATTR,
  input [7:0] OB,
  output VDIR,
  output VINV );
  wire w0;
  wire w1;
  wire w2;
  wire w3;
  wire w4;

  assign w0 = ~(n_PCLK | n_OBJ_RD_ATTR);
  assign w1 = w2 ? OB[7] : 'bz;
  assign VINV = ~w3;
  assign VDIR = ~w4;
  assign w4 = n_PCLK ? VINV : w1;
endmodule

module ParControl (
  input nF_NT,
  input BGSEL,
  input OBSEL,
  input O8_16,
  input OBJ_READ,
  input n_PCLK,
  input H0_DD,
  input [7:0] OB,
  output PAD12,
  output O );
  wire w0;
  wire w1;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = ~H0_DD;
  assign w1 = ~(w0 | nF_NT);
  assign w2 = ~w1;
  assign O = ~(w3 | n_PCLK);
  assign w5 = O8_16 ? w4 : OBSEL;
  assign w6 = OBJ_READ ? w5 : BGSEL;
  dlatch u0 (.en(O), .d(OB[0]), .q(w7), .nq(w4));
  dlatch u1 (.en(n_PCLK), .d(w2), .q(w3), .nq(w8));
  dlatch u2 (.en(n_PCLK), .d(w6), .q(w9), .nq(PAD12));
endmodule

module ParBitInv (
  input INV,
  input val_in,
  input n_PCLK,
  input O,
  output val_out );
  wire w0;
  wire w1;
  wire w2;
  wire w3;
  wire w4;
  wire w5;

  assign w1 = ~w0;
  assign val_out = ~w2;
  assign w2 = INV ? w1 : w0;
  dlatch u0 (.en(n_PCLK), .d(val_in), .q(w3), .nq(w4));
  dlatch u1 (.en(O), .d(w4), .q(w5), .nq(w0));
endmodule

module ParBit4 (
  input O8_16,
  input val_OBPrev,
  input val_OB,
  input val_PD,
  input OBJ_READ,
  input n_PCLK,
  input O,
  output PADx );
  wire w0;
  wire w1;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = ~val_PD;
  assign w2 = O8_16 ? val_OBPrev : w1;
  assign w4 = OBJ_READ ? w2 : w3;
  dlatch u0 (.en(n_PCLK), .d(w0), .q(w5), .nq(w6));
  dlatch u1 (.en(O), .d(val_OB), .q(w7), .nq(w1));
  dlatch u2 (.en(O), .d(w6), .q(w8), .nq(w3));
  dlatch u3 (.en(n_PCLK), .d(w4), .q(w9), .nq(PADx));
endmodule

module ParBit (
  input val_OB,
  input val_PD,
  input OBJ_READ,
  input n_PCLK,
  input O,
  output PADx );
  wire w0;
  wire w1;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;

  assign w0 = ~val_PD;
  assign w3 = OBJ_READ ? w2 : w1;
  dlatch u0 (.en(n_PCLK), .d(w0), .q(w4), .nq(w5));
  dlatch u1 (.en(O), .d(val_OB), .q(w6), .nq(w2));
  dlatch u2 (.en(O), .d(w5), .q(w7), .nq(w1));
  dlatch u3 (.en(n_PCLK), .d(w3), .q(w8), .nq(PADx));
endmodule

module PAR (
  output [13:0] PAddr_out,
  input H0_DD,
  input n_FNT,
  input BGSEL,
  input OBSEL,
  input O8_16,
  input OBJ_READ,
  input n_OBJ_RD_ATTR,
  input n_H1D,
  input n_PCLK,
  input [3:0] OV,
  input [2:0] n_FVO,
  input [7:0] OB,
  input [7:0] PD );
  wire [7:0] bus260_490;
  wire [7:0] bus270_330;
  wire [2:0] bus690_910;
  wire [2:0] bus770_900;
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
  wire w50;
  wire w51;
  wire w52;
  wire w53;
  wire w54;
  wire w55;
  wire w56;
  wire w57;
  wire w58;
  wire w59;
  wire w6;
  wire w60;
  wire w61;
  wire w62;
  wire w63;
  wire w64;
  wire w65;
  wire w66;
  wire w67;
  wire w68;
  wire w69;
  wire w7;
  wire w70;
  wire w8;
  wire w9;

  assign PAddr_out[13] = 1'd0;
  assign PAddr_out[12] = w11;
  assign PAddr_out[3] = ~n_H1D;
  assign bus770_900 = OBJ_READ ? bus690_910 : n_FVO;
  V_Inversion u0 (.n_PCLK(w0), .n_OBJ_RD_ATTR(PD[0]), .OB(bus260_490), .VDIR(w1), .VINV(w2));
  ParControl u1 (.n_PCLK(w3), .H0_DD(w4), .nF_NT(w5), .BGSEL(w6), .OBSEL(w7), .O8_16(w8), .OBJ_READ(w9), .OB(bus270_330), .O(w10), .PAD12(w11));
  ParBitInv u2 (.n_PCLK(w12), .O(w13), .INV(w14), .val_in(w15), .val_out(bus690_910[0]));
  ParBitInv u3 (.n_PCLK(w16), .O(w17), .INV(w18), .val_in(w19), .val_out(w20));
  ParBitInv u4 (.n_PCLK(w21), .O(w22), .INV(w23), .val_in(w24), .val_out(bus690_910[2]));
  ParBitInv u5 (.n_PCLK(w25), .O(w26), .INV(w27), .val_in(w28), .val_out(bus690_910[1]));
  ParBit4 u6 (.n_PCLK(w29), .O(OB[0]), .val_OB(w30), .val_PD(w31), .OBJ_READ(w32), .O8_16(w33), .val_OBPrev(w34), .PADx(PAddr_out[4]));
  dlatch u7 (.en(n_PCLK), .d(bus770_900[2]), .q(w35), .nq(PAddr_out[2]));
  dlatch u8 (.en(n_PCLK), .d(bus770_900[1]), .q(w36), .nq(PAddr_out[1]));
  dlatch u9 (.en(n_PCLK), .d(bus770_900[0]), .q(w37), .nq(PAddr_out[0]));
  ParBit u10 (.n_PCLK(w38), .O(w39), .val_OB(w40), .val_PD(w41), .OBJ_READ(w42), .PADx(PAddr_out[11]));
  ParBit u11 (.n_PCLK(w43), .O(w44), .val_OB(w45), .val_PD(w46), .OBJ_READ(w47), .PADx(PAddr_out[10]));
  ParBit u12 (.n_PCLK(OB[4]), .O(w48), .val_OB(w49), .val_PD(w50), .OBJ_READ(w51), .PADx(PAddr_out[9]));
  ParBit u13 (.n_PCLK(w52), .O(OB[4]), .val_OB(w53), .val_PD(w54), .OBJ_READ(w55), .PADx(PAddr_out[8]));
  ParBit u14 (.n_PCLK(w56), .O(w57), .val_OB(w58), .val_PD(w59), .OBJ_READ(w60), .PADx(PAddr_out[7]));
  ParBit u15 (.n_PCLK(w61), .O(w62), .val_OB(w63), .val_PD(w64), .OBJ_READ(w65), .PADx(PAddr_out[6]));
  ParBit u16 (.n_PCLK(w66), .O(w67), .val_OB(w68), .val_PD(w69), .OBJ_READ(w70), .PADx(PAddr_out[5]));
endmodule
