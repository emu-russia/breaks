// Object FIFO - behavioral model of the 2C02 sprite (object) FIFO.
//
// History: the translation of Logisim/Evolution/PPU_Evo.circ left the
// ObjectFIFO internal wiring unconnected (every FIFO_Lane instance sat on
// undriven nets, FIFO_PairedSR/H_Inversion were empty shells), so no sprite
// pixels could ever come out.  The module is re-implemented behaviourally
// from the documented die semantics (BreakingNESWiki/PPU/fifo.md):
//
//   * The FIFO holds one scanline of up to 8 sprites in 8 parallel "lanes".
//     A lane stores: the two pattern bytes of the sprite row, the sprite
//     attribute bits (2 palette bits, 1 priority bit, horizontal flip) and
//     the sprite X position.
//   * Lane contents are loaded during the sprite fetch window: for every dot
//     with OBJ_READ=1 the lane is selected by H3''..H5'' (3-to-8 decode per
//     the fifo.md lane table) and the byte type by H0''..H2'':
//         H0..H2 == 2: attribute byte (OB[1:0] palette, OB[5] priority,
//                      OB[6] horizontal flip)
//         H0..H2 == 3: X position byte (OB)
//         H0..H2 == 5: pattern byte A (PD)
//         H0..H2 == 7: pattern byte B (PD)
//     PD_FIFO=0 (no real sprite in this slot) makes the pattern loads write
//     zeroes instead of the garbage bus value (see obj_eval PD_FIFO).
//     n_OBJ_RD_ATTR mirrors the attribute strobe one dot later for the Data
//     Reader, exactly like the die SpriteH block.
//   * Z_HPOS ("Clear HPos") arms the loaded lanes for the rendering of the
//     scanline: from then on every dot with n_VIS=0 (visible) is one pixel;
//     the lane counts down from its X position and starts emitting sprite
//     pixels at screen dot X (8 pixels in total).  Pattern bit 7 of byte A/B
//     is the leftmost pixel; the horizontal flip bit mirrors the row.
//   * All eight lanes feed a priority encoder; the lane with the lowest
//     sprite index (lane 0 = sprite 0 of the scanline) wins when it emits a
//     non-transparent pixel.  Output polarities follow the die/MUX contract:
//     n_ZCOL0/n_ZCOL1 active-low pixel bits, ZCOL2/ZCOL3 the palette bits,
//     n_ZPRIO active-low priority (0 = sprite in front of the background).
//   * n_SPR0HIT goes low while sprite 0 (lane 0) emits a non-transparent
//     pixel (CLPO and the background side are handled by the Spr0Hit block
//     outside).
//   * CLPO=1 disables all sprite output for that dot (the Clipper drives it
//     during the left 8 pixels when sprite clipping is enabled).
//
// Behavioural on purpose (one action per dot, posedge PCLK).  Compile with
// -D ICARUS.

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

  // ------------------------------------------------------------------
  // Lane state
  // ------------------------------------------------------------------
  reg [1:0] pal [0:7];      // palette select (attribute bits 0..1)
  reg       prio [0:7];     // 1: sprite in front of background (attr bit 5)
  reg       flip [0:7];     // 1: horizontal mirror (attr bit 6)
  reg [7:0] rowA [0:7];     // pattern plane A (bit 7 = leftmost pixel)
  reg [7:0] rowB [0:7];     // pattern plane B
  reg [7:0] xpos [0:7];     // loaded X position
  reg       armed [0:7];    // lane armed by Z_HPOS (rendering this line)
  reg       done  [0:7];    // lane already shifted its 8 pixels out
  reg [7:0] rem   [0:7];    // remaining countdown to the sprite start dot
  reg [3:0] px    [0:7];    // output pixel index 0..7 while emitting

  integer li;
  initial for (li = 0; li < 8; li = li + 1) begin
    pal[li] = 2'd0; prio[li] = 1'b0; flip[li] = 1'b0;
    rowA[li] = 8'd0; rowB[li] = 8'd0; xpos[li] = 8'd0;
    armed[li] = 1'b0; done[li] = 1'b1; rem[li] = 8'd0; px[li] = 4'd0;
  end

  // ------------------------------------------------------------------
  // Selection logic (per wiki fifo.md lane table)
  // ------------------------------------------------------------------
  function automatic [2:0] code2lane(input [2:0] code);
    begin
      case (code)
        3'd0: code2lane = 3'd7;   // /H3 /H4 /H5
        3'd1: code2lane = 3'd3;   // /H3 /H4  H5
        3'd2: code2lane = 3'd5;   // /H3  H4 /H5
        3'd3: code2lane = 3'd1;   // /H3  H4  H5
        3'd4: code2lane = 3'd6;   //  H3 /H4 /H5
        3'd5: code2lane = 3'd2;   //  H3 /H4  H5
        3'd6: code2lane = 3'd4;   //  H3  H4 /H5
        default: code2lane = 3'd0; //  H3  H4  H5
      endcase
    end
  endfunction

  wire [2:0] h_code = {H3_DD, H4_DD, H5_DD};
  wire [2:0] p_code = {H0_DD, H1_DD, H2_DD};
  wire [2:0] lane_no = code2lane(h_code);

  // attribute strobe (delayed one dot for the external n_OBJ_RD_ATTR)
  reg attr_d = 1'b1;
  always @(posedge n_PCLK)
    attr_d <= ~(OBJ_READ && (p_code == 3'd2));
  assign n_OBJ_RD_ATTR = attr_d;

  // ------------------------------------------------------------------
  // Dot engine
  // ------------------------------------------------------------------
  always @(posedge PCLK) begin
    // ---- sprite fetch window: load lanes ---------------------------
    if (OBJ_READ) begin
      case (p_code)
      3'd2: begin  // attribute
        pal[lane_no]  <= OB[1:0];
        prio[lane_no] <= OB[5];
        flip[lane_no] <= OB[6];
      end
      3'd3: begin  // X position
        xpos[lane_no] <= OB;
      end
      3'd5: begin  // pattern plane A
        rowA[lane_no] <= PD_FIFO ? PD : 8'd0;
      end
      3'd7: begin  // pattern plane B
        rowB[lane_no] <= PD_FIFO ? PD : 8'd0;
      end
      default: ;
      endcase
    end

    // ---- Z_HPOS: arm all loaded lanes for this scanline -------------
    if (Z_HPOS) begin
      for (li = 0; li < 8; li = li + 1) begin
        armed[li] <= 1'b1;
        done[li]  <= 1'b0;
        rem[li]   <= xpos[li];
        px[li]    <= 4'd0;
      end
    end

    // ---- visible dots: count down / shift ---------------------------
    if (n_VIS == 1'b0 && !Z_HPOS) begin
      for (li = 0; li < 8; li = li + 1) begin
        if (armed[li] && !done[li]) begin
          if (rem[li] > 8'd0) begin
            rem[li] <= rem[li] - 8'd1;
          end else if (px[li] < 4'd8) begin
            // emitting pixels: px increments at the end of each dot
            px[li] <= px[li] + 4'd1;
          end else begin
            done[li] <= 1'b1;
          end
        end
      end
    end
  end

  // ------------------------------------------------------------------
  // Pixel outputs
  // ------------------------------------------------------------------
  // pixel index k of lane i is emitted while rem==0 (dot X..X+7).  Because
  // rem is decremented one dot before the first emission starts, the emit
  // window covers exactly px = 0..7 at dots X..X+7.
  wire [2:0] w_lane;     // winning lane
  wire       w_spr0;     // winning pixel belongs to lane 0
  wire [1:0] w_pix;      // {planeB, planeA} of the winning pixel
  reg        any_pix;
  reg [2:0]  win;
  reg        win_spr0;

  integer wi;
  always @(*) begin
    any_pix = 1'b0;
    win = 3'd0;
    win_spr0 = 1'b0;
    if (!CLPO) begin
      for (wi = 0; wi < 8; wi = wi + 1) begin
        // is lane wi emitting a non-transparent pixel on this dot?
        if (armed[wi] && !done[wi] && (rem[wi] == 8'd0) && (px[wi] < 4'd8)) begin
          // px[wi] was already incremented for the *next* dot; this dot's
          // pixel index is px[wi] (before the shift), i.e. the value the
          // register held at the start of the dot.  Because the register is
          // updated on posedge and outputs are sampled between edges, use
          // the current register value directly.
          if ((flip[wi] ? rowA[wi][px[wi]] : rowA[wi][7 - px[wi]]) ||
              (flip[wi] ? rowB[wi][px[wi]] : rowB[wi][7 - px[wi]])) begin
            if (!any_pix) begin
              any_pix = 1'b1;
              win = wi[2:0];
              win_spr0 = (wi == 0);
            end
          end
        end
      end
    end
  end

  wire w_a = any_pix && (flip[win] ? rowA[win][px[win]] : rowA[win][7 - px[win]]);
  wire w_b = any_pix && (flip[win] ? rowB[win][px[win]] : rowB[win][7 - px[win]]);

  assign n_ZCOL0  = any_pix ? ~w_a : 1'b1;
  assign n_ZCOL1  = any_pix ? ~w_b : 1'b1;
  assign ZCOL2    = any_pix ? pal[win][0] : 1'b0;
  assign ZCOL3    = any_pix ? pal[win][1] : 1'b0;
  assign n_ZPRIO  = any_pix ? ~prio[win] : 1'b1;
  assign n_SPR0HIT = (any_pix && win_spr0) ? 1'b0 : 1'b1;

endmodule // ObjectFIFO
