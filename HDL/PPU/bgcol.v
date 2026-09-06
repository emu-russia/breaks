module BGC_Out (
  input n_CLPB,
  input n_BGC0_Out,
  input PCLK,
  input BGC1_Out,
  input n_BGC2_Out,
  input n_BGC3_Out,
  input n_PCLK,
  output [3:0] BGC );
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
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = ~n_BGC0_Out;
  assign w1 = ~n_BGC2_Out;
  assign w2 = ~n_BGC3_Out;
  assign BGC[0] = ~(w3 | w4);
  assign BGC[1] = ~(w5 | w4);
  assign BGC[2] = ~(w6 | w4);
  assign BGC[3] = ~(w7 | w4);
  dlatch u0 (.en(n_PCLK), .d(w0), .q(w8), .nq(w9));
  dlatch u1 (.en(n_PCLK), .d(BGC1_Out), .q(w10), .nq(w11));
  dlatch u2 (.en(n_PCLK), .d(w1), .q(w12), .nq(w13));
  dlatch u3 (.en(n_PCLK), .d(w2), .q(w14), .nq(w15));
  dlatch u4 (.en(PCLK), .d(w9), .q(w3), .nq(w16));
  dlatch u5 (.en(PCLK), .d(w11), .q(w5), .nq(w17));
  dlatch u6 (.en(PCLK), .d(w13), .q(w6), .nq(w18));
  dlatch u7 (.en(PCLK), .d(w15), .q(w7), .nq(w19));
  dlatch u8 (.en(PCLK), .d(n_CLPB), .q(w20), .nq(w4));
endmodule

module BGC_Control (
  input H0_DD,
  input F_TA,
  input F_TB,
  input n_FO,
  input F_AT,
  input PCLK,
  input n_PCLK,
  input [4:0] THO,
  output PD_SR,
  output SRLOAD,
  output STEP,
  output STEP2,
  output PD_SEL,
  output NEXTS,
  output H01 );
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
  assign w1 = ~F_TA;
  assign w2 = ~F_TB;
  assign w3 = ~n_FO;
  assign w4 = ~F_AT;
  assign w5 = ~(w2 | w0);
  assign PD_SR = ~(w1 | w0 | PCLK);
  assign SRLOAD = ~(w2 | w0 | PCLK);
  assign STEP = ~(PCLK | w5 | w3);
  assign STEP2 = ~(PCLK | w3);
  assign PD_SEL = ~(w6 | PCLK | w0);
  assign NEXTS = ~(STEP | STEP2 | n_PCLK);
  assign H01 = ~w7;
  dlatch u0 (.en(PCLK), .d(w4), .q(w6), .nq(w8));
  dlatch u1 (.en(PCLK), .d(THO[1]), .q(w9), .nq(w7));
endmodule

module DLatch_x8 (
  input enable,
  input [7:0] val,
  output [7:0] val_out,
  output [7:0] n_val_out );

  dlatch u0 (.en(enable), .d(val[1]), .q(val_out[1]), .nq(n_val_out[1]));
  dlatch u1 (.en(enable), .d(val[2]), .q(val_out[2]), .nq(n_val_out[2]));
  dlatch u2 (.en(enable), .d(val[3]), .q(val_out[3]), .nq(n_val_out[3]));
  dlatch u3 (.en(enable), .d(val[4]), .q(val_out[4]), .nq(n_val_out[4]));
  dlatch u4 (.en(enable), .d(val[5]), .q(val_out[5]), .nq(n_val_out[5]));
  dlatch u5 (.en(enable), .d(val[6]), .q(val_out[6]), .nq(n_val_out[6]));
  dlatch u6 (.en(enable), .d(val[7]), .q(val_out[7]), .nq(n_val_out[7]));
  dlatch u7 (.en(enable), .d(val[0]), .q(val_out[0]), .nq(n_val_out[0]));
endmodule

module BGC_SRBit (
  input LOAD,
  input STEP,
  input NEXTS,
  input shift_in,
  input val_in,
  output shift_out );
  wire w0;
  wire w1;
  wire w2;
  wire w3;
  wire w4;
  wire w5;
  wire w6;

  assign w0 = 1'd0;
  assign w1 = LOAD ? val_in : 'bz;
  assign w1 = STEP ? shift_in : 'bz;
  dlatch u (.d(w1), .en(w0), .q(w2), .nq(w3));
  dlatch u0 (.en(NEXTS), .d(w3), .q(w6), .nq(shift_out));
endmodule

