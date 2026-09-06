module TileCountersControl (
  input n_PCLK,
  input PCLK,
  input W6_2_Enable,
  input SC_CNT,
  input RESCL,
  input E_EV,
  input TSTEP,
  input F_TB,
  input H0_DD,
  output TVLOAD,
  output THLOAD,
  output THSTEP,
  output TVSTEP );
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
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = F_TB & H0_DD;
  assign w2 = n_PCLK & w1;
  assign w4 = ~w3;
  assign w5 = ~(TSTEP | w0);
  assign w7 = ~(w6 | W6_2_Enable);
  assign w8 = w4 & RESCL;
  assign w6 = ~(w2 | w7);
  assign THSTEP = ~(w5 | PCLK);
  assign w9 = ~(w8 | w1);
  assign w10 = ~(w7 | W6_2_Enable);
  assign w12 = ~(w1 | w11);
  assign w13 = ~(E_EV | TSTEP);
  assign w14 = ~n_PCLK;
  assign w16 = ~w15;
  assign TVLOAD = ~(w9 | w14);
  assign w18 = ~w17;
  assign THLOAD = ~(w12 | PCLK);
  assign TVSTEP = ~(w13 | PCLK);
  assign w1 = ~w19;
  assign w17 = PCLK ? w16 : w10;
  dlatch u0 (.en(PCLK), .d(SC_CNT), .q(w20), .nq(w3));
  dlatch u1 (.en(n_PCLK), .d(E_EV), .q(w21), .nq(w22));
  dlatch u2 (.en(PCLK), .d(w22), .q(w23), .nq(w11));
  dlatch u3 (.en(PCLK), .d(w16), .q(w24), .nq(w19));
endmodule

module TileCountersControl2 (
  input BLNK,
  input n_PCLK,
  input NTHO,
  input NTVO,
  input PCLK,
  input I1_32,
  input TVSTEP,
  input [2:0] n_FVO,
  input [4:0] n_THO,
  input [4:0] n_TVO,
  output NTHIN,
  output NTVIN,
  output FVIN,
  output TVIN,
  output THIN,
  output Z_TV );
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
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w4 = ~TVSTEP;
  assign w5 = ~BLNK;
  assign w6 = NTHO & (~w5);
  assign w7 = NTVO & (~w5);
  assign w8 = ~BLNK;
  assign w10 = ~(w9 | BLNK | n_FVO[0] | n_FVO[1] | n_FVO[2]);
  assign w11 = BLNK & I1_32;
  assign w3 = ~(w8 | n_THO[0] | n_THO[1] | n_THO[2] | n_THO[3] | n_THO[4]);
  assign w2 = ~(BLNK | n_THO[0] | n_THO[1] | n_THO[2] | n_THO[3] | n_THO[4]);
  assign w12 = ~(w1 | w2);
  assign w13 = ~(w6 | w0);
  assign w9 = ~(w5 | w7);
  assign Z_TV = ~(w14 | w15);
  assign NTHIN = ~w12;
  assign NTVIN = ~w13;
  assign FVIN = ~w9;
  assign w16 = ~(w10 | w3 | w11);
  assign TVIN = ~w16;
  assign w17 = ~TVIN;
  assign w18 = ~BLNK;
  assign THIN = ~(BLNK & I1_32);
  assign w19 = ~TVIN;
  assign w20 = ~n_TVO[1];
  assign w1 = ~(w18 | w19 | n_TVO[0] | n_TVO[1] | n_TVO[2] | n_TVO[3] | n_TVO[4]);
  assign w0 = ~(BLNK | w17 | n_TVO[0] | w20 | n_TVO[2] | n_TVO[3] | n_TVO[4]);
  dlatch u0 (.en(PCLK), .d(w0), .q(w21), .nq(w22));
  dlatch u1 (.en(n_PCLK), .d(w22), .q(w14), .nq(w23));
  dlatch u2 (.en(n_PCLK), .d(w4), .q(w15), .nq(w24));
endmodule

module TileCounterBit (
  input Step,
  input val_in,
  input carry_in,
  input Clock,
  input Load,
  output val_out,
  output n_val_out,
  output carry_out );
  wire w0;
  wire w1;
  wire w10;
  wire w11;
  wire w12;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = 1'd0;
  assign w1 = w2 ? val_out : 'bz;
  assign w1 = w3 ? val_in : 'bz;
  assign w1 = w5 ? w4 : 'bz;
  assign w6 = ~w6;
  assign w7 = ~w6;
  assign w8 = ~carry_in;
  assign carry_out = ~(n_val_out | w8);
  assign w9 = carry_in ? val_out : n_val_out;
  dlatch u (.d(w1), .en(w0), .q(val_out), .nq(n_val_out));
  dlatch u0 (.en(Clock), .d(w9), .q(w12), .nq(w4));
