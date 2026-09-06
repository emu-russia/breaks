module FIFO_LaneControl (
  input n_xEN,
  input HSel,
  input n_RD_ATTR,
  input n_RD_X,
  input n_RD_A,
  input n_RD_B,
  input n_PCLK,
  input [7:0] OB,
  output Z_COL2,
  output Z_COL3,
  output nZ_PRIO,
  output SR_EN,
  output LOAD,
  output T_SR0,
  output T_SR1 );
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

  assign SR_EN = ~(n_PCLK | n_xEN);
  assign w1 = ~(n_PCLK | w0 | n_RD_ATTR);
  assign LOAD = ~(n_PCLK | w0 | n_RD_X);
  assign T_SR0 = ~(n_PCLK | w0 | n_RD_A);
  assign T_SR1 = ~(n_PCLK | w0 | n_RD_B);
  dlatch u0 (.en(w1), .d(OB[0]), .q(w2), .nq(w3));
  dlatch u1 (.en(w1), .d(OB[1]), .q(w4), .nq(w5));
  dlatch u2 (.en(w1), .d(OB[5]), .q(w6), .nq(w7));
  dlatch u3 (.en(n_PCLK), .d(HSel), .q(w8), .nq(w0));
  dlatch u4 (.en(n_PCLK), .d(w3), .q(w9), .nq(Z_COL2));
  dlatch u5 (.en(n_PCLK), .d(w5), .q(w10), .nq(Z_COL3));
  dlatch u6 (.en(n_PCLK), .d(w7), .q(w11), .nq(nZ_PRIO));
endmodule

module FIFO_CounterControl (
  input n_ZH,
  input n_VIS,
  input LOAD,
  input Carry,
  input PCLK,
  input n_PCLK,
  output UPD,
  output STEP,
  output n_xEN );
  wire w0;
  wire w1;
  wire w2;
  wire w3;
  wire w4;
  wire w5;

  assign w0 = ~(n_PCLK | n_ZH | Carry);
  assign w1 = PCLK & Carry;
  assign w3 = ~(w0 | w2);
  assign w2 = ~(w3 | w1);
  assign STEP = ~(PCLK | w3);
  assign w4 = ~(w2 | n_VIS);
  assign UPD = ~(LOAD | STEP);
  dlatch u0 (.en(n_PCLK), .d(w4), .q(w5), .nq(n_xEN));
endmodule

module FIFO_SRBit (
  input T_SR,
  input SR_EN,
  input nTx,
  input shift_in,
  input n_PCLK,
  output shift_out );
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
  assign w2 = T_SR ? nTx : w1;
  assign w3 = SR_EN ? shift_in : w2;
  dlatch u (.d(w3), .en(w0), .q(w4), .nq(w5));
  dlatch u0 (.en(n_PCLK), .d(w5), .q(w8), .nq(shift_out));
endmodule