module BGC_SR8 (
  input Nexts,
  input [7:0] val,
  input sin,
  input Load,
  input Step,
  output [7:0] sout );
  wire [2:0] bus820_40;
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
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  BGC_SRBit u0 (.shift_in(w0), .val_in(w1), .LOAD(w2), .STEP(w3), .NEXTS(w4), .shift_out(sout[3]));
  BGC_SRBit u1 (.shift_in(w5), .val_in(w6), .LOAD(w7), .STEP(w8), .NEXTS(w9), .shift_out(sout[7]));
  BGC_SRBit u2 (.shift_in(w10), .val_in(w11), .LOAD(w12), .STEP(w13), .NEXTS(w14), .shift_out(sout[2]));
  BGC_SRBit u3 (.shift_in(w15), .val_in(w16), .LOAD(w17), .STEP(w18), .NEXTS(w19), .shift_out(sout[6]));
  BGC_SRBit u4 (.shift_in(w20), .val_in(w21), .LOAD(w22), .STEP(w23), .NEXTS(w24), .shift_out(sout[1]));
  BGC_SRBit u5 (.shift_in(w25), .val_in(w26), .LOAD(w27), .STEP(w28), .NEXTS(w29), .shift_out(sout[5]));
  BGC_SRBit u6 (.shift_in(w30), .val_in(w31), .LOAD(w32), .STEP(w33), .NEXTS(w34), .shift_out(sout[0]));
  BGC_SRBit u7 (.shift_in(w35), .val_in(w36), .LOAD(w37), .STEP(w38), .NEXTS(w39), .shift_out(sout[4]));
endmodule

