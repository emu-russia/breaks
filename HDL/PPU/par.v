module V_Inversion (
  input n_PCLK,
  input n_OBJ_RD_ATTR,
  input [7:0] OB,
  output VDIR,
  output VINV );
  // Vertical-flip register of the object pipeline.  While the sprite
  // attribute byte is being read (n_PCLK=0, n_OBJ_RD_ATTR=0, i.e. the
  // "attribute read" window) OB[7] - the vertical flip attribute bit - is
  // captured; the value then holds until the next attribute read.  The die
  // exposes it twice (VINV = flip flag, VDIR = its complement) for the
  // invert-control inputs of the PAR row-bit cells.
  // (The .circ Constant-driven "in_latch" here is a permanently transparent
  // buffer: see the note in pamux.v - the previous generated code left the
  // storage nets undriven, so VDIR/VINV never changed.)
  wire attr_rd;
  wire bus;
  assign attr_rd = ~(n_PCLK | n_OBJ_RD_ATTR);
  assign bus = attr_rd ? OB[7] : 1'bz;
  dlatch u0 (.en(attr_rd), .d(OB[7]), .q(VINV), .nq(VDIR));
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
  // Picture Address Register: assembles the pattern-table byte address
  // (PAddr_out[13:0]) that the PAMUX puts on the VRAM bus during the
  // pattern fetches (BG-LO/BG-HI and sprite fetches).  Bit layout follows
  // the role table in BreakingNESWiki/PPU/par.md:
  //   [13]   = 0 (pattern data lives in $0000-$1FFF)
  //   [12]   = pattern-table select (BG: BGSEL; 8x8 sprite: OBSEL;
  //            8x16 sprite: OAM tile-index bit 0)        -- ParControl PAD12
  //   [11:5] = tile index bits 7..1 (BG: name-table byte from PD;
  //            sprite: OAM tile-index byte from OB)
  //   [4]    = tile index bit 0 (BG: PD bit0; 8x8 sprite: OB bit0;
  //            8x16 sprite: OV[3] selects the lower/upper 8-row half)
  //   [3]    = /H1' - selects the A/B (low/high) pattern byte
  //   [2:0]  = row within the 8-row tile (BG: fine vertical scroll n_FVO;
  //            sprite: OV[2:0], inverted when the sprite is flipped
  //            vertically)                                -- ParBitInv path
  // The V_Inversion block latches OB[7] (vertical-flip attribute) during
  // the sprite attribute read and the ParBitInv cells apply the inversion
  // to the sprite row bits; the background row bits bypass them.
  //
  // NOTE: the previous generated body left every inter-cell wire undriven
  // (all controls, clocks and data feeds floated, so PAddr_out was frozen).
  // The whole wiring below is therefore explicit.  The leaf cells
  // (ParControl, ParBit4, ParBit, ParBitInv, V_Inversion) are unchanged.
  wire [3:0] bus690_910;   // sprite row bits (V-flip adjusted)
  wire O_ctl;              // PAR load-window output of ParControl
  wire VDIR;
  wire VINV;
  wire [2:0] row_src;
  wire n_PCLK_s = n_PCLK;

  assign PAddr_out[13] = 1'd0;
  assign PAddr_out[3]  = ~n_H1D;
  // bits 2..0: background uses the fine-vertical counter directly; sprites
  // use the (possibly inverted) OV bits
  assign row_src[0] = bus690_910[0];
  assign row_src[1] = bus690_910[1];
  assign row_src[2] = bus690_910[2];
  dlatch u7 (.en(n_PCLK), .d(OBJ_READ ? row_src[2] : n_FVO[2]), .q(), .nq(PAddr_out[2]));
  dlatch u8 (.en(n_PCLK), .d(OBJ_READ ? row_src[1] : n_FVO[1]), .q(), .nq(PAddr_out[1]));
  dlatch u9 (.en(n_PCLK), .d(OBJ_READ ? row_src[0] : n_FVO[0]), .q(), .nq(PAddr_out[0]));

  V_Inversion u0 (
    .n_PCLK(n_PCLK),
    .n_OBJ_RD_ATTR(n_OBJ_RD_ATTR),
    .OB(OB),
    .VDIR(VDIR),
    .VINV(VINV) );

  ParControl u1 (
    .n_PCLK(n_PCLK),
    .H0_DD(H0_DD),
    .nF_NT(n_FNT),
    .BGSEL(BGSEL),
    .OBSEL(OBSEL),
    .O8_16(O8_16),
    .OBJ_READ(OBJ_READ),
    .OB(OB),
    .O(O_ctl),
    .PAD12(PAddr_out[12]) );

  // row-bit inverters (sprite mode only, INV = vertical flip)
  ParBitInv u2 (.n_PCLK(n_PCLK), .O(O_ctl), .INV(VINV), .val_in(OV[0]), .val_out(bus690_910[0]));
  ParBitInv u5 (.n_PCLK(n_PCLK), .O(O_ctl), .INV(VINV), .val_in(OV[1]), .val_out(bus690_910[1]));
  ParBitInv u4 (.n_PCLK(n_PCLK), .O(O_ctl), .INV(VINV), .val_in(OV[2]), .val_out(bus690_910[2]));

  // PA4: tile-index bit0 (special: 8x16 sprites replace it with OV[3])
  ParBit4 u6 (
    .n_PCLK(n_PCLK),
    .O(O_ctl),
    .val_OB(OB[0]),
    .val_PD(PD[0]),
    .OBJ_READ(OBJ_READ),
    .O8_16(O8_16),
    .val_OBPrev(OV[3]),
    .PADx(PAddr_out[4]) );

  // PA11..PA5: tile index bits 7..1
  ParBit u10 (.n_PCLK(n_PCLK), .O(O_ctl), .val_OB(OB[7]), .val_PD(PD[7]), .OBJ_READ(OBJ_READ), .PADx(PAddr_out[11]));
  ParBit u11 (.n_PCLK(n_PCLK), .O(O_ctl), .val_OB(OB[6]), .val_PD(PD[6]), .OBJ_READ(OBJ_READ), .PADx(PAddr_out[10]));
  ParBit u12 (.n_PCLK(n_PCLK), .O(O_ctl), .val_OB(OB[5]), .val_PD(PD[5]), .OBJ_READ(OBJ_READ), .PADx(PAddr_out[9]));
  ParBit u13 (.n_PCLK(n_PCLK), .O(O_ctl), .val_OB(OB[4]), .val_PD(PD[4]), .OBJ_READ(OBJ_READ), .PADx(PAddr_out[8]));
  ParBit u14 (.n_PCLK(n_PCLK), .O(O_ctl), .val_OB(OB[3]), .val_PD(PD[3]), .OBJ_READ(OBJ_READ), .PADx(PAddr_out[7]));
  ParBit u15 (.n_PCLK(n_PCLK), .O(O_ctl), .val_OB(OB[2]), .val_PD(PD[2]), .OBJ_READ(OBJ_READ), .PADx(PAddr_out[6]));
  ParBit u16 (.n_PCLK(n_PCLK), .O(O_ctl), .val_OB(OB[1]), .val_PD(PD[1]), .OBJ_READ(OBJ_READ), .PADx(PAddr_out[5]));
endmodule
