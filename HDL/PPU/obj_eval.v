module Eval_OAM_Address (
  input BLNK,
  input n_VIS,
  input H0_DD,
  input [7:0] OAM_x,
  input [4:0] OAMTemp,
  output OAM8,
  output [7:0] n_OAM_x );
  wire [4:0] bus380_270;
  wire [2:0] bus380_220;
  wire [4:0] bus330_260;
  wire [7:0] bus450_180;
  wire w0;
  wire w1;
  wire w2;

  assign w0 = ~BLNK;
  assign w1 = n_VIS | H0_DD;
  assign w2 = ~(w1 & w0);
  assign OAM8 = ~w2;
  assign n_OAM_x = ~{OAM_x[0], OAM_x[1], OAM_x[2], bus380_270[0], bus380_270[1], bus380_270[2], bus380_270[3], bus380_270[4]};
  assign bus380_270 = OAM8 ? OAMTemp : {OAM_x[3], OAM_x[4], OAM_x[5], OAM_x[6], OAM_x[7]};
endmodule

module PosedgeDFFE (
  input val_in,
  input CLK,
  input n_EN,
  output n_Q,
  output Q );
  wire w0;
  wire w1;
  wire w2;

  assign w0 = ~(CLK | n_EN);
  reg qff_260_50 = 1'b0;
  always @(posedge w0) qff_260_50 <= val_in;
  assign Q = qff_260_50;
  assign n_Q = ~qff_260_50;
endmodule

module Eval_FSM (
  input n_F_NT,
  input H0_DD,
  input I_OAM2,
  input n_VIS,
  input SPR_OV,
  input S_EV,
  input OBJ_READ,
  input OVZ,
  input PCLK,
  output COPY_OVF,
  output OMFG,
  output PD_FIFO,
  output n_SPR0_EV );
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
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w1 = ~S_EV;
  assign w2 = ~OBJ_READ;
  assign w3 = ~OVZ;
  assign w4 = ~H0_DD;
  assign w0 = ~PCLK;
  assign w5 = ~(I_OAM2 | n_VIS | SPR_OV | w3);
  assign w6 = ~(n_F_NT | w4);
  assign w7 = ~(PCLK | w4);
  assign w8 = ~w6;
  assign w12 = ~(w9 | w10 | w11);
  assign COPY_OVF = ~w12;
  assign OMFG = ~(COPY_OVF | w5);
  dlatch u0 (.en(w7), .d(w5), .q(w13), .nq(w14));
  PosedgeDFFE u1 (.CLK(w15), .n_EN(w16), .val_in(w17), .Q(w18), .n_Q(w19));
  dlatch u2 (.en(w0), .d(w3), .q(w20), .nq(w21));
  dlatch u3 (.en(PCLK), .d(w14), .q(w22), .nq(w11));
  dlatch u4 (.en(w0), .d(w8), .q(w23), .nq(w24));
  dlatch u5 (.en(w7), .d(w11), .q(w25), .nq(w26));
  dlatch u6 (.en(PCLK), .d(w26), .q(w27), .nq(w10));
  PosedgeDFFE u7 (.CLK(w28), .n_EN(w29), .val_in(w30), .Q(n_SPR0_EV), .n_Q(w31));
  dlatch u8 (.en(w7), .d(w10), .q(w32), .nq(w33));
  dlatch u9 (.en(PCLK), .d(w33), .q(w34), .nq(w9));
  PosedgeDFFE u10 (.CLK(w35), .n_EN(w36), .val_in(w37), .Q(PD_FIFO), .n_Q(w38));
endmodule

