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

// One bit of the background data shift/latch cell (PPU_Evo.circ BGC_SRBit
// page): the master latch ("in_latch" DFF, clock tied to the default-high
// constant Vcc -> always-transparent dynamic latch, exactly like the tile
// counter cells) takes val_in when LOAD is high or shift_in when STEP is
// high, and holds otherwise (tri-state keep). The complementary content is
// transferred to the output stage on NEXTS; shift_out follows the cell
// content after that transfer. The original translation tied the master
// enable to 1'd0 which froze every cell.
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

  assign w0 = 1'd1;
  assign w1 = LOAD ? val_in : 'bz;
  assign w1 = STEP ? shift_in : 'bz;
  dlatch u (.d(w1), .en(w0), .q(w2), .nq(w3));
  dlatch u0 (.en(NEXTS), .d(w3), .q(w6), .nq(shift_out));
endmodule

// 8-bit background shift register (PPU_Evo.circ BGC_SR8 page).  The eight
// BGC_SRBit cells share the Nexts/Load/Step controls; stage k loads val[k]
// in parallel on Load and on Step takes the content of stage k+1 (with the
// serial input sin entering the top stage), i.e. a right shift - bit 7 of
// the loaded value is the first pixel out (bit 7 = leftmost tile pixel in
// the NES pattern layout).  sout[k] = content of stage k.  Each stage
// commits to its output on Nexts (two-phase transfer).
module BGC_SR8 (
  input Nexts,
  input [7:0] val,
  input sin,
  input Load,
  input Step,
  output [7:0] sout );
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

  // stage shift_out -> sout[stage] mapping is kept from the schematic nets;
  // the serial chain goes from stage 7 down to stage 0 (sin at stage 7).
  BGC_SRBit u7 (.shift_in(sin),      .val_in(val[7]), .LOAD(Load), .STEP(Step), .NEXTS(Nexts), .shift_out(sout[7]));
  BGC_SRBit u6 (.shift_in(sout[7]),  .val_in(val[6]), .LOAD(Load), .STEP(Step), .NEXTS(Nexts), .shift_out(sout[6]));
  BGC_SRBit u5 (.shift_in(sout[6]),  .val_in(val[5]), .LOAD(Load), .STEP(Step), .NEXTS(Nexts), .shift_out(sout[5]));
  BGC_SRBit u4 (.shift_in(sout[5]),  .val_in(val[4]), .LOAD(Load), .STEP(Step), .NEXTS(Nexts), .shift_out(sout[4]));
  BGC_SRBit u3 (.shift_in(sout[4]),  .val_in(val[3]), .LOAD(Load), .STEP(Step), .NEXTS(Nexts), .shift_out(sout[3]));
  BGC_SRBit u2 (.shift_in(sout[3]),  .val_in(val[2]), .LOAD(Load), .STEP(Step), .NEXTS(Nexts), .shift_out(sout[2]));
  BGC_SRBit u1 (.shift_in(sout[2]),  .val_in(val[1]), .LOAD(Load), .STEP(Step), .NEXTS(Nexts), .shift_out(sout[1]));
  BGC_SRBit u0 (.shift_in(sout[1]),  .val_in(val[0]), .LOAD(Load), .STEP(Step), .NEXTS(Nexts), .shift_out(sout[0]));
endmodule