module FIFO_PairedSR (
  output nZ_COL0,
  output nZ_COL1,
  input T_SR0,
  input T_SR1,
  input SR_EN,
  input n_PCLK,
  input [7:0] n_Tx );
  wire [2:0] bus840_130;
  wire [2:0] bus840_350;
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
  wire w94;
  wire w95;

  assign w0 = 1'd0;
  assign w1 = 1'd0;
  FIFO_SRBit u0 (.n_PCLK(w2), .T_SR(w3), .SR_EN(w4), .nTx(w5), .shift_in(w6), .shift_out(w7));
  FIFO_SRBit u1 (.n_PCLK(w8), .T_SR(w9), .SR_EN(w10), .nTx(w11), .shift_in(w12), .shift_out(w13));
  FIFO_SRBit u2 (.n_PCLK(w14), .T_SR(w15), .SR_EN(w16), .nTx(w17), .shift_in(w18), .shift_out(w19));
  FIFO_SRBit u3 (.n_PCLK(w20), .T_SR(w21), .SR_EN(w22), .nTx(w23), .shift_in(w24), .shift_out(w25));
  FIFO_SRBit u4 (.n_PCLK(w26), .T_SR(w27), .SR_EN(w28), .nTx(w29), .shift_in(w30), .shift_out(w31));
  FIFO_SRBit u5 (.n_PCLK(w32), .T_SR(w33), .SR_EN(w34), .nTx(w35), .shift_in(w36), .shift_out(w37));
  FIFO_SRBit u6 (.n_PCLK(w38), .T_SR(w39), .SR_EN(w40), .nTx(w41), .shift_in(w42), .shift_out(nZ_COL0));
  FIFO_SRBit u7 (.n_PCLK(w43), .T_SR(w44), .SR_EN(w45), .nTx(w46), .shift_in(w47), .shift_out(nZ_COL1));
  FIFO_SRBit u8 (.n_PCLK(w48), .T_SR(w49), .SR_EN(w50), .nTx(w51), .shift_in(w52), .shift_out(w53));
  FIFO_SRBit u9 (.n_PCLK(w54), .T_SR(w55), .SR_EN(w56), .nTx(w57), .shift_in(w58), .shift_out(w59));
  FIFO_SRBit u10 (.n_PCLK(w60), .T_SR(w61), .SR_EN(w62), .nTx(w63), .shift_in(w64), .shift_out(w65));
  FIFO_SRBit u11 (.n_PCLK(w66), .T_SR(w67), .SR_EN(w68), .nTx(w69), .shift_in(w70), .shift_out(w71));
  FIFO_SRBit u12 (.n_PCLK(w72), .T_SR(w73), .SR_EN(w74), .nTx(w75), .shift_in(w76), .shift_out(w77));
  FIFO_SRBit u13 (.n_PCLK(w78), .T_SR(w79), .SR_EN(w80), .nTx(w81), .shift_in(w82), .shift_out(w83));
  FIFO_SRBit u14 (.n_PCLK(w84), .T_SR(w85), .SR_EN(w86), .nTx(w87), .shift_in(w88), .shift_out(w89));
  FIFO_SRBit u15 (.n_PCLK(w90), .T_SR(w91), .SR_EN(w92), .nTx(w93), .shift_in(w94), .shift_out(w95));
endmodule

module FIFO_CounterBit (
  input Step,
  input Clock,
  input Load,
  input val_in,
  input carry_in,
  output n_val_out,
  output carry_out,
  output val_out );
  wire w0;
  wire w1;
  wire w10;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = 1'd0;
  assign w1 = ~carry_in;
  assign carry_out = ~(val_out | w1);
  assign w3 = Load ? val_in : w2;
  assign w5 = Step ? w4 : w3;
  assign w6 = Clock ? val_out : w5;
  assign w7 = carry_in ? val_out : n_val_out;
  dlatch u (.d(w6), .en(w0), .q(val_out), .nq(n_val_out));
  dlatch u0 (.en(Clock), .d(w7), .q(w10), .nq(w4));
endmodule