module BGC_0 (
  input PD_SR,
  input SRLOAD,
  input STEP,
  input STEP2,
  input NEXTS,
  input [2:0] FH,
  input [7:0] PD,
  output n_BGC0_Out );
  wire [7:0] bus270_160;
  wire [7:0] bus270_180;
  wire [7:0] bus270_210;
  wire [7:0] bus280_170;
  wire [7:0] bus420_210;
  wire [7:0] bus500_130;
  wire [7:0] bus50_180;
  wire [7:0] bus670_180;
  wire [7:0] bus390_170;
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
  assign w1 = 1'd0;
  assign n_BGC0_Out = (FH==3'd7) ? bus670_180[7] : ((FH==3'd6) ? bus670_180[6] : ((FH==3'd5) ? bus670_180[5] : ((FH==3'd4) ? bus670_180[4] : ((FH==3'd3) ? bus670_180[3] : ((FH==3'd2) ? bus670_180[2] : ((FH==3'd1) ? bus670_180[1] : (bus670_180[0])))))));
  DLatch_x8 u0 (.enable(w2), .val(bus50_180), .val_out(bus270_160), .n_val_out(bus270_180));
  BGC_SR8 u1 (.sin(w3), .Load(w4), .Step(bus280_170[0]), .Nexts(w5), .val(bus270_210), .sout(bus500_130));
  BGC_SR8 u2 (.sin(w6), .Load(w7), .Step(w8), .Nexts(w9), .val(bus420_210), .sout(bus670_180));
endmodule

module BGC_1 (
  input SRLOAD,
  input STEP,
  input STEP2,
  input NEXTS,
  input [2:0] FH,
  input [7:0] PD,
  output BGC1_Out );
  wire [7:0] bus270_210;
  wire [7:0] bus420_210;
  wire [7:0] bus500_130;
  wire [7:0] bus670_180;
  wire [7:0] bus390_170;
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
  assign w1 = 1'd0;
  assign BGC1_Out = (FH==3'd7) ? bus670_180[7] : ((FH==3'd6) ? bus670_180[6] : ((FH==3'd5) ? bus670_180[5] : ((FH==3'd4) ? bus670_180[4] : ((FH==3'd3) ? bus670_180[3] : ((FH==3'd2) ? bus670_180[2] : ((FH==3'd1) ? bus670_180[1] : (bus670_180[0])))))));
  BGC_SR8 u0 (.sin(w2), .Load(w3), .Step(w4), .Nexts(w5), .val(bus270_210), .sout(bus500_130));
  BGC_SR8 u1 (.sin(w6), .Load(w7), .Step(w8), .Nexts(w9), .val(bus420_210), .sout(bus670_180));
endmodule

module BGC_2 (
  input PD_SEL,
  input [4:0] TVO,
  input H01,
  input SRLOAD,
  input STEP2,
  input NEXTS,
  input [2:0] FH,
  input [7:0] PD,
  output n_BGC2_Out );
  wire [7:0] bus420_210;
  wire [7:0] bus670_180;
  wire [1:0] bus310_120;
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
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = 1'd0;
  assign w1 = 1'd0;
  assign w6 = ({H01, bus310_120[1]}==2'd3) ? w5 : (({H01, bus310_120[1]}==2'd2) ? w4 : (({H01, bus310_120[1]}==2'd1) ? w3 : (w2)));
  assign n_BGC2_Out = (FH==3'd7) ? bus670_180[7] : ((FH==3'd6) ? bus670_180[6] : ((FH==3'd5) ? bus670_180[5] : ((FH==3'd4) ? bus670_180[4] : ((FH==3'd3) ? bus670_180[3] : ((FH==3'd2) ? bus670_180[2] : ((FH==3'd1) ? bus670_180[1] : (bus670_180[0])))))));
  dlatch u0 (.en(PD_SEL), .d(PD[0]), .q(w7), .nq(w2));
  dlatch u1 (.en(PD_SEL), .d(PD[2]), .q(w8), .nq(w3));
  dlatch u2 (.en(PD_SEL), .d(PD[4]), .q(w9), .nq(w4));
  dlatch u3 (.en(PD_SEL), .d(PD[6]), .q(w10), .nq(w5));
  BGC_SRBit u4 (.shift_in(w11), .val_in(w12), .LOAD(w13), .STEP(w14), .NEXTS(w15), .shift_out(w16));
  BGC_SR8 u5 (.sin(w17), .Load(w18), .Step(w19), .Nexts(w20), .val(bus420_210), .sout(bus670_180));
endmodule

module BGC_3 (
  input PD_SEL,
  input [4:0] TVO,
  input H01,
  input SRLOAD,
  input STEP2,
  input NEXTS,
  input [2:0] FH,
  input [7:0] PD,
  output n_BGC3_Out );
  wire [7:0] bus420_210;
  wire [7:0] bus670_180;
  wire [1:0] bus310_120;
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
  wire w3;
  wire w4;
  wire w5;
  wire w6;
  wire w7;
  wire w8;
  wire w9;

  assign w0 = 1'd0;
  assign w1 = 1'd0;
  assign w6 = ({H01, bus310_120[1]}==2'd3) ? w5 : (({H01, bus310_120[1]}==2'd2) ? w4 : (({H01, bus310_120[1]}==2'd1) ? w3 : (w2)));
  assign n_BGC3_Out = (FH==3'd7) ? bus670_180[7] : ((FH==3'd6) ? bus670_180[6] : ((FH==3'd5) ? bus670_180[5] : ((FH==3'd4) ? bus670_180[4] : ((FH==3'd3) ? bus670_180[3] : ((FH==3'd2) ? bus670_180[2] : ((FH==3'd1) ? bus670_180[1] : (bus670_180[0])))))));
  dlatch u0 (.en(PD_SEL), .d(PD[1]), .q(w7), .nq(w2));
  dlatch u1 (.en(PD_SEL), .d(PD[3]), .q(w8), .nq(w3));
  dlatch u2 (.en(PD_SEL), .d(PD[5]), .q(w9), .nq(w4));
  dlatch u3 (.en(PD_SEL), .d(PD[7]), .q(w10), .nq(w5));
  BGC_SRBit u4 (.shift_in(w11), .val_in(w12), .LOAD(w13), .STEP(w14), .NEXTS(w15), .shift_out(w16));
  BGC_SR8 u5 (.sin(w17), .Load(w18), .Step(w19), .Nexts(w20), .val(bus420_210), .sout(bus670_180));
endmodule

module BGCol (
  output [3:0] BGC,
  input H0_DD,
  input F_TA,
  input F_TB,
  input n_FO,
  input F_AT,
  input [4:0] THO,
  input [4:0] TVO,
  input [2:0] FH,
  input PCLK,
  input n_CLPB,
  input n_PCLK,
  input [7:0] PD );
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

  BGC_Out u0 (.PCLK(PCLK), .n_PCLK(n_PCLK), .n_CLPB(n_CLPB), .n_BGC0_Out(w0), .BGC1_Out(w1), .n_BGC2_Out(w2), .n_BGC3_Out(w3), .BGC(BGC));
  BGC_Control u1 (.PCLK(PCLK), .n_PCLK(n_PCLK), .H0_DD(H0_DD), .F_TA(F_TA), .F_TB(F_TB), .n_FO(n_FO), .F_AT(F_AT), .THO(THO), .PD_SR(w4), .SRLOAD(w5), .STEP(w6), .STEP2(w7), .PD_SEL(w8), .NEXTS(w9), .H01(w10));
  BGC_0 u2 (.PD_SR(w4), .PD(PD), .SRLOAD(w5), .STEP(w6), .STEP2(w7), .NEXTS(w9), .FH(FH), .n_BGC0_Out(w0));
  BGC_1 u3 (.PD(PD), .SRLOAD(w5), .STEP(w6), .STEP2(w7), .NEXTS(w9), .FH(FH), .BGC1_Out(w1));
  BGC_2 u4 (.TVO(TVO), .H01(w10), .PD_SEL(w8), .PD(PD), .SRLOAD(w5), .STEP2(w7), .NEXTS(w9), .FH(FH), .n_BGC2_Out(w2));
  BGC_3 u5 (.TVO(TVO), .H01(w10), .PD_SEL(w8), .PD(PD), .SRLOAD(w5), .STEP2(w7), .NEXTS(w9), .FH(FH), .n_BGC3_Out(w3));
endmodule