endmodule

module Tile_FV_Counter (
  input TVSTEP,
  input FVIN,
  input [2:0] FVx,
  input PCLK,
  input TVLOAD,
  output [2:0] FVO,
  output [2:0] n_FVO );
  wire [2:0] bus200_340;
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

  TileCounterBit u0 (.Clock(w0), .Load(w1), .Step(w2), .val_in(w3), .carry_in(w4), .val_out(FVO[1]), .n_val_out(w5), .carry_out(w6));
  TileCounterBit u1 (.Clock(w7), .Load(w8), .Step(w9), .val_in(w10), .carry_in(w11), .val_out(FVO[2]), .n_val_out(w12), .carry_out(w13));
  TileCounterBit u2 (.Clock(TVLOAD), .Load(TVSTEP), .Step(w14), .val_in(w15), .carry_in(w16), .val_out(FVO[0]), .n_val_out(w17), .carry_out(w18));
endmodule

module Tile_NT_Counters (
  input THSTEP,
  input NTHIN,
  input NTH,
  input TVLOAD,
  input TVSTEP,
  input NTVIN,
  input NTV,
  input PCLK,
  input THLOAD,
  output NTHOut,
  output NTHO,
  output NTVOut,
  output NTVO );
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

  TileCounterBit u0 (.Clock(w0), .Load(w1), .Step(w2), .val_in(w3), .carry_in(w4), .val_out(NTHOut), .n_val_out(NTHO), .carry_out(w5));
  TileCounterBit u1 (.Clock(w6), .Load(w7), .Step(w8), .val_in(w9), .carry_in(w10), .val_out(NTVOut), .n_val_out(NTVO), .carry_out(w11));
endmodule

module TileCounterBitReset (
  input Step,
  input val_in,
  input carry_in,
  input Reset,
  input Clock,
  input Load,
  output val_out,
  output n_val_out,
  output carry_out );
  wire w0;
  wire w1;
  wire w10;
  wire w11;
  wire w12;
  wire w13;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = 1'd0;
  assign w1 = w2 ? val_out : 'bz;
  assign w1 = w3 ? val_in : 'bz;
  assign w1 = w5 ? w4 : 'bz;
  assign val_out = w6 & (~Reset);
  assign w7 = ~w7;
  assign w8 = ~w7;
  assign w9 = ~carry_in;
  assign carry_out = ~(n_val_out | w9);
  assign w10 = carry_in ? w6 : n_val_out;
  dlatch u (.d(w1), .en(w0), .q(w6), .nq(n_val_out));
  dlatch u0 (.en(Clock), .d(w10), .q(w13), .nq(w4));
endmodule

module Tile_TV_Counter (
  input TVSTEP,
  input TVIN,
  input [4:0] TVx,
  input Z_TV,
  input PCLK,
  input TVLOAD,
  output [4:0] n_TVO,
  output [4:0] TVO );
  wire [2:0] bus200_560;
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
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  TileCounterBitReset u0 (.Clock(w0), .Load(w1), .Step(w2), .val_in(w3), .carry_in(w4), .Reset(w5), .val_out(TVO[1]), .n_val_out(w6), .carry_out(w7));
  TileCounterBitReset u1 (.Clock(w8), .Load(w9), .Step(w10), .val_in(w11), .carry_in(w12), .Reset(w13), .val_out(TVO[2]), .n_val_out(w14), .carry_out(w15));
  TileCounterBitReset u2 (.Clock(w16), .Load(w17), .Step(w18), .val_in(w19), .carry_in(w20), .Reset(w21), .val_out(TVO[3]), .n_val_out(w22), .carry_out(w23));
  TileCounterBitReset u3 (.Clock(w24), .Load(w25), .Step(w26), .val_in(w27), .carry_in(w28), .Reset(w29), .val_out(TVO[4]), .n_val_out(w30), .carry_out(w31));
  TileCounterBitReset u4 (.Clock(TVLOAD), .Load(TVSTEP), .Step(TVIN), .val_in(w32), .carry_in(w33), .Reset(w34), .val_out(TVO[0]), .n_val_out(w35), .carry_out(w36));
endmodule

