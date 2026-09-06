module PamuxHighBit (
  input PCLK,
  input PARR,
  input PAH,
  input F_AT,
  input AT_ADR,
  input NT_ADR,
  input PAT_ADR,
  output n_PAx );
  wire w0;
  wire w1;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;

  assign w0 = 1'd0;
  assign n_PAx = w1;
  assign w3 = F_AT ? AT_ADR : w2;
  assign w4 = PAH ? NT_ADR : w3;
  assign w5 = PARR ? PAT_ADR : w4;
  dlatch u0 (.en(w0), .d(w5), .q(w6), .nq(w7));
  dlatch u1 (.en(PCLK), .d(w7), .q(w1), .nq(w8));
endmodule

module PamuxLowBit (
  input PARR,
  input DB_PAR,
  input PAL,
  input F_AT,
  input AT_ADR,
  input NT_ADR,
  input PAT_ADR,
  input DBx,
  input PCLK,
  output n_PAx );
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

  assign w0 = 1'd0;
  assign n_PAx = w1;
  assign w3 = F_AT ? AT_ADR : w2;
  assign w4 = PAL ? NT_ADR : w3;
  assign w5 = PARR ? PAT_ADR : w4;
  assign w6 = DB_PAR ? DBx : w5;
  dlatch u0 (.en(w0), .d(w6), .q(w7), .nq(w8));
  dlatch u1 (.en(PCLK), .d(w8), .q(w1), .nq(w9));
endmodule

module PAMUX_bit (
  output [13:0] n_PAx,
  input PARR,
  input DB_PAR,
  input PAH,
  input PAL,
  input F_AT,
  input [13:0] AT_ADR,
  input [13:0] NT_ADR,
  input [13:0] PAT_ADR,
  input [7:0] DB_in,
  input PCLK );
  wire [5:0] bus640_1090;
  wire [5:0] bus980_610;
  wire [5:0] bus970_160;
  wire [5:0] bus970_400;
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
  wire w71;
  wire w72;
  wire w73;
  wire w74;
  wire w75;
  wire w76;
  wire w77;
  wire w78;
  wire w79;
  wire w8;
  wire w80;
  wire w81;
  wire w82;
  wire w83;
  wire w84;
  wire w85;
  wire w86;
  wire w87;
  wire w88;
  wire w89;
  wire w9;
  wire w90;
  wire w91;
  wire w92;
  wire w93;

  PamuxHighBit u0 (.PCLK(w0), .PARR(w1), .PAH(w2), .F_AT(w3), .AT_ADR(w4), .NT_ADR(w5), .PAT_ADR(w6), .n_PAx(n_PAx[13]));
  PamuxHighBit u1 (.PCLK(w7), .PARR(w8), .PAH(w9), .F_AT(w10), .AT_ADR(AT_ADR[10]), .NT_ADR(w11), .PAT_ADR(w12), .n_PAx(n_PAx[8]));
  PamuxHighBit u2 (.PCLK(w12), .PARR(w13), .PAH(w14), .F_AT(w15), .AT_ADR(w16), .NT_ADR(w17), .PAT_ADR(w18), .n_PAx(n_PAx[9]));
  PamuxHighBit u3 (.PCLK(w18), .PARR(w19), .PAH(AT_ADR[10]), .F_AT(w20), .AT_ADR(w21), .NT_ADR(w22), .PAT_ADR(w23), .n_PAx(n_PAx[10]));
  PamuxHighBit u4 (.PCLK(w23), .PARR(w24), .PAH(w25), .F_AT(w26), .AT_ADR(w27), .NT_ADR(w28), .PAT_ADR(w29), .n_PAx(n_PAx[11]));
  PamuxHighBit u5 (.PCLK(w29), .PARR(w30), .PAH(w31), .F_AT(w32), .AT_ADR(w33), .NT_ADR(w34), .PAT_ADR(w35), .n_PAx(n_PAx[12]));
  PamuxLowBit u6 (.PCLK(w36), .PARR(w37), .DB_PAR(w38), .PAL(w39), .F_AT(w40), .AT_ADR(w41), .NT_ADR(w42), .PAT_ADR(w43), .DBx(w44), .n_PAx(n_PAx[7]));
  PamuxLowBit u7 (.PCLK(w45), .PARR(w46), .DB_PAR(w47), .PAL(w48), .F_AT(w49), .AT_ADR(w50), .NT_ADR(w51), .PAT_ADR(w52), .DBx(w53), .n_PAx(n_PAx[0]));
  PamuxLowBit u8 (.PCLK(w52), .PARR(w53), .DB_PAR(w54), .PAL(w55), .F_AT(w56), .AT_ADR(w57), .NT_ADR(w58), .PAT_ADR(w59), .DBx(w60), .n_PAx(n_PAx[1]));
  PamuxLowBit u9 (.PCLK(w59), .PARR(w60), .DB_PAR(w61), .PAL(w62), .F_AT(w63), .AT_ADR(w64), .NT_ADR(w65), .PAT_ADR(w66), .DBx(w67), .n_PAx(n_PAx[2]));
  PamuxLowBit u10 (.PCLK(w66), .PARR(w67), .DB_PAR(w68), .PAL(w69), .F_AT(w70), .AT_ADR(w71), .NT_ADR(w72), .PAT_ADR(w73), .DBx(w74), .n_PAx(n_PAx[3]));
  PamuxLowBit u11 (.PCLK(w73), .PARR(w74), .DB_PAR(w75), .PAL(w76), .F_AT(w77), .AT_ADR(w78), .NT_ADR(w79), .PAT_ADR(w80), .DBx(w81), .n_PAx(n_PAx[4]));
  PamuxLowBit u12 (.PCLK(w80), .PARR(w81), .DB_PAR(w82), .PAL(w83), .F_AT(w84), .AT_ADR(w85), .NT_ADR(w86), .PAT_ADR(w87), .DBx(w88), .n_PAx(n_PAx[5]));
  PamuxLowBit u13 (.PCLK(w87), .PARR(w88), .DB_PAR(w89), .PAL(w90), .F_AT(w91), .AT_ADR(w92), .NT_ADR(w93), .PAT_ADR(w36), .DBx(w37), .n_PAx(n_PAx[6]));
endmodule

module PamuxControl (
  input BLNK,
  input F_AT,
  input DB_PAR,
  input n_H2_D,
  output PAH,
  output PAL,
  output PARR );
  wire w0;

  assign PARR = ~(n_H2_D | BLNK);
  assign PAH = ~(PARR | F_AT);
  assign w0 = ~PAH;
  assign PAL = ~(w0 | DB_PAR);
endmodule

module PAMUX (
  output [13:0] n_PA,
  input PCLK,
  input n_H2_D,
  input BLNK,
  input F_AT,
  input DB_PAR,
  input [13:0] AT_ADR_in,
  input [13:0] NT_ADR_in,
  input [13:0] PAT_ADR_in,
  input [7:0] CPU_DB );
  wire w0;
  wire w1;
  wire w2;

  PAMUX_bit u0 (.PCLK(PCLK), .PARR(w0), .DB_PAR(DB_PAR), .PAH(w1), .PAL(w2), .F_AT(F_AT), .AT_ADR(AT_ADR_in), .NT_ADR(NT_ADR_in), .PAT_ADR(PAT_ADR_in), .DB_in(CPU_DB), .n_PAx(n_PA));
  PamuxControl u1 (.n_H2_D(n_H2_D), .BLNK(BLNK), .F_AT(F_AT), .DB_PAR(DB_PAR), .PARR(w0), .PAH(w1), .PAL(w2));
endmodule