module FIFO_DownCounter (
  output CarryOut,
  input STEP,
  input UPD,
  input LOAD,
  input [7:0] OB );
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

  assign w0 = 1'd0;
  assign w6 = ~(w1 | w2 | w3 | w4 | w5);
  FIFO_CounterBit u0 (.Clock(UPD), .Load(LOAD), .Step(STEP), .val_in(OB[1]), .carry_in(w7), .val_out(w2), .n_val_out(w8), .carry_out(w9));
  FIFO_CounterBit u1 (.Clock(UPD), .Load(LOAD), .Step(STEP), .val_in(OB[2]), .carry_in(w9), .val_out(w3), .n_val_out(w10), .carry_out(w11));
  FIFO_CounterBit u2 (.Clock(UPD), .Load(LOAD), .Step(STEP), .val_in(OB[3]), .carry_in(w11), .val_out(w4), .n_val_out(w12), .carry_out(w13));
  FIFO_CounterBit u3 (.Clock(UPD), .Load(LOAD), .Step(STEP), .val_in(OB[4]), .carry_in(w13), .val_out(w5), .n_val_out(w14), .carry_out(w15));
  FIFO_CounterBit u4 (.Clock(UPD), .Load(LOAD), .Step(STEP), .val_in(OB[0]), .carry_in(w0), .val_out(w1), .n_val_out(w16), .carry_out(w7));
  FIFO_CounterBit u5 (.Clock(UPD), .Load(LOAD), .Step(STEP), .val_in(OB[6]), .carry_in(w17), .val_out(w18), .n_val_out(w19), .carry_out(w20));
  FIFO_CounterBit u6 (.Clock(UPD), .Load(LOAD), .Step(STEP), .val_in(OB[7]), .carry_in(w20), .val_out(w21), .n_val_out(w22), .carry_out(CarryOut));
  FIFO_CounterBit u7 (.Clock(UPD), .Load(LOAD), .Step(STEP), .val_in(OB[5]), .carry_in(w6), .val_out(w23), .n_val_out(w24), .carry_out(w17));
endmodule

module FIFO_Lane (
  input HSel,
  input n_RD_ATTR,
  input n_RD_X,
  input n_RD_A,
  input n_RD_B,
  input PCLK,
  input n_ZH,
  input n_VIS,
  input n_PCLK,
  input [7:0] n_Tx,
  input [7:0] OB,
  output Z_COL2,
  output Z_COL3,
  output nZ_PRIO,
  output nZ_COL0,
  output n_xEN,
  output nZ_COL1 );
  wire [7:0] bus390_130;
  wire w0;
  wire w1;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;

  FIFO_LaneControl u0 (.n_PCLK(n_PCLK), .OB(OB), .n_xEN(n_xEN), .HSel(HSel), .n_RD_ATTR(n_RD_ATTR), .n_RD_X(n_RD_X), .n_RD_A(n_RD_A), .n_RD_B(n_RD_B), .Z_COL2(Z_COL2), .Z_COL3(Z_COL3), .nZ_PRIO(nZ_PRIO), .SR_EN(w0), .LOAD(w1), .T_SR0(w2), .T_SR1(w3));
  FIFO_CounterControl u1 (.PCLK(PCLK), .n_PCLK(n_PCLK), .n_ZH(n_ZH), .n_VIS(n_VIS), .LOAD(w1), .Carry(w4), .UPD(w5), .STEP(w6), .n_xEN(n_xEN));
  FIFO_PairedSR u2 (.n_PCLK(n_PCLK), .T_SR0(w2), .T_SR1(w3), .SR_EN(w0), .n_Tx({n_Tx[7], n_Tx[6], n_Tx[5], n_Tx[4], n_Tx[3], n_Tx[2], n_Tx[1], n_Tx[0]}), .nZ_COL0(nZ_COL0), .nZ_COL1(nZ_COL1));
  FIFO_DownCounter u3 (.UPD(w5), .LOAD(w1), .STEP(w6), .OB(OB), .CarryOut(w4));
endmodule

