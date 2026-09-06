module SCC_FF (
  input RC,
  input val_in,
  input n_DBE,
  output val_out );
  wire w0;
  wire w1;

  assign val_out = ~(w0 | RC);
  assign w0 = ~w1;
  assign w1 = n_DBE ? val_out : val_in;
endmodule

module Fine_H (
  input RC,
  input W5_1,
  input n_DBE,
  input [7:0] DB,
  output [2:0] FHx );
  wire w0;
  wire w1;
  wire w10;
  wire w11;
  wire w12;
  wire w13;
  wire w14;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = w1 ? DB[0] : 'bz;
  assign w2 = w3 ? DB[1] : 'bz;
  assign w4 = w5 ? DB[2] : 'bz;
  SCC_FF u0 (.val_in(w6), .n_DBE(w7), .RC(w8), .val_out(FHx[0]));
  SCC_FF u1 (.val_in(w9), .n_DBE(w10), .RC(w11), .val_out(FHx[1]));
  SCC_FF u2 (.val_in(w12), .n_DBE(w13), .RC(w14), .val_out(FHx[2]));
endmodule

module Fine_V (
  input RC,
  input W5_2,
  input W6_1,
  input n_DBE,
  input [7:0] DB,
  output [2:0] FVx );
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
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = 1'd0;
  assign w1 = w2 ? DB[1] : 'bz;
  assign w3 = w4 ? DB[2] : 'bz;
  assign w5 = w6 ? DB[0] : 'bz;
  assign w5 = w7 ? DB[4] : 'bz;
  assign w1 = w8 ? DB[5] : 'bz;
  assign w3 = w9 ? w0 : 'bz;
  SCC_FF u0 (.val_in(w10), .n_DBE(w11), .RC(w12), .val_out(FVx[0]));
  SCC_FF u1 (.val_in(w13), .n_DBE(w14), .RC(w15), .val_out(FVx[1]));
  SCC_FF u2 (.val_in(w16), .n_DBE(w17), .RC(w18), .val_out(FVx[2]));
endmodule

module NT_Select (
  input RC,
  input W0,
  input W6_1,
  input n_DBE,
  input [7:0] DB,
  output NTH,
  output NTV );
  wire w0;
  wire w1;
  wire w10;
  wire w11;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = w1 ? DB[1] : 'bz;
  assign w2 = w3 ? DB[0] : 'bz;
  assign w2 = w4 ? DB[2] : 'bz;
  assign w0 = w5 ? DB[3] : 'bz;
  SCC_FF u0 (.val_in(w6), .n_DBE(w7), .RC(w8), .val_out(NTH));
  SCC_FF u1 (.val_in(w9), .n_DBE(w10), .RC(w11), .val_out(NTV));
endmodule

module Tile_V (
  input n_DBE,
  input RC,
  input W5_2,
  input W6_1,
  input W6_2,
  input [7:0] DB,
  output [4:0] TVx );
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
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = w1 ? DB[3] : 'bz;
  assign w2 = w3 ? DB[4] : 'bz;
  assign w4 = w5 ? DB[5] : 'bz;
  assign w6 = w7 ? DB[6] : 'bz;
  assign w8 = w9 ? DB[7] : 'bz;
  assign w6 = w10 ? DB[0] : 'bz;
  assign w8 = w11 ? DB[1] : 'bz;
  assign w0 = w12 ? DB[5] : 'bz;
  assign w2 = w13 ? DB[6] : 'bz;
  assign w4 = w14 ? DB[7] : 'bz;
  SCC_FF u0 (.val_in(w15), .n_DBE(w16), .RC(w2), .val_out(TVx[0]));
  SCC_FF u1 (.val_in(w17), .n_DBE(w18), .RC(w4), .val_out(TVx[1]));
  SCC_FF u2 (.val_in(w19), .n_DBE(w20), .RC(w21), .val_out(TVx[2]));
  SCC_FF u3 (.val_in(w22), .n_DBE(w23), .RC(w24), .val_out(TVx[3]));
  SCC_FF u4 (.val_in(w25), .n_DBE(w26), .RC(w27), .val_out(TVx[4]));
endmodule

module Tile_H (
  input RC,
  input W5_1,
  input W6_2,
  input n_DBE,
  input [7:0] DB,
  output [4:0] THx );
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
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = w1 ? DB[4] : 'bz;
  assign w2 = w3 ? DB[5] : 'bz;
  assign w4 = w5 ? DB[6] : 'bz;
  assign w6 = w7 ? DB[7] : 'bz;
  assign w8 = w9 ? DB[3] : 'bz;
  assign w8 = w10 ? DB[0] : 'bz;
  assign w0 = w11 ? DB[1] : 'bz;
  assign w2 = w12 ? DB[2] : 'bz;
  assign w4 = w13 ? DB[3] : 'bz;
  assign w6 = w14 ? DB[4] : 'bz;
  SCC_FF u0 (.val_in(w15), .n_DBE(w16), .RC(w17), .val_out(THx[0]));
  SCC_FF u1 (.val_in(w18), .n_DBE(w19), .RC(w20), .val_out(THx[1]));
  SCC_FF u2 (.val_in(w21), .n_DBE(w22), .RC(w23), .val_out(THx[2]));
  SCC_FF u3 (.val_in(w24), .n_DBE(w25), .RC(w26), .val_out(THx[3]));
  SCC_FF u4 (.val_in(w27), .n_DBE(w28), .RC(w29), .val_out(THx[4]));
endmodule

module ScrollRegs (
  output [4:0] TV,
  output [4:0] TH,
  output W6_2_Ena,
  input n_W6_1,
  input n_W6_2,
  input n_DBE,
  input RC,
  input n_W0,
  input n_W5_1,
  input n_W5_2,
  input [7:0] CPU_DB,
  output [2:0] FH,
  output [2:0] FV,
  output NTH,
  output NTV );
  wire w0;
  wire w1;
  wire w2;
  wire w3;

  assign w3 = ~(n_W0 | n_DBE);
  assign w0 = ~(n_W5_1 | n_DBE);
  assign w1 = ~(n_W5_2 | n_DBE);
  assign w2 = ~(n_W6_1 | n_DBE);
  assign W6_2_Ena = ~(n_W6_2 | n_DBE);
  Fine_H u0 (.W5_1(w0), .n_DBE(n_DBE), .RC(RC), .DB(CPU_DB), .FHx(FH));
  Fine_V u1 (.W5_2(w1), .W6_1(w2), .n_DBE(n_DBE), .RC(RC), .DB(CPU_DB), .FVx(FV));
  NT_Select u2 (.W0(w3), .W6_1(w2), .n_DBE(n_DBE), .RC(RC), .DB(CPU_DB), .NTH(NTH), .NTV(NTV));
  Tile_V u3 (.W5_2(w1), .W6_1(w2), .W6_2(W6_2_Ena), .n_DBE(n_DBE), .RC(RC), .DB(CPU_DB), .TVx(TV));
  Tile_H u4 (.W5_1(w0), .W6_2(W6_2_Ena), .n_DBE(n_DBE), .RC(RC), .DB(CPU_DB), .THx(TH));
endmodule