// BGC_0: background pixel colour bit 0 (pattern plane A, the byte fetched on
// F_TA).  Port list identical to the schematic page.
//
// Datapath model (behavioural; the translator left every internal net of the
// four BGC_* cells undriven, freezing BGC at a constant - see the module
// header).  One 8-bit "display byte" is produced per 8-pixel tile period:
//
//   * PD_SR (BGC_Control: F_TA & H0_DD & ~PCLK) opens the staging latch while
//     the plane-A byte of the current fetch is on PD (the DLatch_x8 on the
//     page).  Data is only latched when defined (0/1), so a floating VRAM bus
//     cannot poison the pipeline.
//   * SRLOAD (F_TB & H0_DD & ~PCLK, at the tile boundary, two dots after the
//     plane-A latch) loads the display shift register from staging.  The byte
//     is loaded bit-reversed: NES pattern bit 7 is the leftmost pixel, and
//     the register rotates once per pixel, so the colour taps come out in
//     pixel order (the page Text: "PD is loaded into the SR in reverse order
//     according to the pixel output order").
//   * STEP + NEXTS (one pair per pixel dot) rotate the register; the colour
//     tap is the stage selected by FH.  Over the 8 dots of a tile period the
//     output walks the pattern byte starting at bit (7-FH) and wrapping, i.e.
//     the fine-H scroll offset selects which pixel of the tile the visible
//     run begins with.
//
// Pixel polarity: BGC_Out re-inverts this net, so n_BGC0_Out = ~pixel bit.
module BGC_0 (
  input PD_SR,
  input SRLOAD,
  input STEP,
  input STEP2,
  input NEXTS,
  input [2:0] FH,
  input [7:0] PD,
  output n_BGC0_Out );
  reg [7:0] staging = 8'h00;   // DLatch_x8 role: pattern-A byte captured at PD_SR
  reg [7:0] master  = 8'h00;   // shift-register master stage (capture phase)
  reg [7:0] disp    = 8'h00;   // committed stage (output/rotation source)
  integer k;

  // staging latch: transparent while PD_SR, holds otherwise; undefined bus
  // bits (z/x) are never captured (like the dlatch primitive).
  always @(PD_SR or PD)
    if (PD_SR)
      for (k = 0; k < 8; k = k + 1)
        staging[k] = (PD[k] === 1'b1) ? 1'b1 : (PD[k] === 1'b0) ? 1'b0 : staging[k];

  // capture phase: SRLOAD takes the staged plane-A byte (bit-reversed so the
  // rotation below walks bit 7 first); STEP rotates the *committed* content
  // (rotation reads disp, which is static while STEP is high, so the master
  // settles - no combinational loop).  master[k] on SRLOAD is guarded against
  // x/z on its source, so floating reads only freeze the cell.
  always @(SRLOAD or STEP or staging or disp or master) begin
    if (SRLOAD) begin
      master[0] = (staging[7] === 1'b1) ? 1'b1 : (staging[7] === 1'b0) ? 1'b0 : master[0];
      master[1] = (staging[6] === 1'b1) ? 1'b1 : (staging[6] === 1'b0) ? 1'b0 : master[1];
      master[2] = (staging[5] === 1'b1) ? 1'b1 : (staging[5] === 1'b0) ? 1'b0 : master[2];
      master[3] = (staging[4] === 1'b1) ? 1'b1 : (staging[4] === 1'b0) ? 1'b0 : master[3];
      master[4] = (staging[3] === 1'b1) ? 1'b1 : (staging[3] === 1'b0) ? 1'b0 : master[4];
      master[5] = (staging[2] === 1'b1) ? 1'b1 : (staging[2] === 1'b0) ? 1'b0 : master[5];
      master[6] = (staging[1] === 1'b1) ? 1'b1 : (staging[1] === 1'b0) ? 1'b0 : master[6];
      master[7] = (staging[0] === 1'b1) ? 1'b1 : (staging[0] === 1'b0) ? 1'b0 : master[7];
    end else if (STEP)
      master = {disp[0], disp[7:1]};
  end

  // commit phase: NEXTS moves the master to the outputs (one pixel per dot).
  always @(NEXTS or master)
    if (NEXTS) disp = master;

  assign n_BGC0_Out = ~disp[FH];
endmodule

// BGC_1: background pixel colour bit 1 (pattern plane B, the byte fetched on
// F_TB).  Same pipeline as BGC_0; plane B arrives on PD during the F_TB
// fetch that ends exactly at the SRLOAD boundary, so no staging latch is
// needed - SRLOAD loads the register straight from PD (mirroring the page,
// which has no DLatch_x8 for plane B).
//
// Rotation/FH semantics are identical to BGC_0 (see there).
module BGC_1 (
  input SRLOAD,
  input STEP,
  input STEP2,
  input NEXTS,
  input [2:0] FH,
  input [7:0] PD,
  output BGC1_Out );
  reg [7:0] master = 8'h00;
  reg [7:0] disp   = 8'h00;
  integer k;

  always @(SRLOAD or STEP or PD or master) begin
    if (SRLOAD) begin
      master[0] = (PD[7] === 1'b1) ? 1'b1 : (PD[7] === 1'b0) ? 1'b0 : master[0];
      master[1] = (PD[6] === 1'b1) ? 1'b1 : (PD[6] === 1'b0) ? 1'b0 : master[1];
      master[2] = (PD[5] === 1'b1) ? 1'b1 : (PD[5] === 1'b0) ? 1'b0 : master[2];
      master[3] = (PD[4] === 1'b1) ? 1'b1 : (PD[4] === 1'b0) ? 1'b0 : master[3];
      master[4] = (PD[3] === 1'b1) ? 1'b1 : (PD[3] === 1'b0) ? 1'b0 : master[4];
      master[5] = (PD[2] === 1'b1) ? 1'b1 : (PD[2] === 1'b0) ? 1'b0 : master[5];
      master[6] = (PD[1] === 1'b1) ? 1'b1 : (PD[1] === 1'b0) ? 1'b0 : master[6];
      master[7] = (PD[0] === 1'b1) ? 1'b1 : (PD[0] === 1'b0) ? 1'b0 : master[7];
    end else if (STEP)
      master = {disp[0], disp[7:1]};
  end

  always @(NEXTS or master)
    if (NEXTS) disp = master;

  assign BGC1_Out = disp[FH];
endmodule

// BGC_2: background pixel colour bit 2 = attribute LSB of the current
// 16x16-pixel quadrant (the colour row / palette select).  The attribute
// byte arrives on PD during F_AT; PD_SEL (BGC_Control) opens the capture
// latches.  Each 2-bit quadrant pair of the byte maps to the four 16x16
// quadrants of the 32x32 attribute region (TL = PD[1:0], TR = PD[3:2],
// BL = PD[5:4], BR = PD[7:6]); this cell keeps the even (LSB) bits of all
// four pairs and the quadrant select {TVO[1] (vertical half of the region,
// constant for a scanline), H01 (~delayed THO[1], horizontal half, toggles
// every two tiles)} picks the pair for the tile period being shown.  The
// pair value moves through the same two phases as the pattern bytes (boundary
// copy on SRLOAD, commit on NEXTS), so the colour row flips on exactly the
// dot the pattern registers change and stays constant for the whole 16-pixel
// group.
// Port list identical to the schematic page.
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
  reg [3:0] atM = 4'b0000;  // captured quadrant LSBs (PD even bits)
  reg [3:0] m2  = 4'b0000;  // boundary stage (SRLOAD)
  reg [3:0] at  = 4'b0000;  // committed quadrant value (colour row)
  integer k;

  always @(PD_SEL or PD)
    if (PD_SEL)
      for (k = 0; k < 4; k = k + 1)
        atM[k] = (PD[2*k] === 1'b1) ? 1'b1 : (PD[2*k] === 1'b0) ? 1'b0 : atM[k];

  // Same two phases as the pattern bytes: the captured candidates are copied
  // on the SRLOAD boundary and committed on the NEXTS phase, so the colour
  // row flips on exactly the same dot as the pattern shift registers (no
  // one-pixel skew between bits 1:0 and 3:2 at tile boundaries).
  always @(SRLOAD or atM or m2)
    if (SRLOAD) m2 = atM;

  always @(NEXTS or m2 or at)
    if (NEXTS) at = m2;

  // quadrant index = {vertical half (TVO[1]), horizontal half (H01)}
  assign n_BGC2_Out = ~at[{TVO[1], H01}];
endmodule

// BGC_3: background pixel colour bit 3 = attribute MSB of the quadrant.
// Mirror of BGC_2 over the odd PD bits.
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
  reg [3:0] atM = 4'b0000;
  reg [3:0] m2  = 4'b0000;
  reg [3:0] at  = 4'b0000;
  integer k;

  always @(PD_SEL or PD)
    if (PD_SEL)
      for (k = 0; k < 4; k = k + 1)
        atM[k] = (PD[2*k+1] === 1'b1) ? 1'b1 : (PD[2*k+1] === 1'b0) ? 1'b0 : atM[k];

  always @(SRLOAD or atM or m2)
    if (SRLOAD) m2 = atM;

  always @(NEXTS or m2 or at)
    if (NEXTS) at = m2;

  assign n_BGC3_Out = ~at[{TVO[1], H01}];
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