module Tile_TH_Counter (
  input THSTEP,
  input THIN,
  input [4:0] THx,
  input PCLK,
  input THLOAD,
  output [4:0] n_THO,
  output [4:0] THO );
  wire [2:0] bus200_560;
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
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  TileCounterBit u0 (.Clock(w0), .Load(w1), .Step(w2), .val_in(w3), .carry_in(w4), .val_out(THO[1]), .n_val_out(w5), .carry_out(w6));
  TileCounterBit u1 (.Clock(w7), .Load(w8), .Step(w9), .val_in(w10), .carry_in(w11), .val_out(THO[2]), .n_val_out(w12), .carry_out(w13));
  TileCounterBit u2 (.Clock(w14), .Load(w15), .Step(w16), .val_in(w17), .carry_in(w18), .val_out(THO[3]), .n_val_out(w19), .carry_out(w20));
  TileCounterBit u3 (.Clock(w21), .Load(w22), .Step(w23), .val_in(w24), .carry_in(w25), .val_out(THO[4]), .n_val_out(w26), .carry_out(w27));
  TileCounterBit u4 (.Clock(THLOAD), .Load(THSTEP), .Step(w28), .val_in(w29), .carry_in(w30), .val_out(THO[0]), .n_val_out(w31), .carry_out(w32));
endmodule

module TileCnt (
  input W6_2_Ena,
  input SC_CNT,
  input RESCL,
  input E_EV,
  input TSTEP,
  input F_TB,
  input H0_DD,
  input n_PCLK,
  input BLNK,
  input I_1_32,
  input PCLK,
  input [2:0] FV,
  input NTH,
  input NTV,
  input [4:0] TV,
  input [4:0] TH,
  output [13:0] AT_adr,
  output [13:0] NT_adr,
  output [4:0] THO,
  output [4:0] TVO,
  output [2:0] n_FVO );
  wire [4:0] bus850_640;
  wire [4:0] bus850_670;
  wire [2:0] bus860_120;
  wire w0;
  wire w1;
  wire w10;
  wire w11;
  wire w12;
  wire w13;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign AT_adr[6] = 1'd0;
  assign AT_adr[13] = ~w0;
  assign AT_adr[12] = ~(n_FVO[0] | w1);
  assign w1 = ~BLNK;
  assign w0 = ~(bus860_120[1] | w1);
  TileCountersControl u0 (.n_PCLK(n_PCLK), .PCLK(PCLK), .W6_2_Enable(W6_2_Ena), .SC_CNT(SC_CNT), .RESCL(RESCL), .E_EV(E_EV), .TSTEP(TSTEP), .F_TB(F_TB), .H0_DD(H0_DD), .TVLOAD(w2), .THLOAD(w3), .THSTEP(w4), .TVSTEP(w5));
  TileCountersControl2 u1 (.n_PCLK(n_PCLK), .PCLK(PCLK), .BLNK(BLNK), .n_THO(bus850_670), .n_TVO(bus850_640), .NTHO(w6), .NTVO(w7), .n_FVO(n_FVO), .I1_32(I_1_32), .TVSTEP(w5), .NTHIN(w8), .NTVIN(w9), .FVIN(w10), .TVIN(w11), .THIN(w12), .Z_TV(w13));
  Tile_FV_Counter u2 (.PCLK(PCLK), .TVLOAD(w2), .TVSTEP(w5), .FVIN(w10), .FVx(FV), .n_FVO(n_FVO), .FVO(bus860_120));
  Tile_NT_Counters u3 (.PCLK(PCLK), .THLOAD(w3), .THSTEP(w4), .NTHIN(w8), .NTH(NTH), .TVLOAD(w2), .TVSTEP(w5), .NTVIN(w9), .NTV(NTV), .NTHOut(AT_adr[10]), .NTHO(w6), .NTVOut(AT_adr[11]), .NTVO(w7));
  Tile_TV_Counter u4 (.PCLK(PCLK), .TVLOAD(w2), .TVSTEP(w5), .TVIN(w11), .TVx(TV), .Z_TV(w13), .n_TVO(bus850_640), .TVO({NT_adr[5], NT_adr[6], AT_adr[3], AT_adr[4], AT_adr[5]}));
  Tile_TH_Counter u5 (.PCLK(PCLK), .THLOAD(w3), .THSTEP(w4), .THIN(w12), .THx(TH), .n_THO(bus850_670), .THO({NT_adr[0], NT_adr[1], AT_adr[0], AT_adr[1], AT_adr[2]}));
endmodule
