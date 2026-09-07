// Sprite evaluation (ObjEval) - behavioral model of the 2C02 sprite
// evaluator.
//
// History: the original translation of Logisim/Evolution/PPU_Evo.circ left
// the internal connections of ObjEval floating (Eval_FSM PosedgeDFFE inputs,
// Eval_MainCounter/Eval_TempCounter control nets had no drivers), so the
// module could never perform a scanline evaluation.  It is re-implemented
// behaviourally here from the documented die semantics
// (BreakingNESWiki/PPU/obj_eval.md, oam.md):
//
//   * During the evaluation window of a visible scanline the PPU walks the 64
//     OAM sprites (4 bytes each: Y,tile,attr,X) and selects the up to 8
//     sprites whose Y range (8 or 16 rows, see O8_16) contains the current
//     scanline V.
//   * The walk is presented on the OAM interface:
//       - search dot:  OAM8=0, n_OAM = ~(4*sprite)     (Y byte of sprite s)
//       - copy dots:   the byte that was read one dot earlier is written back
//                      into the temp (secondary) OAM area:
//                      OAM8=1, n_OAM = ~(4*slot + byte),
//                      slot = order in which the sprite was found (0..7).
//       The byte loop-back (OAM buffer read, then write out) is done by the
//       OAM block (oam.v); OAMCTR2=1 marks the temp write-back dots (OAM
//       buffer copies the byte read one dot earlier into the addressed temp
//       cell).
//   * SPR_OV (live) is set when a 9th on-line sprite is found; evaluation is
//     then stopped (as on the die) and SPR_OV is cleared by the next I_OAM2.
//     The sticky $2002[5] flag (spr_ov_reg) is cleared by RESCL and read out
//     on DB5 while the CPU reads $2002 (n_R2=0 and n_DBE=0); otherwise DB5 is
//     tri-state (the CPU data bus has precharge pull-ups in the pads).
//   * n_SPR0_EV is driven low when sprite 0 (sprite index 0) is found on the
//     line; it is reset by I_OAM2 of the next line.
//   * When the evaluation window ends (n_EVAL goes high), the module serves
//     the object-FIFO load window: while OBJ_READ is high it re-presents the
//     temp OAM bytes 0..31 (OAM8=1, one per dot) for the FIFO loads.
//     PD_FIFO=1 only while the served byte belongs to a real sprite
//     (byte < 4*found); the empty tail slots must be filled with zeroes.
//     OV carries the in-sprite row offset (V - Y) of the sprite whose temp
//     byte is currently served (used by the pattern address register).
//
// NTSC/PAL: the per-line selection rule is identical for both revisions (PAL
// only shifts the whole pipeline by one extra scanline at the FSM level).
//
// Behavioural on purpose: the two-phase (PCLK/n_PCLK) latch logic of the die
// is modelled with one action per pixel dot (posedge PCLK); the inputs are
// sampled with the levels they hold during the dot, and the OAM data OB for
// the address presented during dot N is assumed to be valid on the module
// input at the posedge PCLK that ends dot N (1-dot bus latency, matching the
// OAM buffer FF of the die).  Compile with -D ICARUS.

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

  // ------------------------------------------------------------------
  // State
  // ------------------------------------------------------------------
  // typ: op that was presented during the *previous* dot (its data/effect is
  // consumed on the current edge).  NONE = nothing presented.
  localparam T_NONE = 2'd0;  // idle
  localparam T_SRCH = 2'd1;  // search read: OAM8=0, n_OAM = ~(4*sprite)
  localparam T_READ = 2'd2;  // copy main read: OAM8=0, n_OAM = ~(4*sprite + b)
  localparam T_WR   = 2'd3;  // temp write-back: OAM8=1, OAMCTR2=1, n_OAM = ~tc

  reg [1:0] typ = T_NONE;
  reg       in_fetch = 1'b0;  // serving the temp OAM to the FIFO
  reg [7:0] sbase = 8'd0;     // main OAM byte address of the sprite base (4*s)
  reg [4:0] tc = 5'd0;        // temp byte write address (4*slot + b)
  reg [3:0] found = 4'd0;     // sprites copied this scanline (0..8)
  reg [1:0] b = 2'd0;         // byte 0..3 within the sprite being copied
  reg [4:0] fetch_ptr = 5'd0; // temp byte pointer of the fetch window

  reg       spr0_ff = 1'b1;     // n_SPR0_EV storage (1 = sprite 0 not found)
  reg       ovf = 1'b0;        // live overflow (cleared by I_OAM2)
  reg       ovf_reg = 1'b0;    // sticky $2002[5] (cleared by RESCL)
  reg [3:0] offs[0:7];         // per temp-slot in-sprite row offset (V-Y)
  reg       n_eval_d = 1'b1;   // previous n_EVAL (edge detect = E_EV)

  // ------------------------------------------------------------------
  // Outputs (combinational from the state that is presented this dot)
  // ------------------------------------------------------------------
  wire [7:0] paddr =
    (typ == T_WR)   ? {3'b000, tc} :
    in_fetch        ? {3'b000, fetch_ptr} :
    (typ == T_READ) ? (sbase + {6'b000000, b}) :
                      sbase;

  assign n_OAM   = ~paddr;
  assign OAM8    = (typ == T_WR) || in_fetch;
  // OAMCTR2 marks the temp write-back dots (the OAM buffer copies the byte
  // that was read one dot earlier into the addressed temp cell).
  assign OAMCTR2 = (typ == T_WR);
  assign SPR_OV  = ovf;
  assign PD_FIFO = in_fetch && OBJ_READ && (fetch_ptr < {1'b0, found, 1'b0});
  assign n_SPR0_EV = spr0_ff;
  assign DB5 = (n_R2 == 1'b0 && n_DBE == 1'b0) ? ovf_reg : 1'bz;

  reg [7:0] ov_comb;
  always @(*) begin
    if (in_fetch && OBJ_READ)
      ov_comb = {4'b0, offs[fetch_ptr[4:2]]};
    else if (OB <= V)
      ov_comb = V - OB;
    else
      ov_comb = 8'd0;
  end
  assign OV = ov_comb;

  integer k;
  initial for (k = 0; k < 8; k = k + 1) offs[k] = 4'd0;

  // ------------------------------------------------------------------
  // Dot engine (one op per dot: consume the op presented last dot, then
  // present the next op for the following dot)
  // ------------------------------------------------------------------
  always @(posedge PCLK) begin
    // sticky $2002[5] overflow flag: cleared at the end of VBlank
    if (RESCL)
      ovf_reg <= 1'b0;

    if (I_OAM2) begin
      // init OAM2: start a fresh evaluation of the next scanline
      typ <= T_NONE;
      in_fetch <= 1'b0;
      sbase <= 8'd0; tc <= 5'd0; found <= 4'd0; b <= 2'd0;
      fetch_ptr <= 5'd0;
      spr0_ff <= 1'b1;
      ovf <= 1'b0;
    end else if (S_EV) begin
      // start sprite evaluation: present sprite 0's Y byte on the next dot
      typ <= T_SRCH;
      sbase <= 8'd0;
      n_eval_d <= 1'b1;
    end else if (in_fetch) begin
      // ---- post-eval fetch: serve the temp OAM bytes to the FIFO --------
      if (OBJ_READ) begin
        if (fetch_ptr < 5'd31)
          fetch_ptr <= fetch_ptr + 5'd1;
      end else begin
        in_fetch <= 1'b0;
        typ <= T_NONE;
      end
    end else begin
      case (typ)
      T_NONE: begin
        // idle
      end
      T_SRCH: begin
        // The Y byte of candidate sprite s = sbase>>2 was read during the
        // last dot; OB holds its value now.
        if (OB <= V && V < OB + (O8_16 ? 8'd16 : 8'd8)) begin
          // candidate sprite is on this scanline
          if (found == 4'd8) begin
            // 9th sprite on the line: sprite overflow, evaluation stops
            ovf <= 1'b1;
            ovf_reg <= 1'b1;
            typ <= T_NONE;
          end else begin
            if (sbase == 8'd0)
              spr0_ff <= 1'b0;                    // sprite 0 is on the line
            b <= 2'd0;
            tc <= {1'b0, found[3:0], 2'b00};      // 4*slot + 0
            offs[found[2:0]] <= V[3:0] - OB[3:0];
            // write the Y byte back to the temp area on the next dot
            typ <= T_WR;
          end
        end else begin
          // not on the line: step to the next sprite
          if (sbase == 8'd252) begin
            typ <= T_NONE;                        // sprite 63 was last
          end else begin
            sbase <= sbase + 8'd4;
            typ <= T_SRCH;
          end
        end
      end
      T_WR: begin
        // A temp write-back of byte b just happened.
        if (b == 2'd3) begin
          // all 4 bytes copied: slot complete, resume the search
          found <= found + 4'd1;
          b <= 2'd0;
          if (sbase == 8'd252) begin
            typ <= T_NONE;                        // sprite 63 was last
          end else begin
            sbase <= sbase + 8'd4;
            typ <= T_SRCH;
          end
        end else begin
          // read the next byte of this sprite from the main OAM
          b <= b + 2'd1;
          typ <= T_READ;
        end
      end
      T_READ: begin
        // The main-OAM byte b of the current sprite was read during the last
        // dot; write it back to the temp area on the next dot.
        tc <= tc + 5'd1;
        typ <= T_WR;
      end
      default: typ <= T_NONE;
      endcase
    end

    // End of the evaluation window (E_EV edge): cut any unfinished search
    // short and enter the fetch phase.
    n_eval_d <= n_EVAL;
    if (!I_OAM2 && !S_EV && !in_fetch &&
        (typ != T_NONE || sbase != 8'd0) &&
        n_eval_d == 1'b0 && n_EVAL == 1'b1) begin
      // evaluation window ended -> serve the found sprites to the FIFO
      typ <= T_NONE;
      in_fetch <= 1'b1;
      fetch_ptr <= 5'd0;
      if (sbase == 8'd0 && found == 4'd0)
        in_fetch <= 1'b0;   // nothing was evaluated: stay idle
    end
  end

endmodule // ObjEval
