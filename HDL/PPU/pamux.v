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

  // u0 "in_latch" enable is tied to Vdd (the .circ Constant with no value
  // attribute defaults to 1 in Logisim-Evolution): the element is a
  // permanently transparent buffer/inverter, so w7 follows ~(mux output).
  // (Previously generated as 1'd0, which froze the latch and stuck n_PAx=1.)
  assign w0 = 1'd1;
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

  // See PamuxHighBit: u0 "in_latch" enable tied to Vdd (default-1 Constant).
  assign w0 = 1'd1;
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
  // 14 independent address-bit cells.  The address latch of every bit can be
  // loaded from the attribute-table, name-table or pattern(PAR) address bus,
  // and the low eight bits can also be loaded from the CPU data bus (DB_PAR
  // mode, used for the CPU VRAM port).  The cell output /PAx is active-low,
  // matching the PPU's external /PA0-13 address bus.
  PamuxHighBit u0  (.PCLK(PCLK), .PARR(PARR), .PAH(PAH), .F_AT(F_AT), .AT_ADR(AT_ADR[13]), .NT_ADR(NT_ADR[13]), .PAT_ADR(PAT_ADR[13]), .n_PAx(n_PAx[13]));
  PamuxHighBit u1  (.PCLK(PCLK), .PARR(PARR), .PAH(PAH), .F_AT(F_AT), .AT_ADR(AT_ADR[8]),  .NT_ADR(NT_ADR[8]),  .PAT_ADR(PAT_ADR[8]),  .n_PAx(n_PAx[8]));
  PamuxHighBit u2  (.PCLK(PCLK), .PARR(PARR), .PAH(PAH), .F_AT(F_AT), .AT_ADR(AT_ADR[9]),  .NT_ADR(NT_ADR[9]),  .PAT_ADR(PAT_ADR[9]),  .n_PAx(n_PAx[9]));
  PamuxHighBit u3  (.PCLK(PCLK), .PARR(PARR), .PAH(PAH), .F_AT(F_AT), .AT_ADR(AT_ADR[10]), .NT_ADR(NT_ADR[10]), .PAT_ADR(PAT_ADR[10]), .n_PAx(n_PAx[10]));
  PamuxHighBit u4  (.PCLK(PCLK), .PARR(PARR), .PAH(PAH), .F_AT(F_AT), .AT_ADR(AT_ADR[11]), .NT_ADR(NT_ADR[11]), .PAT_ADR(PAT_ADR[11]), .n_PAx(n_PAx[11]));
  PamuxHighBit u5  (.PCLK(PCLK), .PARR(PARR), .PAH(PAH), .F_AT(F_AT), .AT_ADR(AT_ADR[12]), .NT_ADR(NT_ADR[12]), .PAT_ADR(PAT_ADR[12]), .n_PAx(n_PAx[12]));
  PamuxLowBit u6   (.PCLK(PCLK), .PARR(PARR), .DB_PAR(DB_PAR), .PAL(PAL), .F_AT(F_AT), .AT_ADR(AT_ADR[7]), .NT_ADR(NT_ADR[7]), .PAT_ADR(PAT_ADR[7]), .DBx(DB_in[7]), .n_PAx(n_PAx[7]));
  PamuxLowBit u7   (.PCLK(PCLK), .PARR(PARR), .DB_PAR(DB_PAR), .PAL(PAL), .F_AT(F_AT), .AT_ADR(AT_ADR[0]), .NT_ADR(NT_ADR[0]), .PAT_ADR(PAT_ADR[0]), .DBx(DB_in[0]), .n_PAx(n_PAx[0]));
  PamuxLowBit u8   (.PCLK(PCLK), .PARR(PARR), .DB_PAR(DB_PAR), .PAL(PAL), .F_AT(F_AT), .AT_ADR(AT_ADR[1]), .NT_ADR(NT_ADR[1]), .PAT_ADR(PAT_ADR[1]), .DBx(DB_in[1]), .n_PAx(n_PAx[1]));
  PamuxLowBit u9   (.PCLK(PCLK), .PARR(PARR), .DB_PAR(DB_PAR), .PAL(PAL), .F_AT(F_AT), .AT_ADR(AT_ADR[2]), .NT_ADR(NT_ADR[2]), .PAT_ADR(PAT_ADR[2]), .DBx(DB_in[2]), .n_PAx(n_PAx[2]));
  PamuxLowBit u10  (.PCLK(PCLK), .PARR(PARR), .DB_PAR(DB_PAR), .PAL(PAL), .F_AT(F_AT), .AT_ADR(AT_ADR[3]), .NT_ADR(NT_ADR[3]), .PAT_ADR(PAT_ADR[3]), .DBx(DB_in[3]), .n_PAx(n_PAx[3]));
  PamuxLowBit u11  (.PCLK(PCLK), .PARR(PARR), .DB_PAR(DB_PAR), .PAL(PAL), .F_AT(F_AT), .AT_ADR(AT_ADR[4]), .NT_ADR(NT_ADR[4]), .PAT_ADR(PAT_ADR[4]), .DBx(DB_in[4]), .n_PAx(n_PAx[4]));
  PamuxLowBit u12  (.PCLK(PCLK), .PARR(PARR), .DB_PAR(DB_PAR), .PAL(PAL), .F_AT(F_AT), .AT_ADR(AT_ADR[5]), .NT_ADR(NT_ADR[5]), .PAT_ADR(PAT_ADR[5]), .DBx(DB_in[5]), .n_PAx(n_PAx[5]));
  PamuxLowBit u13  (.PCLK(PCLK), .PARR(PARR), .DB_PAR(DB_PAR), .PAL(PAL), .F_AT(F_AT), .AT_ADR(AT_ADR[6]), .NT_ADR(NT_ADR[6]), .PAT_ADR(PAT_ADR[6]), .DBx(DB_in[6]), .n_PAx(n_PAx[6]));
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
