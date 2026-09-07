module SCC_FF (
  input RC,
  input val_in,
  input n_DBE,
  output val_out );

  // scroll-register bit: level latch (DBE write) with async reset
  sdffr ff (.d(val_in), .res(RC), .phi_keep(n_DBE), .q(val_out), .nq());

endmodule

// The five dual scroll-register banks below implement the "loopy" t-register
// fields (see BreakingNESWiki/PPU/scroll_regs.md):
//   FH  = fine X scroll (3 bits), written by the FIRST $2005 write
//   TH  = coarse X (t[4:0]),      written by the first $2005 write / second $2006 write
//   FV  = fine Y (t[14:12]),      written by the second $2005 write / first $2006 write
//   TV  = coarse Y (t[9:5]),      written by the second $2005 write / first $2006 write
//   NT  = nametable select (t[11:10], NTH = t[10], NTV = t[11]), written by $2000 /
//         first $2006 write
// Each bit is a SCC_FF level latch.  The register write pulses (W5_1..W6_2, W0)
// arriving from ScrollRegs are already gated with n_DBE (active high only while
// the matching CPU bus cycle is in progress); a SCC_FF is made transparent only
// during its own write window (capture = selected pulse AND bus enabled) so that
// writes to other PPU registers can never corrupt the stored value, and it holds
// at every other time.  RC asynchronously clears every bit.

module Fine_H (
  input RC,
  input W5_1,
  input n_DBE,
  input [7:0] DB,
  output [2:0] FHx );
  wire w0;

  // First $2005 write: fine-X = DB[2:0] (wiki Fine HScroll table)
  assign w0 = W5_1 & ~n_DBE;
  SCC_FF u0 (.val_in(DB[0]), .n_DBE(~w0), .RC(RC), .val_out(FHx[0]));
  SCC_FF u1 (.val_in(DB[1]), .n_DBE(~w0), .RC(RC), .val_out(FHx[1]));
  SCC_FF u2 (.val_in(DB[2]), .n_DBE(~w0), .RC(RC), .val_out(FHx[2]));
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
  wire w2;

  // Wiki Fine VScroll table:
  //   second $2005 write (W5/2): DB0..DB2 -> FVx[0..2]
  //   first  $2006 write (W6/1): DB4, DB5 -> FVx[0..1], FVx[2] <- 0
  assign w0 = (W5_2 | W6_1) & ~n_DBE;
  assign w1 = W5_2;                 // $2005-second-write data source active
  assign w2 = ~w0;                  // latch keep while no FV write in progress
  SCC_FF u0 (.val_in(w1 ? DB[0] : DB[4]), .n_DBE(w2), .RC(RC), .val_out(FVx[0]));
  SCC_FF u1 (.val_in(w1 ? DB[1] : DB[5]), .n_DBE(w2), .RC(RC), .val_out(FVx[1]));
  SCC_FF u2 (.val_in(w1 ? DB[2] : 1'b0), .n_DBE(w2), .RC(RC), .val_out(FVx[2]));
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

  // Wiki NT Select table:
  //   NTH (t[10]): $2000 bit0 or first-$2006 bit2
  //   NTV (t[11]): $2000 bit1 or first-$2006 bit3
  assign w0 = (W0 | W6_1) & ~n_DBE;
  assign w1 = ~w0;
  SCC_FF u0 (.val_in(W0 ? DB[0] : DB[2]), .n_DBE(w1), .RC(RC), .val_out(NTH));
  SCC_FF u1 (.val_in(W0 ? DB[1] : DB[3]), .n_DBE(w1), .RC(RC), .val_out(NTV));
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
  wire w2;

  // Wiki Tile V table:
  //   TVx[0..2] <- second-$2005 DB3..5 | second-$2006 DB5..7
  //   TVx[3..4] <- second-$2005 DB6..7 | first-$2006  DB0..1
  assign w0 = (W5_2 | W6_2) & ~n_DBE;
  assign w1 = (W5_2 | W6_1) & ~n_DBE;
  assign w2 = W5_2;
  SCC_FF u0 (.val_in(w2 ? DB[3] : DB[5]), .n_DBE(~w0), .RC(RC), .val_out(TVx[0]));
  SCC_FF u1 (.val_in(w2 ? DB[4] : DB[6]), .n_DBE(~w0), .RC(RC), .val_out(TVx[1]));
  SCC_FF u2 (.val_in(w2 ? DB[5] : DB[7]), .n_DBE(~w0), .RC(RC), .val_out(TVx[2]));
  SCC_FF u3 (.val_in(w2 ? DB[6] : DB[0]), .n_DBE(~w1), .RC(RC), .val_out(TVx[3]));
  SCC_FF u4 (.val_in(w2 ? DB[7] : DB[1]), .n_DBE(~w1), .RC(RC), .val_out(TVx[4]));
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

  // Wiki Tile H table:
  //   THx[0..4] <- first-$2005  DB3..7 | second-$2006 DB0..4
  assign w0 = (W5_1 | W6_2) & ~n_DBE;
  assign w1 = W5_1;
  SCC_FF u0 (.val_in(w1 ? DB[3] : DB[0]), .n_DBE(~w0), .RC(RC), .val_out(THx[0]));
  SCC_FF u1 (.val_in(w1 ? DB[4] : DB[1]), .n_DBE(~w0), .RC(RC), .val_out(THx[1]));
  SCC_FF u2 (.val_in(w1 ? DB[5] : DB[2]), .n_DBE(~w0), .RC(RC), .val_out(THx[2]));
  SCC_FF u3 (.val_in(w1 ? DB[6] : DB[3]), .n_DBE(~w0), .RC(RC), .val_out(THx[3]));
  SCC_FF u4 (.val_in(w1 ? DB[7] : DB[4]), .n_DBE(~w0), .RC(RC), .val_out(THx[4]));
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

  // Register write enablers (active high while the matching bus cycle runs):
  // "W5/1" = first $2005 write, "W5/2" = second, "W6/1" = first $2006 write,
  // "W6/2" = second, "W0" = $2000 write.
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