module Eval_CountersControl (
  input n_W3,
  input n_DBE,
  input OMFG,
  input I_OAM2,
  input n_VIS,
  input OBJ_READ,
  input n_EVAL,
  input RESCL,
  input H0_DD,
  input H0_D,
  input n_H2_D,
  input OFETCH,
  input OMV,
  input TMV,
  input n_PCLK,
  output OMOUT,
  output OSTEP,
  output ORES,
  output OAMCTR2,
  output SPR_OV,
  output SPR_OV_Reg,
  output W3_Enable,
  output OMSTEP );
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

  assign W3_Enable = ~(n_W3 | n_DBE);
  assign w0 = ~(I_OAM2 | n_VIS);
  assign w1 = ~OMFG;
  assign w2 = ~(w0 & H0_DD);
  assign w4 = ~(w3 | n_PCLK);
  assign w6 = w5 & OSTEP;
  assign w7 = ~w4;
  assign w10 = ~(w8 | w9);
  assign ORES = ~(n_PCLK | w11);
  assign OAMCTR2 = ~(ORES | w12);
  assign w12 = ~(OAMCTR2 | w6);
  assign w14 = w13 | n_PCLK;
  assign w17 = ~(w15 | w16 | H0_D | n_PCLK);
  assign w18 = n_H2_D & OBJ_READ;
  assign OMSTEP = ~(w14 & w7);
  assign w20 = OMSTEP & w19;
  assign w21 = ~(w10 | H0_D);
  assign w22 = ~(w12 & n_EVAL);
  assign w23 = ~(w17 | SPR_OV_Reg);
  assign SPR_OV_Reg = ~(w23 | RESCL);
  assign w24 = ~(w21 | w18);
  assign OMOUT = ~(OMSTEP | W3_Enable);
  assign OSTEP = ~(w25 | n_PCLK | w24);
  assign w26 = ~(w20 | w17 | SPR_OV);
  assign SPR_OV = ~(w26 | I_OAM2);
  dlatch u0 (.en(n_PCLK), .d(OFETCH), .q(w27), .nq(w3));
  dlatch u1 (.en(n_PCLK), .d(n_EVAL), .q(w11), .nq(w28));
  dlatch u2 (.en(n_PCLK), .d(TMV), .q(w5), .nq(w29));
  dlatch u3 (.en(n_PCLK), .d(w1), .q(w8), .nq(w30));
  dlatch u4 (.en(n_PCLK), .d(I_OAM2), .q(w9), .nq(w31));
  dlatch u5 (.en(n_PCLK), .d(OMFG), .q(w15), .nq(w32));
  dlatch u6 (.en(n_PCLK), .d(w12), .q(w16), .nq(w33));
  dlatch u7 (.en(n_PCLK), .d(w2), .q(w13), .nq(w34));
  dlatch u8 (.en(n_PCLK), .d(OMV), .q(w19), .nq(w35));
  dlatch u9 (.en(n_PCLK), .d(w22), .q(w25), .nq(w36));
endmodule

module Eval_SprOV_Flag (
  input n_DBE,
  input SPR_OV_Reg,
  input n_R2,
  output DB5 );
  wire w0;
  wire w1;
  wire w2;
  wire w3;

  assign w0 = ~(n_R2 | n_DBE);
  assign w1 = ~w0;
  assign w2 = ~w1;
  assign DB5 = w3 ? SPR_OV_Reg : 'bz;
endmodule

module Eval_CounterBit (
  input Step,
  input BlockCount,
  input Reset,
  input val_in,
  input carry_in,
  input Clock,
  input Load,
  output carry_out,
  output n_val_out,
  output val_out );
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
  assign w1 = ~carry_in;
  assign w2 = ~(Reset | n_val_out);
  assign carry_out = ~(n_val_out | w1);
  assign w4 = ~(w3 | BlockCount);
  assign w5 = w6 ? w4 : 'bz;
  assign w5 = w7 ? val_in : 'bz;
  assign w5 = w8 ? w2 : 'bz;
  assign val_out = ~n_val_out;
  assign w9 = carry_in ? w2 : n_val_out;
  dlatch u (.d(w5), .en(w0), .q(w10), .nq(n_val_out));
  dlatch u0 (.en(Clock), .d(w9), .q(w3), .nq(w13));
endmodule

module Eval_MainCounter (
  output OMV,
  output [7:0] OAM_x,
  input OMFG,
  input OMOUT,
  input OMSTEP,
  input OBJ_READ,
  input W3_Enable,
  input BLNK,
  input [7:0] DB_In );
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

  assign w4 = 1'd0;
  assign w5 = 1'd0;
  assign w6 = 1'd0;
  assign w11 = 1'd0;
  assign w12 = 1'd0;
  assign w13 = 1'd0;
  assign w14 = 1'd0;
  assign w16 = ~(w0 | w1);
  assign w17 = ~w2;
  assign w18 = ~w16;
  assign w19 = ~OMFG;
  assign w20 = w18 & w17;
  assign w21 = ~(w17 & w18);
  assign w2 = ~(BLNK | w19);
  assign w22 = ~(w20 | w3);
  assign w23 = ~(w20 | w3 | w7);
  assign w24 = ~(w20 | w3 | w7 | w8);
  assign w25 = ~(w20 | w3 | w7 | w8 | w9);
  assign w26 = ~(w20 | w3 | w7 | w8 | w9 | w10);
  Eval_CounterBit u0 (.Clock(w27), .Load(w28), .Step(w29), .BlockCount(w30), .Reset(w31), .val_in(w32), .carry_in(w33), .val_out(OAM_x[0]), .n_val_out(w34), .carry_out(w35));
  Eval_CounterBit u1 (.Clock(w36), .Load(w37), .Step(w38), .BlockCount(w39), .Reset(w40), .val_in(w41), .carry_in(w42), .val_out(OAM_x[1]), .n_val_out(w43), .carry_out(w44));
  Eval_CounterBit u2 (.Clock(w45), .Load(w46), .Step(w47), .BlockCount(w48), .Reset(w49), .val_in(w50), .carry_in(w51), .val_out(OAM_x[2]), .n_val_out(w52), .carry_out(w53));
  Eval_CounterBit u3 (.Clock(w54), .Load(w55), .Step(w56), .BlockCount(w57), .Reset(w58), .val_in(w59), .carry_in(w60), .val_out(OAM_x[3]), .n_val_out(w61), .carry_out(w62));
  Eval_CounterBit u4 (.Clock(w63), .Load(w64), .Step(w65), .BlockCount(w66), .Reset(w67), .val_in(w68), .carry_in(w69), .val_out(OAM_x[4]), .n_val_out(w70), .carry_out(w71));
  Eval_CounterBit u5 (.Clock(w72), .Load(w73), .Step(w74), .BlockCount(w75), .Reset(w24), .val_in(w76), .carry_in(w77), .val_out(OAM_x[5]), .n_val_out(w78), .carry_out(w79));
  Eval_CounterBit u6 (.Clock(w80), .Load(w81), .Step(w82), .BlockCount(w83), .Reset(w25), .val_in(w84), .carry_in(w85), .val_out(OAM_x[6]), .n_val_out(w86), .carry_out(w87));
  Eval_CounterBit u7 (.Clock(w88), .Load(w89), .Step(w90), .BlockCount(w91), .Reset(w92), .val_in(w93), .carry_in(w94), .val_out(OAM_x[7]), .n_val_out(OMV), .carry_out(w95));
