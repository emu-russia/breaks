# Visual 2C02 Signal Mapping

Visual 2C02: http://www.qmtpro.com/~nes/chipimages/visual2c02/

|Breaks signal name|Visual 2C02 signal name|
|---|---|
|Terminals||
|R/W|node: 1224 io_rw|
|D 0-7|io_db0-7|
|RS 0-2|io_ab0-2|
|/DBE|node: 5 io_ce|
|EXT 0-3|exp0-3|
|CLK|node: 772 clk0|
|/INT|node: 1031 int|
|ALE|node: 1611 ale|
|AD 0-7|ab0-7|
|A 8-13|ab8-13|
|/RD|node: 2428 rd|
|/WR|node: 2087 wr|
|/RES|node: 1934 res|
|Internal Buses||
|DB 0-7|_io_db0-7|
|PD 0-7|_db0-7|
|OB 0-7|spr_d0-7|
|/PA 0-13|/_ab0-13|
|Clocks||
|/CLK|node: 245 /clk0_int|
|CLK|node: 218 clk0_int|
|/PCLK|node: 58 pclk1|
|PCLK|node: 106 pclk0|
|Registers||
|RES|node: 170 _res|
|RC|node: 128 _res2|
|R/W|node: 79 _io_rw|
|RS 0-2|_io_ab0-2|
|/DBE|node: 77 _io_ce|
|/RD|node: 31 _io_rw_buf|
|/WR|node: 13 _io_dbe|
|/W6/1|node: 255 /w2006a|
|/W6/2|node: 244 /w2006b|
|/W5/1|node: 297 /w2005a|
|/W5/2|node: 291 /w2005b|
|/R7|node: 387 /r2007|
|/W7|node: 414 /w2007|
|/W4|node: 341 /w2004|
|/W3|node: 463 /w2003|
|/R2|node: 205 /r2002|
|/W1|node: 481 /w2001|
|/W0|node: 487 /w2000|
|/R4|node: 83 /r2004|
|I1/32|node: 1277 addr_inc_out|
|OBSEL|node: 1182 /spr_pat_out|
|BGSEL|node: 1177 /bkg_pat_out|
|O8/16|node: 1058 spr_size_out|
|/SLAVE|node: 23 slave_mode|
|VBL|node: 1125 enable_nmi|
|B/W|node: 1111 pal_mono|
|/BGCLIP|node: 1161 bkg_clip_out|
|/OBCLIP|node: 1153 spr_clip_out|
|BGE|node: 1280 bkg_enable_out|
|BLACK|node: 1133 rendering_disabled|
|OBE|node: 1267 spr_enable_out|
|/TR|node: 1184 /emph0_out|
|/TG|node: 1168 /emph1_out|
|/TB|node: 1128 /emph2_out|
|H/V FSM||
|H 0-8|hpos0-8|
|V 0-8|vpos0-8|
|S/EV|node: 1070 ++hpos_eq_65_and_rendering|
|CLIP_O|node: 1114 ++in_clip_area_and_clipping_spr|
|CLIP_B|node: 1117 ++in_clip_area_and_clipping_bg|
|0/HPOS|node: 1096 ++hpos_eq_339_and_rendering|
|/EVAL|node: 708 ++/hpos_eq_63_255_or_339_and_rendering|
|E/EV|node: 1009 ++hpos_eq_255_and_rendering|
|I/OAM2|node: 357 ++hpos_lt_64_and_rendering|
|PAR/O|node: 328 ++hpos_eq_256_to_319_and_rendering|
|/VIS|node: 283 ++/in_visible_frame_and_rendering|
|#F/NT|node: 1051 ++/hpos_mod_8_eq_0_or_1_and_rendering|
|F/TB|node: 1091 ++hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_6_or_7_and_rendering|
|F/TA|node: 1093 ++hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_4_or_5_and_rendering|
|F/AT|node: 1162 +hpos_eq_0-255_or_320-335_and_hpos_mod_8_eq_2_or_3_and_rendering|
|/FO|node: 1090 ++hpos_eq_0-255_or_320-335_and_rendering|
|BPORCH|node: 1002 +hpos_eq_270_to_327|
|SC/CNT|node: 1003 +hpos_eq_279_to_303_and_rendering_enabled|
|/HB|node: 1007 +hpos_eq_279_to_303|
|BURST|node: 547 in_range_3|
|SYNC|node: 915 in_range_2|
|/PICTURE|node: 949 ++/in_draw_range|
|RESCL|node: 604 vbl_clear_flags|
|VSYNC|node: 1079 +/in_range_1|
|/VSET|node: 1015 +/vpos_eq_241_2|
|VB|node: 1100 in_vblank|
|BLNK|node: 1030 not_rendering|
|BLNK (Outside)|node: 203 not_rendering_2|
|INT|node: 988 _int|
|H0'|node: 614 +hpos0|
|H0''|node: 282 ++hpos0|
|H0'' (2)|node: 589 ++hpos0_2|
|/H1'|node: 1006 +/hpos1|
|H1''|node: 1179 ++hpos1|
|/H2'|node: 638 +/hpos2|
|H2''|node: 1173 ++hpos2|
|H3''|node: 1167 ++hpos3|
|H4''|node: 1159 ++hpos4|
|H5''|node: 1109 ++hpos5|
|EvenOddOut|node: 802 skip_dot|
|HC|node: 171 +move_to_next_line|
|VC|node: 172 +clear_vpos_next|
|V_IN|node: 116 hpos_eq_340|
|MPX||
|/ZCOL0|node: 1680 spr_out_/pat0|
|/ZCOL1|node: 1674 spr_out_/pat1|
|ZCOL2|node: 1520 spr_out_attr0|
|ZCOL3|node: 1525 spr_out_attr1|
|/ZPRIO|node: 1528 spr_out_prio|
|/SPR0HIT|node: 1349 /spr_slot_0_opaque|
|EXT_In 0-3|exp_in0-3|
|/EXT_Out 0-3|/exp_out0-3|
|CRAM||
|#CB/DB|node: 1207 /read_2007_output_palette|
|/BW|node: 1350 (++in_draw_range_or_read_2007_output_palette)_and_/pal_mono|
|#DB/CB|node: 1276 /(ab_in_palette_range_and_not_rendering_and_+write_2007_ended)_2|
|PAL 0-4|pal_ptr0-4|
|/CC 0-3|node: 811 +/pal_d0_out; node: 872 +/pal_d1_out; node: 810 +/pal_d2_out; node: 812 +/pal_d3_out|
|/LL 0-1|node: 1216 +++/pal_d4_out; node: 1157 +++/pal_d5_out|
|OAM Eval||
|OMSTEP|node: 288 spr_addr_load_next_value|
|OMOUT|node: 179 /spr_load_next_value_or_write_2003_reg|
|ORES|node: 743 clear_spr_ptr|
|OSTEP|node: 735 inc_spr_ptr|
|OVZ|node: 1052 sprite_in_range|
|OMFG|node: 118 /spr_eval_copy_sprite|
|OMV|node: 455 spr_addr_7_carry_out|
|TMV'|node: 608 +spr_ptr4_carry_out|
|COPY_STEP|node: 1077 ++hpos0_2_and_pclk_1|
|DO_COPY|node: 1047 copy_sprite_to_sec_oam|
|COPY_OVF|node: 5853 do_copy_sprite_to_sec_oam|
|OAM||
|/SPR0_EV|node: 1105 /sprite_0_on_cur_scanline|
|OFETCH|node: 157 delayed_write_2004_value|
|SPR_OV|node: 272 end_of_oam_or_sec_oam_overflow|
|OAMCTR2|node: 300 spr_ptr_overflow|
|/OAM 0-7|node: 57 /spr_addr0_out; etc|
|OAM8|node: 37 spr_ptr5|
|PD/FIFO|node: 1098 +sprite_in_range_reg|
|OV 0-7|+vpos_minus_spr_d0-7|
|/WE|node: 334 oam_write_disable|
|Object FIFO||
|/SH2|node: 1322 /spr_loadFlag|
|/SH3|node: 1311 /spr_loadX|
|/SH5|node: 1337 /spr_loadL|
|/SH7|node: 1329 /spr_loadH|
|#0/H|node: 1681 +++++/hpos_eq_339_and_rendering|
|DataReader||
|CLPO|node: 1283 ++++/do_sprite_render_ops|
|/CLPB|node: 1281 +++do_bg_render_ops|
|BGC 0-3|pixel_color0-3|
|FH 0-2|finex0-2|
|FV 0-2|node: 2341 vramaddr_t12; node: 2340 vramaddr_t13; node: 2339 vramaddr_t14|
|NTV|node: 2342 vramaddr_t11|
|NTH|node: 2343 vramaddr_t10|
|TV 0-4|vramaddr_t5-9|
|TH 0-4|vramaddr_t0-4|
|THO 0-4|node: 1558 vramaddr_v0_out; etc|
|/THO 0-4|vramaddr_/v0-4|
|TVO 0-4|node: 2268 vramaddr_v5_out; etc|
|/TVO 0-4|vramaddr_/v5-9|
|FVO 0-2|node: 2272 vramaddr_v13_out (FVO1)|
|/FVO 0-2|node: 1872 vramaddr_/v12; etc|
|/PAD 0-12|node: 9046 +++/vpos_minus_spr_d0_buf_after_ev_y_flip_if_fetching_sprites_else_+vramaddr_/v12 (:crazy:); etc|
|VRAM Controller||
|RD|node: 1960 _rd|
|WR|node: 2048 _wr|
|/ALE|node: 1593 /_ale|
|TSTEP|node: 2266 reading_or_writing_2007|
|DB/PAR|node: 1275 write_2007_ended_2|
|PD/RB|node: 2325 read_2007_ended_2|
|TH/MUX|node: 1266 ab_in_palette_range_and_not_rendering_2|
|XRB|node: 2327 read_2007_output_vrambuf_2|
|VideoOut||
|L0|node: 751 vid_sync_l|
|L1|node: 4941 vid_burst_l|
|L2|node: 5538 vid_luma0_l|
|L3|node: 787 vid_sync_h; node: 5835 vid_luma1_l|
|L4|node: 4942 vid_burst_h|
|L5|node: 5912 vid_luma2_l|
|L6|node: 5556 vid_luma0_h|
|L7|node: 5842 vid_luma1_h|
|L8|node: 5805 vid_luma3_l|
|L9|node: 5925 vid_luma2_h; node: 5784 vid_luma3_h|
|TINT|node: 954 vid_emph|
|PBLACK|node: 542 +++pal_d3-1_eq_7|
|/PR|node: 193 chroma_ring5|
|/PB|node: 195 chroma_ring3|
|/PG|node: 197 chroma_ring1|
|/PZ|node: 381 chroma_waveform_out|
|/POUT|node: 918 /(+in_draw_range_and_++/pal_d3-1_eq_7)|
