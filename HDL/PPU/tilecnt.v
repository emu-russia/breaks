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

// Tile counter bit (from the PPU_Evo.circ TileCounterBit page):
//   - master latch ("DFF" with its clock tied high -> transparent dynamic
//     latch) holds val_out; three tri-state drivers on its input select
//     keep/load/step:
//        Clock=1 : val_out stays (dynamic keep through the Clock buffer)
//        Load=1  : val_out = val_in
//        Step=1  : val_out = ~step_latch.q
//   - step_latch (enabled by Clock) captures carry_in ? val_out : n_val_out
//     during the Clock phase, so a step during the following phase toggles
//     the bit only when carry_in is set (ripple carry-in), else holds it.
//   - carry_out = val_out & carry_in.
// The original translation tied the master-latch enable to 1'd0 (frozen) and
// left the three buffer controls undriven; per the schematic the master
// enable is the (default high) constant Vcc and the controls are Clock,
// Load, Step.
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

  assign w0 = 1'd1;
  assign w1 = Clock ? val_out : 'bz;
  assign w1 = Load   ? val_in  : 'bz;
  assign w1 = Step   ? w4      : 'bz;
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

  // bit i: Clock=PCLK, Load=TVLOAD, Step=TVSTEP, val_in=FVx[i]
  // (instance i at (350,90+110*i) in the Tile_FV_Counter page); carry chain
  // from bit 0 up; bit 0 carry_in = FVIN.
  TileCounterBit u0 (.Clock(PCLK), .Load(TVLOAD), .Step(TVSTEP), .val_in(FVx[0]), .carry_in(FVIN), .val_out(FVO[0]), .n_val_out(n_FVO[0]), .carry_out(w0));
  TileCounterBit u1 (.Clock(PCLK), .Load(TVLOAD), .Step(TVSTEP), .val_in(FVx[1]), .carry_in(w0), .val_out(FVO[1]), .n_val_out(n_FVO[1]), .carry_out(w1));
  TileCounterBit u2 (.Clock(PCLK), .Load(TVLOAD), .Step(TVSTEP), .val_in(FVx[2]), .carry_in(w1), .val_out(FVO[2]), .n_val_out(n_FVO[2]), .carry_out(w2));
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

  // Tile_NT_Counters page: nametable-select flip-flops.
  // NTH bit (instance at (320,120)): val_out -> NTHOut, carry_out -> NTHO,
  // val_in = NTH (scroll), carry_in = NTHIN, Load = THLOAD, Step = THSTEP.
  // NTV bit (instance at (320,300)): same with the TVSTEP/TVLOAD group.
  TileCounterBit u0 (.Clock(PCLK), .Load(THLOAD), .Step(THSTEP), .val_in(NTH), .carry_in(NTHIN), .val_out(NTHOut), .n_val_out(w0), .carry_out(NTHO));
  TileCounterBit u1 (.Clock(PCLK), .Load(TVLOAD), .Step(TVSTEP), .val_in(NTV), .carry_in(NTVIN), .val_out(NTVOut), .n_val_out(w1), .carry_out(NTVO));
endmodule

// Tile counter bit with reset (PPU_Evo.circ TileCounterBitReset page):
// same keep/load/step scheme as TileCounterBit plus an AND with negated
// Reset between the master-latch value and the output:
//   val_out = Q & ~Reset
// so Reset=1 clears the output value (and, through the Clock keep-buffer,
// the master on the next keep phase) while the complementary output
// n_val_out is left untouched (wiki note about the 0/TV signal).
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

  assign w0 = 1'd1;
  assign w1 = Clock ? val_out : 'bz;
  assign w1 = Load   ? val_in  : 'bz;
  assign w1 = Step   ? w4      : 'bz;
  assign val_out = w6 & (~Reset);
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

  // 5-bit vertical (coarse-Y) counter, bit i = TileCounterBitReset instance
  // at (350,90+110*i) in the Tile_TV_Counter page:
  // Clock=PCLK, Load=TVLOAD, Step=TVSTEP, val_in=TVx[i], Reset=Z_TV;
  // bit 0 carry_in = TVIN, carry chain from bit 0 up; the top carry is left
  // open in the schematic (NoConnect).
  TileCounterBitReset u0 (.Clock(PCLK), .Load(TVLOAD), .Step(TVSTEP), .val_in(TVx[0]), .carry_in(TVIN), .Reset(Z_TV), .val_out(TVO[0]), .n_val_out(w0), .carry_out(w1));
  TileCounterBitReset u1 (.Clock(PCLK), .Load(TVLOAD), .Step(TVSTEP), .val_in(TVx[1]), .carry_in(w1), .Reset(Z_TV), .val_out(TVO[1]), .n_val_out(w2), .carry_out(w3));
  TileCounterBitReset u2 (.Clock(PCLK), .Load(TVLOAD), .Step(TVSTEP), .val_in(TVx[2]), .carry_in(w3), .Reset(Z_TV), .val_out(TVO[2]), .n_val_out(w4), .carry_out(w5));
  TileCounterBitReset u3 (.Clock(PCLK), .Load(TVLOAD), .Step(TVSTEP), .val_in(TVx[3]), .carry_in(w5), .Reset(Z_TV), .val_out(TVO[3]), .n_val_out(w6), .carry_out(w7));
  TileCounterBitReset u4 (.Clock(PCLK), .Load(TVLOAD), .Step(TVSTEP), .val_in(TVx[4]), .carry_in(w7), .Reset(Z_TV), .val_out(TVO[4]), .n_val_out(w8), .carry_out(w9));
  assign n_TVO = {w8, w6, w4, w2, w0};