endmodule

module Eval_TempCounter (
  input ORES,
  input n_PCLK,
  input OSTEP,
  output TMV,
  output [4:0] OAMTemp );
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

  assign w0 = 1'd0;
  assign w1 = 1'd0;
  assign w2 = 1'd0;
  assign w3 = 1'd0;
  assign w4 = 1'd0;
  assign w5 = 1'd0;
  Eval_CounterBit u0 (.Clock(w6), .Load(w7), .Step(w8), .BlockCount(w9), .Reset(w10), .val_in(w11), .carry_in(w12), .val_out(OAMTemp[1]), .n_val_out(w13), .carry_out(w14));
  Eval_CounterBit u1 (.Clock(w15), .Load(w16), .Step(w17), .BlockCount(w18), .Reset(w19), .val_in(w20), .carry_in(w21), .val_out(OAMTemp[2]), .n_val_out(w22), .carry_out(w23));
  Eval_CounterBit u2 (.Clock(w24), .Load(w25), .Step(w26), .BlockCount(w27), .Reset(w28), .val_in(w29), .carry_in(w30), .val_out(OAMTemp[3]), .n_val_out(w31), .carry_out(w32));
  Eval_CounterBit u3 (.Clock(w33), .Load(w34), .Step(w35), .BlockCount(w36), .Reset(w37), .val_in(w38), .carry_in(w39), .val_out(OAMTemp[4]), .n_val_out(TMV), .carry_out(w40));
  Eval_CounterBit u4 (.Clock(w41), .Load(w42), .Step(w43), .BlockCount(w44), .Reset(w45), .val_in(w46), .carry_in(w47), .val_out(OAMTemp[0]), .n_val_out(w48), .carry_out(w49));
endmodule

module Eval_CmpBitPair (
  input OB_Even,
  input V_Even,
  input OB_Odd,
  input V_Odd,
  input carry_in,
  input PCLK,
  output OV_Odd,
  output carry_out,
  output OV_Even );
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

  assign w1 = ~(w0 | V_Even);
  assign w3 = ~(w2 & V_Odd);
  assign w4 = ~(V_Odd | w2);
  assign w5 = ~(w0 & V_Even);
  assign w6 = ~w3;
  assign w7 = ~w5;
  assign w8 = ~(carry_in | w1);
  assign w9 = ~(w5 | w4);
  assign carry_out = ~(w9 | w6 | w10);
  assign w10 = ~(w1 | w4 | carry_in);
  assign w11 = ~(w7 | w1);
  assign w12 = ~(w7 | w8);
  assign w13 = ~(w4 | w6);
  assign w14 = carry_in & w11;
  assign w15 = ~(w13 | w12);
  assign w16 = w12 & w13;
  assign w17 = ~(carry_in | w11);
  assign w18 = ~(w15 | w16);
  assign w19 = ~(w17 | w14);
  assign OV_Odd = ~w18;
  assign OV_Even = ~w19;
  dlatch u0 (.en(PCLK), .d(OB_Odd), .q(w20), .nq(w2));
  dlatch u1 (.en(PCLK), .d(OB_Even), .q(w21), .nq(w0));
endmodule