module FIFO_Priority (
  input PCLK,
  input CLPO,
  output [4:0] ZOut,
  input [5:0] Lane0,
  input [5:0] Lane1,
  input [5:0] Lane2,
  input [5:0] Lane3,
  input [5:0] Lane4,
  input [5:0] Lane5,
  input [5:0] Lane6,
  input [5:0] Lane7,
  output n_SPR0HIT );
  wire [4:0] bus1030_460;
  wire [4:0] bus1090_500;
  wire [4:0] bus1150_540;
  wire [4:0] bus1210_580;
  wire [4:0] bus1270_620;
  wire [4:0] bus1330_660;
  wire [4:0] bus910_380;
  wire [4:0] bus970_420;
  wire [4:0] bus1030_480;
  wire [4:0] bus1090_520;
  wire [4:0] bus1150_560;
  wire [4:0] bus1210_600;
  wire [4:0] bus1270_640;
  wire [4:0] bus1330_680;
  wire [4:0] bus910_400;
  wire [4:0] bus970_440;
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
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign bus910_380[0] = 1'd0;
  assign bus910_380[1] = 1'd0;
  assign w8 = Lane0[0] & Lane0[1];
  assign w9 = Lane1[0] & Lane1[1];
  assign w10 = Lane2[0] & Lane2[1];
  assign w11 = Lane3[0] & Lane3[1];
  assign w12 = Lane4[0] & Lane4[1];
  assign w13 = Lane5[0] & Lane5[1];
  assign w14 = Lane6[0] & Lane6[1];
  assign w15 = Lane7[0] & Lane7[1];
  assign w5 = ~(w8 | CLPO | Lane0[5]);
  assign w4 = ~(w9 | CLPO | Lane1[5] | w5);
  assign w3 = ~(w10 | CLPO | w5 | w4 | Lane2[5]);
  assign w2 = ~(w11 | CLPO | Lane3[5] | w5 | w4 | w3);
  assign w1 = ~(w12 | CLPO | Lane4[5] | w5 | w4 | w3 | w2);
  assign w0 = ~(w13 | CLPO | Lane5[5] | w5 | w4 | w3 | w2 | w1);
  assign w6 = ~(w14 | CLPO | Lane6[5] | w5 | w4 | w3 | w2 | w1 | w0);
  assign w7 = ~(w15 | CLPO | Lane7[5] | w5 | w4 | w3 | w2 | w1 | w0 | w6);
  assign w16 = ~(w5 | w4 | w3 | w2 | w1 | w0 | w6 | w7);
  assign w17 = ~w16;
  assign bus1030_460 = w6 ? {Lane6[0], Lane6[1], Lane6[2], Lane6[3], Lane6[4]} : bus970_420;
  assign bus1090_500 = w0 ? {Lane5[0], Lane5[1], Lane5[2], Lane5[3], Lane5[4]} : bus1030_460;
  assign bus1150_540 = w1 ? {Lane4[0], Lane4[1], Lane4[2], Lane4[3], Lane4[4]} : bus1090_500;
  assign bus1210_580 = w2 ? {Lane3[0], Lane3[1], Lane3[2], Lane3[3], Lane3[4]} : bus1150_540;
  assign bus1270_620 = w3 ? {Lane2[0], Lane2[1], Lane2[2], Lane2[3], Lane2[4]} : bus1210_580;
  assign bus1330_660 = w4 ? {Lane1[0], Lane1[1], Lane1[2], Lane1[3], Lane1[4]} : bus1270_620;
  assign ZOut = w5 ? {Lane0[0], Lane0[1], Lane0[2], Lane0[3], Lane0[4]} : bus1330_660;
  assign bus970_420 = w7 ? {Lane7[0], Lane7[1], Lane7[2], Lane7[3], Lane7[4]} : bus910_380;
  dlatch u0 (.en(PCLK), .d(w5), .q(w18), .nq(n_SPR0HIT));
  dlatch u1 (.en(w17), .d(ZOut[2]), .q(bus910_380[2]), .nq(w19));
  dlatch u2 (.en(w17), .d(ZOut[3]), .q(bus910_380[3]), .nq(w20));
  dlatch u3 (.en(w17), .d(ZOut[4]), .q(bus910_380[4]), .nq(w21));
endmodule