endmodule

module Tile_TH_Counter (
  input THSTEP,
  input THIN,
  input [4:0] THx,
  input PCLK,
  input THLOAD,
  output [4:0] n_THO,
  output [4:0] THO );
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

  // 5-bit horizontal (coarse-X) counter, bit i = TileCounterBit instance at
  // (350,90+110*i) in the Tile_TH_Counter page:
  // Clock=PCLK, Load=THLOAD, Step=THSTEP, val_in=THx[i];
  // bit 0 carry_in = THIN, carry chain from bit 0 up; the top carry is left
  // open in the schematic (NoConnect).
  TileCounterBit u0 (.Clock(PCLK), .Load(THLOAD), .Step(THSTEP), .val_in(THx[0]), .carry_in(THIN), .val_out(THO[0]), .n_val_out(w0), .carry_out(w1));
  TileCounterBit u1 (.Clock(PCLK), .Load(THLOAD), .Step(THSTEP), .val_in(THx[1]), .carry_in(w1), .val_out(THO[1]), .n_val_out(w2), .carry_out(w3));
  TileCounterBit u2 (.Clock(PCLK), .Load(THLOAD), .Step(THSTEP), .val_in(THx[2]), .carry_in(w3), .val_out(THO[2]), .n_val_out(w4), .carry_out(w5));
  TileCounterBit u3 (.Clock(PCLK), .Load(THLOAD), .Step(THSTEP), .val_in(THx[3]), .carry_in(w5), .val_out(THO[3]), .n_val_out(w6), .carry_out(w7));
  TileCounterBit u4 (.Clock(PCLK), .Load(THLOAD), .Step(THSTEP), .val_in(THx[4]), .carry_in(w7), .val_out(THO[4]), .n_val_out(w8), .carry_out(w9));
  assign n_THO = {w8, w6, w4, w2, w0};
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
  assign AT_adr[7] = 1'd0;
  assign AT_adr[8] = 1'd0;
  assign AT_adr[9] = 1'd0;
  assign AT_adr[13] = ~w0;
  assign AT_adr[12] = ~(n_FVO[0] | w1);
  assign w1 = ~BLNK;
  assign w0 = ~(bus860_120[1] | w1);
  // NT_adr shares the counter bits with AT_adr (from TileCounters_All wiring)
  assign NT_adr[2]  = AT_adr[0];  // THO[2]
  assign NT_adr[3]  = AT_adr[1];  // THO[3]
  assign NT_adr[4]  = AT_adr[2];  // THO[4]
  assign NT_adr[7]  = AT_adr[3];  // TVO[2]
  assign NT_adr[8]  = AT_adr[4];  // TVO[3]
  assign NT_adr[9]  = AT_adr[5];  // TVO[4]
  assign NT_adr[10] = AT_adr[10]; // NTHOut
  assign NT_adr[11] = AT_adr[11]; // NTVOut
  assign NT_adr[12] = AT_adr[12]; // ~(n_FVO[0]|~BLNK)
  assign NT_adr[13] = AT_adr[13]; // FVO[1]|~BLNK
  assign THO = {AT_adr[2], AT_adr[1], AT_adr[0], NT_adr[1], NT_adr[0]};
  assign TVO = {AT_adr[5], AT_adr[4], AT_adr[3], NT_adr[6], NT_adr[5]};
  TileCountersControl u0 (.n_PCLK(n_PCLK), .PCLK(PCLK), .W6_2_Enable(W6_2_Ena), .SC_CNT(SC_CNT), .RESCL(RESCL), .E_EV(E_EV), .TSTEP(TSTEP), .F_TB(F_TB), .H0_DD(H0_DD), .TVLOAD(w2), .THLOAD(w3), .THSTEP(w4), .TVSTEP(w5));
  TileCountersControl2 u1 (.n_PCLK(n_PCLK), .PCLK(PCLK), .BLNK(BLNK), .n_THO(bus850_670), .n_TVO(bus850_640), .NTHO(w6), .NTVO(w7), .n_FVO(n_FVO), .I1_32(I_1_32), .TVSTEP(w5), .NTHIN(w8), .NTVIN(w9), .FVIN(w10), .TVIN(w11), .THIN(w12), .Z_TV(w13));
  Tile_FV_Counter u2 (.PCLK(PCLK), .TVLOAD(w2), .TVSTEP(w5), .FVIN(w10), .FVx(FV), .n_FVO(n_FVO), .FVO(bus860_120));
  Tile_NT_Counters u3 (.PCLK(PCLK), .THLOAD(w3), .THSTEP(w4), .NTHIN(w8), .NTH(NTH), .TVLOAD(w2), .TVSTEP(w5), .NTVIN(w9), .NTV(NTV), .NTHOut(AT_adr[10]), .NTHO(w6), .NTVOut(AT_adr[11]), .NTVO(w7));
  Tile_TV_Counter u4 (.PCLK(PCLK), .TVLOAD(w2), .TVSTEP(w5), .TVIN(w11), .TVx(TV), .Z_TV(w13), .n_TVO(bus850_640), .TVO({AT_adr[5], AT_adr[4], AT_adr[3], NT_adr[6], NT_adr[5]}));
  Tile_TH_Counter u5 (.PCLK(PCLK), .THLOAD(w3), .THSTEP(w4), .THIN(w12), .THx(TH), .n_THO(bus850_670), .THO({AT_adr[2], AT_adr[1], AT_adr[0], NT_adr[1], NT_adr[0]}));
endmodule