module Eval_Cmp (
  input O8_16,
  input PCLK,
  input [7:0] OB,
  input [7:0] V,
  input COPY_OVF,
  output [7:0] OV,
  output OVZ );
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
  assign w1 = ~O8_16;
  assign w2 = w1 & OV[3];
  assign w4 = ~(w3 | V[7]);
  assign OVZ = ~(OV[4] | OV[5] | OV[6] | OV[7] | w2 | w4 | COPY_OVF);
  dlatch u0 (.en(PCLK), .d(OB[7]), .q(w5), .nq(w3));
  Eval_CmpBitPair u1 (.PCLK(PCLK), .OB_Even(OB[2]), .V_Even(V[2]), .OB_Odd(OB[3]), .V_Odd(V[3]), .carry_in(w6), .OV_Even(OV[2]), .OV_Odd(OV[3]), .carry_out(w7));
  Eval_CmpBitPair u2 (.PCLK(PCLK), .OB_Even(OB[4]), .V_Even(V[4]), .OB_Odd(OB[5]), .V_Odd(V[5]), .carry_in(w7), .OV_Even(OV[4]), .OV_Odd(OV[5]), .carry_out(w8));
  Eval_CmpBitPair u3 (.PCLK(PCLK), .OB_Even(OB[6]), .V_Even(V[6]), .OB_Odd(OB[7]), .V_Odd(V[7]), .carry_in(w8), .OV_Even(OV[6]), .OV_Odd(OV[7]), .carry_out(w9));
  Eval_CmpBitPair u4 (.PCLK(PCLK), .OB_Even(OB[0]), .V_Even(V[0]), .OB_Odd(OB[1]), .V_Odd(V[1]), .carry_in(w0), .OV_Even(OV[0]), .OV_Odd(OV[1]), .carry_out(w6));
endmodule

module ObjEval (
  output DB5,
  output [7:0] n_OAM,
  output OAM8,
  output OAMCTR2,
  output SPR_OV,
  output [7:0] OV,
  output PD_FIFO,
  output n_SPR0_EV,
  input n_FNT,
  input S_EV,
  input n_PCLK,
  input BLNK,
  input I_OAM2,
  input n_VIS,
  input OBJ_READ,
  input n_EVAL,
  input RESCL,
  input H0_DD,
  input H0_D,
  input n_H2_D,
  input OFETCH,
  input n_W3,
  input n_DBE,
  input PCLK,
  input n_R2,
  input [7:0] CPU_DB,
  input [7:0] OB,
  input [7:0] V,
  input O8_16 );
  wire [7:0] bus940_290;
  wire [4:0] bus940_310;
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

  Eval_OAM_Address u0 (.n_VIS(n_VIS), .H0_DD(H0_DD), .BLNK(BLNK), .OAM_x(bus940_290), .OAMTemp(bus940_310), .n_OAM_x(n_OAM), .OAM8(OAM8));
  Eval_FSM u1 (.PCLK(PCLK), .n_F_NT(n_FNT), .H0_DD(H0_DD), .I_OAM2(I_OAM2), .n_VIS(n_VIS), .SPR_OV(SPR_OV), .S_EV(S_EV), .OBJ_READ(OBJ_READ), .OVZ(w0), .PD_FIFO(PD_FIFO), .n_SPR0_EV(n_SPR0_EV), .COPY_OVF(w1), .OMFG(w2));
  Eval_CountersControl u2 (.n_PCLK(n_PCLK), .OMFG(w2), .I_OAM2(I_OAM2), .n_VIS(n_VIS), .OBJ_READ(OBJ_READ), .n_EVAL(n_EVAL), .RESCL(RESCL), .H0_DD(H0_DD), .H0_D(H0_D), .n_H2_D(n_H2_D), .OFETCH(OFETCH), .OMV(w3), .TMV(w4), .n_W3(n_W3), .n_DBE(n_DBE), .OMSTEP(w5), .OMOUT(w6), .OSTEP(w7), .ORES(w8), .OAMCTR2(OAMCTR2), .SPR_OV(SPR_OV), .SPR_OV_Reg(w9), .W3_Enable(w10));
  Eval_SprOV_Flag u3 (.n_R2(n_R2), .n_DBE(n_DBE), .SPR_OV_Reg(w9), .DB5(DB5));
  Eval_MainCounter u4 (.BLNK(BLNK), .OMFG(w2), .OMOUT(w6), .OMSTEP(w5), .OBJ_READ(OBJ_READ), .W3_Enable(w10), .DB_In(CPU_DB), .OAM_x(bus940_290), .OMV(w3));
  Eval_TempCounter u5 (.n_PCLK(n_PCLK), .OSTEP(w7), .ORES(w8), .OAMTemp(bus940_310), .TMV(w4));
  Eval_Cmp u6 (.PCLK(PCLK), .OB(OB), .V(V), .O8_16(O8_16), .COPY_OVF(w1), .OV(OV), .OVZ(w0));
endmodule