module SpriteH (
  input H0_DD,
  input H1_DD,
  input H2_DD,
  input n_PCLK,
  input OBJ_READ,
  output n_OBJ_RD_ATTR,
  output n_OBJ_RD_X,
  output n_OBJ_RD_A,
  output n_OBJ_RD_B );
  wire [2:0] bus220_160;
  wire w0;
  wire w1;
  wire w10;
  wire w11;
  wire w12;
  wire w13;
  wire w14;
  wire w15;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign n_OBJ_RD_ATTR = w0;
  assign n_OBJ_RD_X = w1;
  assign n_OBJ_RD_A = w2;
  assign n_OBJ_RD_B = w3;
  // decoder sel=3
  assign w4 = (OBJ_READ) & ({H0_DD, H1_DD, H2_DD} == 3'd0);
  assign w5 = (OBJ_READ) & ({H0_DD, H1_DD, H2_DD} == 3'd1);
  assign w6 = (OBJ_READ) & ({H0_DD, H1_DD, H2_DD} == 3'd2);
  assign w7 = (OBJ_READ) & ({H0_DD, H1_DD, H2_DD} == 3'd3);
  assign w8 = (OBJ_READ) & ({H0_DD, H1_DD, H2_DD} == 3'd4);
  assign w9 = (OBJ_READ) & ({H0_DD, H1_DD, H2_DD} == 3'd5);
  assign w10 = (OBJ_READ) & ({H0_DD, H1_DD, H2_DD} == 3'd6);
  assign w11 = (OBJ_READ) & ({H0_DD, H1_DD, H2_DD} == 3'd7);
  dlatch u0 (.en(n_PCLK), .d(w7), .q(w12), .nq(w1));
  dlatch u1 (.en(n_PCLK), .d(w9), .q(w13), .nq(w2));
  dlatch u2 (.en(n_PCLK), .d(w11), .q(w14), .nq(w3));
  dlatch u3 (.en(n_PCLK), .d(w6), .q(w15), .nq(w0));
endmodule

module H_Inversion (
  input OB6,
  input PD_FIFO,
  input n_PCLK,
  input n_OBJ_RD_ATTR,
  input [7:0] PD,
  output [7:0] n_Tx );
  wire [7:0] bus330_300;
  wire [7:0] bus440_290;
  wire [7:0] bus550_300;
  wire [7:0] bus590_260;
  wire [7:0] bus590_280;
  wire [7:0] bus380_300;
  wire w0;
  wire w1;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;

  assign bus590_260 = {7'b0, w0};
  assign w1 = ~(n_PCLK | n_OBJ_RD_ATTR);
  assign w3 = ~w2;
  assign w5 = ~w4;
  assign n_Tx = ~(bus590_260 & bus590_280);
  assign w4 = w1 ? OB6 : w3;
  assign bus440_290 = w4 ? {PD[7], PD[6], PD[5], PD[4], PD[3], PD[2], PD[1], PD[0]} : PD;
  DLatch_x8 u0 (.enable(w6), .val(bus330_300), .val_out(bus590_280), .n_val_out(bus550_300));
endmodule

module ObjectFIFO (
  output n_SPR0HIT,
  output n_ZCOL0,
  output n_ZCOL1,
  output ZCOL2,
  output ZCOL3,
  output n_ZPRIO,
  output n_OBJ_RD_ATTR,
  input OBJ_READ,
  input H0_DD,
  input H1_DD,
  input H2_DD,
  input H3_DD,
  input H4_DD,
  input H5_DD,
  input n_PCLK,
  input Z_HPOS,
  input n_VIS,
  input PCLK,
  input PD_FIFO,
  input [7:0] PD,
  input CLPO,
  input [7:0] OB );
  wire [7:0] bus1020_160;
  wire [7:0] bus1020_180;
  wire [7:0] bus1020_310;
  wire [7:0] bus1020_330;
  wire [7:0] bus1020_550;
  wire [7:0] bus1020_570;
  wire [7:0] bus1020_700;
  wire [7:0] bus1020_720;
  wire [7:0] bus1110_680;
  wire [5:0] bus1340_360;
  wire [5:0] bus1340_380;
  wire [5:0] bus1340_400;
  wire [5:0] bus1340_420;
  wire [5:0] bus1340_440;
  wire [5:0] bus1340_460;
  wire [5:0] bus1340_480;
  wire [5:0] bus1340_650;
  wire [7:0] bus460_800;
  wire [7:0] bus710_160;
  wire [7:0] bus710_180;
  wire [7:0] bus710_310;
  wire [7:0] bus710_330;
  wire [7:0] bus710_570;
  wire [7:0] bus710_700;
  wire [7:0] bus710_720;
  wire [7:0] bus800_550;
  wire [5:0] bus730_770;
  wire [4:0] bus1580_420;
  wire [2:0] bus610_210;
  wire w0;
  wire w1;
  wire w10;
  wire w100;
  wire w101;
  wire w102;
  wire w103;
  wire w104;
  wire w105;
  wire w106;
  wire w107;
  wire w108;
  wire w109;
  wire w11;
  wire w110;
  wire w111;
  wire w112;
  wire w113;
  wire w114;
  wire w115;
  wire w116;
  wire w117;
  wire w118;
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
  wire w94;
  wire w95;
  wire w96;
  wire w97;
  wire w98;
  wire w99;

  // decoder sel=3
  assign w0 = (1'b1) & ({H3_DD, H4_DD, H5_DD} == 3'd0);
  assign w1 = (1'b1) & ({H3_DD, H4_DD, H5_DD} == 3'd1);
  assign bus800_550[0] = (1'b1) & ({H3_DD, H4_DD, H5_DD} == 3'd2);
  assign w2 = (1'b1) & ({H3_DD, H4_DD, H5_DD} == 3'd3);
  assign w3 = (1'b1) & ({H3_DD, H4_DD, H5_DD} == 3'd4);
  assign w4 = (1'b1) & ({H3_DD, H4_DD, H5_DD} == 3'd5);
  assign w5 = (1'b1) & ({H3_DD, H4_DD, H5_DD} == 3'd6);
  assign w6 = (1'b1) & ({H3_DD, H4_DD, H5_DD} == 3'd7);
  FIFO_Lane u0 (.PCLK(w7), .n_PCLK(w8), .n_Tx(bus1020_160), .OB(bus1020_180), .HSel(w9), .n_RD_ATTR(w10), .n_RD_X(w11), .n_RD_A(w12), .n_RD_B(w13), .n_ZH(w14), .n_VIS(w15), .nZ_COL0(bus1340_440[0]), .nZ_COL1(bus1340_440[2]), .Z_COL2(bus1340_440[4]), .Z_COL3(w16), .nZ_PRIO(w17), .n_xEN(w18));
  FIFO_Lane u1 (.PCLK(w19), .n_PCLK(w20), .n_Tx(bus1020_310), .OB(bus1020_330), .HSel(w21), .n_RD_ATTR(w22), .n_RD_X(w23), .n_RD_A(w24), .n_RD_B(w25), .n_ZH(w26), .n_VIS(w27), .nZ_COL0(bus1340_460[0]), .nZ_COL1(bus1340_460[2]), .Z_COL2(bus1340_460[4]), .Z_COL3(w28), .nZ_PRIO(w29), .n_xEN(w30));
  FIFO_Lane u2 (.PCLK(w31), .n_PCLK(w32), .n_Tx(bus1020_550), .OB(bus1020_570), .HSel(w33), .n_RD_ATTR(w34), .n_RD_X(w35), .n_RD_A(w36), .n_RD_B(w37), .n_ZH(w38), .n_VIS(w39), .nZ_COL0(bus1340_480[0]), .nZ_COL1(bus1340_480[2]), .Z_COL2(bus1340_480[4]), .Z_COL3(w40), .nZ_PRIO(w41), .n_xEN(w42));
  FIFO_Lane u3 (.PCLK(w43), .n_PCLK(w44), .n_Tx(bus1020_700), .OB(bus1020_720), .HSel(w45), .n_RD_ATTR(w46), .n_RD_X(w47), .n_RD_A(w48), .n_RD_B(w49), .n_ZH(w50), .n_VIS(w51), .nZ_COL0(bus1340_650[0]), .nZ_COL1(bus1340_650[2]), .Z_COL2(bus1340_650[4]), .Z_COL3(w52), .nZ_PRIO(w53), .n_xEN(w54));
  FIFO_Priority u4 (.PCLK(PCLK), .CLPO(CLPO), .Lane0(bus1340_360), .Lane1(bus1340_380), .Lane2(bus1340_400), .Lane3(bus1340_420), .Lane4(bus1340_440), .Lane5(bus1340_460), .Lane6(bus1340_480), .Lane7(bus1340_650), .n_SPR0HIT(n_SPR0HIT), .ZOut({n_ZCOL0, n_ZCOL1, ZCOL2, ZCOL3, n_ZPRIO}));
  dlatch u5 (.en(n_PCLK), .d(Z_HPOS), .q(w55), .nq(w56));
  dlatch u6 (.en(PCLK), .d(w56), .q(w57), .nq(w58));
  dlatch u7 (.en(n_PCLK), .d(w58), .q(w59), .nq(bus730_770[4]));
  SpriteH u8 (.n_PCLK(w60), .OBJ_READ(w61), .H0_DD(w62), .H1_DD(w63), .H2_DD(w64), .n_OBJ_RD_ATTR(n_OBJ_RD_ATTR), .n_OBJ_RD_X(bus730_770[2]), .n_OBJ_RD_A(w65), .n_OBJ_RD_B(w66));
  H_Inversion u9 (.n_PCLK(w67), .n_OBJ_RD_ATTR(w68), .OB6(w69), .PD_FIFO(w70), .PD(bus460_800), .n_Tx(bus1110_680));
  FIFO_Lane u10 (.PCLK(w71), .n_PCLK(w72), .n_Tx(bus710_160), .OB(bus710_180), .HSel(w73), .n_RD_ATTR(w74), .n_RD_X(w75), .n_RD_A(w76), .n_RD_B(w77), .n_ZH(w78), .n_VIS(w79), .nZ_COL0(bus1340_360[0]), .nZ_COL1(bus1340_360[2]), .Z_COL2(bus1340_360[4]), .Z_COL3(w80), .nZ_PRIO(w81), .n_xEN(w82));
  FIFO_Lane u11 (.PCLK(w83), .n_PCLK(w84), .n_Tx(bus710_310), .OB(bus710_330), .HSel(w85), .n_RD_ATTR(w86), .n_RD_X(w87), .n_RD_A(w88), .n_RD_B(w89), .n_ZH(w90), .n_VIS(w91), .nZ_COL0(bus1340_380[0]), .nZ_COL1(bus1340_380[2]), .Z_COL2(bus1340_380[4]), .Z_COL3(w92), .nZ_PRIO(w93), .n_xEN(w94));
  FIFO_Lane u12 (.PCLK(w95), .n_PCLK(w96), .n_Tx(bus800_550), .OB(bus710_570), .HSel(w97), .n_RD_ATTR(w98), .n_RD_X(w99), .n_RD_A(w100), .n_RD_B(w101), .n_ZH(w102), .n_VIS(w103), .nZ_COL0(bus1340_400[0]), .nZ_COL1(bus1340_400[2]), .Z_COL2(bus1340_400[4]), .Z_COL3(w104), .nZ_PRIO(w105), .n_xEN(w106));
  FIFO_Lane u13 (.PCLK(w107), .n_PCLK(w108), .n_Tx(bus710_700), .OB(bus710_720), .HSel(w109), .n_RD_ATTR(w110), .n_RD_X(w111), .n_RD_A(w112), .n_RD_B(w113), .n_ZH(w114), .n_VIS(w115), .nZ_COL0(bus1340_420[0]), .nZ_COL1(bus1340_420[2]), .Z_COL2(bus1340_420[4]), .Z_COL3(w116), .nZ_PRIO(w117), .n_xEN(w118));
endmodule
