"""

	A script for slicing the topology/tran pictures into small pieces.

	I'm tired of doing it by hand every time.

"""

# https://stackoverflow.com/questions/5953373/how-to-split-image-into-multiple-pieces-in-python

import os
import sys
from PIL import Image, ImageDraw

# DecompressionBombWarning: Image size (166166000 pixels) exceeds limit of 89478485 pixels, could be decompression bomb DOS attack.
Image.MAX_IMAGE_PIXELS = None

def CropImage (src, dest, rect):
	im = Image.open(src + ".jpg")
	a = im.crop([rect[0], rect[1], rect[0]+rect[2], rect[1]+rect[3]])
	a.save("%s.jpg" % dest, quality=85)

def CropRotImage (src, dest, rect, angle):
	im = Image.open(src + ".jpg")
	a = im.crop([rect[0], rect[1], rect[0]+rect[2], rect[1]+rect[3]])
	a = a.rotate(angle, expand=True)
	a.save("%s.jpg" % dest, quality=85)

def CropMaskImage (src, dest, rect, mask=[]):
	im = Image.open(src + ".jpg")
	a = im.crop([rect[0], rect[1], rect[0]+rect[2], rect[1]+rect[3]])
	draw = ImageDraw.Draw(a)
	for r in mask:
		ofsx = r[0]-rect[0]
		ofsy = r[1]-rect[1]
		draw.rectangle ((ofsx, ofsy, r[2]+ofsx, r[3]+ofsy), fill="#777777")
	a.save("%s.jpg" % dest, quality=85)		

def PrintHelp ():
	print ("Use: python3 TopoShredder.py <-apu|-ppu|-6502|-all>")

def ApuShredder (FusedTopo):
	imgstore = "../BreakingNESWiki/imgstore/apu/"
	# DPCM chan
	CropImage (FusedTopo, imgstore + "dpcm_addr_in_tran", [5003, 9555, 233, 1290] )
	CropImage (FusedTopo, imgstore + "dpcm_address_high_tran", [5197, 9880, 574, 1126] )
	CropImage (FusedTopo, imgstore + "dpcm_address_low_tran", [5183, 8581, 588, 1298] )
	CropImage (FusedTopo, imgstore + "dpcm_control_reg_tran", [4976, 8545, 213, 1015] )
	CropImage (FusedTopo, imgstore + "dpcm_debug_tran", [1190, 5219, 284, 1238] )
	CropImage (FusedTopo, imgstore + "dpcm_decoder_tran", [4030, 9256, 973, 811] )
	CropImage (FusedTopo, imgstore + "dpcm_dma_control_tran", [4654, 7304, 556, 510] )
	CropImage (FusedTopo, imgstore + "dpcm_enable_control_tran", [3860, 7476, 588, 456] )
	CropImage (FusedTopo, imgstore + "dpcm_freq_counter_lfsr_tran", [4466, 7959, 536, 1264] )
	CropImage (FusedTopo, imgstore + "dpcm_int_control_tran", [3478, 7414, 551, 622] )
	CropImage (FusedTopo, imgstore + "dpcm_output_tran", [1635, 5193, 621, 1200] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_bit_counter_tran", [3619, 8075, 959, 529] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_buffer_control_tran", [4413, 6798, 795, 546] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_buffer_tran", [4627, 5420, 569, 1396] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_counter_control_tran1", [4258, 7447, 545, 393] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_counter_control_tran2", [4200, 8013, 373, 347] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_counter_in_tran", [4395, 5535, 209, 1292] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_counter_tran", [3865, 5517, 568, 1952] )
	CropImage (FusedTopo, imgstore + "DMC_A15", [5745, 11016, 376, 161] )
	# Length counters
	CropImage (FusedTopo, imgstore + "length_counter_control_tran", [3450, 9533, 554, 327] )
	CropImage (FusedTopo, imgstore + "length_counter_tran", [3469, 9887, 584, 1301] )
	CropImage (FusedTopo, imgstore + "length_decoder_tran", [4156, 10056, 813, 1283] )
	# Noise chan
	CropImage (FusedTopo, imgstore + "noise_debug_tran", [1173, 8757, 274, 697] )
	CropImage (FusedTopo, imgstore + "noise_decoder_tran", [3448, 8619, 779, 782] )
	CropImage (FusedTopo, imgstore + "noise_envelope_control_tran", [1681, 8050, 788, 605] )
	CropImage (FusedTopo, imgstore + "noise_envelope_counter_tran", [1871, 8665, 591, 652] )
	CropImage (FusedTopo, imgstore + "noise_envelope_rate_counter_tran", [1679, 7372, 751, 682] )
	CropImage (FusedTopo, imgstore + "noise_feedback_tran", [2700, 7132, 346, 507] )
	CropImage (FusedTopo, imgstore + "noise_freq_control_tran", [3063, 9173, 512, 259] )
	CropImage (FusedTopo, imgstore + "noise_freq_in_tran", [4232, 8649, 208, 663] )
	CropImage (FusedTopo, imgstore + "noise_freq_lfsr_tran", [3024, 7707, 489, 1467] )
	CropImage (FusedTopo, imgstore + "noise_output_tran", [1629, 8514, 295, 783] )
	CropImage (FusedTopo, imgstore + "noise_random_lfsr_tran", [2394, 7634, 631, 1715] )
	# Pads
	CropImage (FusedTopo, imgstore + "out_tran", [7882, 1426, 334, 568] )
	CropImage (FusedTopo, imgstore + "pad_a", [2094, 125, 939, 1052] )
	CropImage (FusedTopo, imgstore + "pad_clk", [11890, 8649, 987, 849] )
	CropImage (FusedTopo, imgstore + "pad_d", [11852, 9579, 1017, 934] )
	CropImage (FusedTopo, imgstore + "pad_dbg", [12027, 7710, 851, 868] )
	CropImage (FusedTopo, imgstore + "pad_in", [10898, 111, 952, 1099] )
	CropImage (FusedTopo, imgstore + "pad_irq", [11811, 3162, 1068, 947] )
	CropImage (FusedTopo, imgstore + "pad_m2", [11809, 4102, 1076, 1018] )
	CropImage (FusedTopo, imgstore + "pad_nmi", [11819, 2236, 1052, 948] )
	CropImage (FusedTopo, imgstore + "pad_out", [8120, 120, 943, 1102] )
	CropImage (FusedTopo, imgstore + "pad_res", [3023, 120, 985, 1040] )
	CropImage (FusedTopo, imgstore + "pad_rw", [11837, 1325, 1034, 935] )
	# Core integration + SoftCLK
	CropRotImage (FusedTopo, imgstore + "div", [11765, 5887, 613, 1718], -90 )
	CropImage (FusedTopo, imgstore + "aclk_gen_tran", [7866, 2012, 540, 1536] )
	CropImage (FusedTopo, imgstore + "apu_core_irq", [7279, 6244, 409, 343] )
	CropImage (FusedTopo, imgstore + "apu_core_irqnmi_logic1", [8549, 5691, 182, 291] )
	CropImage (FusedTopo, imgstore + "apu_core_irqnmi_logic2", [7716, 5658, 267, 324] )
	CropImage (FusedTopo, imgstore + "apu_core_nmi", [6854, 6223, 412, 282] )
	CropImage (FusedTopo, imgstore + "apu_core_phi_internal", [9660, 6075, 791, 397] )
	CropImage (FusedTopo, imgstore + "apu_core_phi1_ext", [7736, 6065, 294, 413] )
	CropImage (FusedTopo, imgstore + "apu_core_phi2_ext", [8734, 6077, 623, 373] )
	CropImage (FusedTopo, imgstore + "apu_core_rdy", [7994, 6203, 268, 280] )
	CropImage (FusedTopo, imgstore + "apu_core_res", [8247, 6270, 535, 183] )
	CropImage (FusedTopo, imgstore + "apu_core_rw", [10983, 6265, 264, 287] )
	CropImage (FusedTopo, imgstore + "apu_core_so", [9351, 6118, 307, 364] )
	CropImage (FusedTopo, imgstore + "notdbg_res_tran", [12433, 6024, 406, 1626] )
	CropImage (FusedTopo, imgstore + "dbg_buf1", [11921, 5691, 499, 315] )
	CropImage (FusedTopo, imgstore + "dbg_not1", [8716, 5687, 108, 298] )
	CropImage (FusedTopo, imgstore + "lock_tran", [8302, 5640, 256, 344] )
	CropImage (FusedTopo, imgstore + "nDBGRD", [9200, 5680, 370, 296] )
	CropImage (FusedTopo, imgstore + "pdsel_tran", [6470, 9423, 919, 2200] )
	CropImage (FusedTopo, imgstore + "rd_tran", [11419, 5556, 175, 126] )
	CropImage (FusedTopo, imgstore + "reg_rw_decoder_tran", [6165, 6615, 465, 227] )
	CropImage (FusedTopo, imgstore + "reg_select_tran", [6483, 5033, 1347, 1279] )
	CropImage (FusedTopo, imgstore + "softclk_control_tran", [8358, 3526, 655, 1101] )
	CropImage (FusedTopo, imgstore + "softclk_counter_control_tran", [8259, 1480, 742, 555] )
	CropImage (FusedTopo, imgstore + "softclk_counter_tran", [8412, 2033, 570, 1700] )
	# Sprite DMA
	CropImage (FusedTopo, imgstore + "sprbuf_tran", [9434, 4910, 1163, 445] )
	CropImage (FusedTopo, imgstore + "sprdma_addr_hi_tran", [5207, 6818, 737, 672] )
	CropImage (FusedTopo, imgstore + "sprdma_addr_low_tran", [5215, 5496, 717, 1335] )
	CropImage (FusedTopo, imgstore + "sprdma_addr_mux_bit_tran", [5768, 8595, 338, 157] )
	CropImage (FusedTopo, imgstore + "sprdma_addr_mux_control_tran", [5550, 8401, 306, 178] )
	CropImage (FusedTopo, imgstore + "sprdma_control_tran", [5167, 7496, 607, 757] )
	# Square chan
	CropImage (FusedTopo, imgstore + "square_adder_tran", [5347, 1391, 783, 2099] )
	CropImage (FusedTopo, imgstore + "square_barrel_shifter_tran1", [5030, 1509, 321, 1780] )
	CropImage (FusedTopo, imgstore + "square_barrel_shifter_tran2", [5054, 3271, 411, 206] )
	CropImage (FusedTopo, imgstore + "square_duty_counter_tran", [6168, 3248, 552, 485] )
	CropImage (FusedTopo, imgstore + "square_duty_cycle_tran", [6750, 3277, 375, 764] )
	CropImage (FusedTopo, imgstore + "square_envelope_control_tran1", [6745, 2119, 903, 485] )
	CropImage (FusedTopo, imgstore + "square_envelope_control_tran2", [7131, 3272, 240, 275] )
	CropImage (FusedTopo, imgstore + "square_envelope_counter_tran", [6834, 2601, 812, 662] )
	CropImage (FusedTopo, imgstore + "square_freq_counter_control_tran", [6176, 3749, 397, 238] )
	CropImage (FusedTopo, imgstore + "square_freq_counter_tran", [6156, 1469, 561, 1768] )
	CropImage (FusedTopo, imgstore + "square_freq_in_tran", [4765, 1490, 300, 1769] )
	CropImage (FusedTopo, imgstore + "square_output_tran", [7137, 3283, 536, 706] )
	CropImage (FusedTopo, imgstore + "square_shift_in_tran", [4836, 3549, 164, 493] )
	CropImage (FusedTopo, imgstore + "square_sweep_control_tran1", [4837, 3256, 584, 887] )
	CropImage (FusedTopo, imgstore + "square_sweep_control_tran2", [5399, 3230, 688, 317] )
	CropImage (FusedTopo, imgstore + "square_sweep_counter_control_tran", [5611, 3351, 516, 217] )
	CropImage (FusedTopo, imgstore + "square_sweep_counter_tran", [5396, 3549, 759, 515] )
	CropImage (FusedTopo, imgstore + "square_decay_counter_tran", [6742, 1474, 764, 648] )
	CropImage (FusedTopo, imgstore + "square0_debug_tran", [8083, 3562, 275, 669] )
	CropImage (FusedTopo, imgstore + "square1_debug_tran", [1146, 3212, 505, 745] )
	# Triangle chan
	CropImage (FusedTopo, imgstore + "tri_debug_tran", [1172, 6610, 273, 706] )
	CropImage (FusedTopo, imgstore + "tri_freq_counter_control_tran", [3058, 7276, 588, 175] )
	CropImage (FusedTopo, imgstore + "tri_freq_counter_tran", [3042, 5508, 779, 1803] )
	CropImage (FusedTopo, imgstore + "tri_linear_counter_control_tran1", [2459, 6341, 592, 492] )
	CropImage (FusedTopo, imgstore + "tri_linear_counter_control_tran2", [2624, 7140, 259, 239] )
	CropImage (FusedTopo, imgstore + "tri_linear_counter_tran", [2285, 5200, 747, 1135] )
	CropImage (FusedTopo, imgstore + "tri_output_tran", [1646, 6454, 813, 818] )
	# DACs
	CropImage (FusedTopo, imgstore + "dac_other_tran", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "dac_square_tran", [6050, 1019, 726, 203] )
	# Other ACLK2
	CropImage (FusedTopo, imgstore + "ACLK2", [4451, 7154, 233, 184] )
	CropImage (FusedTopo, imgstore + "ACLK3", [4799, 3233, 200, 181] )
	CropImage (FusedTopo, imgstore + "ACLK4", [3050, 7710, 261, 187] )
	CropImage (FusedTopo, imgstore + "ACLK5", [7845, 2000, 234, 616] )
	# Common
	CropImage (FusedTopo, imgstore + "RegisterBit_tran", [5396, 3710, 184, 169] )
	CropImage (FusedTopo, imgstore + "CounterBit_tran", [5211, 9555, 565, 163] )
	CropImage (FusedTopo, imgstore + "DownCounterBit_tran", [3863, 5697, 544, 170] )
	CropImage (FusedTopo, imgstore + "RevCounterBit_tran", [1639, 5571, 609, 174] )

def PpuShredder (FusedTopo):
	imgstore = "../BreakingNESWiki/imgstore/ppu/"
	# H/V
	CropImage (FusedTopo, imgstore + "h_counter_output", [2273, 4208, 311, 718] )
	CropImage (FusedTopo, imgstore + "H_trans", [2513, 1585, 560, 1582] )
	CropImage (FusedTopo, imgstore + "CARRYH", [2507, 1580, 512, 305] )
	CropImage (FusedTopo, imgstore + "CARRYV", [3357, 1534, 322, 340] )
	CropRotImage (FusedTopo, imgstore + "even_odd_tran", [4235, 3550, 174, 664], -90 )
	CropImage (FusedTopo, imgstore + "h0_dash_dash_tran", [4623, 3741, 441, 183] )
	CropImage (FusedTopo, imgstore + "hv_counters_control", [2954, 3199, 1063, 457] )
	CropImage (FusedTopo, imgstore + "hv_fporch", [2251, 3968, 374, 421] )
	CropImage (FusedTopo, imgstore + "hv_fsm_horz", [2528, 4144, 929, 959] )
	CropImage (FusedTopo, imgstore + "hv_fsm_int", [3422, 4291, 353, 752] )
	CropImage (FusedTopo, imgstore + "hv_fsm_vert", [3743, 4214, 733, 815] )
	CropImage (FusedTopo, imgstore + "HV_stage", [3108, 2729, 560, 151] )
	CropImage (FusedTopo, imgstore + "V_trans", [3133, 1538, 547, 1632] )
	# CRAM
	CropImage (FusedTopo, imgstore + "color_buffer_bit", [2846, 5382, 349, 575] )
	CropImage (FusedTopo, imgstore + "cb_control", [4001, 4905, 358, 771] )
	CropImage (FusedTopo, imgstore + "cbout_cc", [2862, 5237, 191, 203] )
	CropImage (FusedTopo, imgstore + "cbout_ll", [2759, 5214, 705, 274] )
	CropImage (FusedTopo, imgstore + "cram_decoder", [4042, 5817, 434, 1175] )
	CropImage (FusedTopo, imgstore + "cram_precharge", [3637, 6735, 412, 184] )
	CropImage (FusedTopo, imgstore + "cram_col_outputs", [3636, 5948, 404, 181] )
	# Regs
	CropImage (FusedTopo, imgstore + "clp_tran", [5144, 5417, 1318, 252] )
	CropImage (FusedTopo, imgstore + "control_regs", [5119, 4861, 2073, 828] )
	CropImage (FusedTopo, imgstore + "r4_enabler_tran", [5712, 1387, 170, 331] )
	CropImage (FusedTopo, imgstore + "reg_select", [3748, 1824, 718, 1012] )
	CropImage (FusedTopo, imgstore + "rw_decoder", [5894, 1439, 538, 279] )
	# OAM
	CropImage (FusedTopo, imgstore + "oam_buffer_bit", [7739, 6326, 617, 392] )
	CropImage (FusedTopo, imgstore + "oam_buffer_control", [7713, 1572, 606, 726] )
	CropImage (FusedTopo, imgstore + "oam_buffer_readback", [7424, 3536, 187, 350] )
	CropImage (FusedTopo, imgstore + "oam_row_decoder", [8369, 4329, 3189, 471] )
	CropImage (FusedTopo, imgstore + "oam_col_decoder", [7171, 872, 1125, 528] )
	CropImage (FusedTopo, imgstore + "oam_col_outputs1", [8355, 2020, 349, 614] )
	CropImage (FusedTopo, imgstore + "oam_col_outputs2", [8356, 3852, 349, 477] )
	# Object Eval
	CropImage (FusedTopo, imgstore + "eval_cmpr", [5236, 3637, 1858, 917] )
	CropImage (FusedTopo, imgstore + "eval_counters_control", [5304, 2567, 829, 928] )
	CropImage (FusedTopo, imgstore + "eval_fsm", [5126, 4489, 1851, 414] )	
	CropImage (FusedTopo, imgstore + "eval_main_counter", [5389, 1779, 1687, 789] )
	CropImage (FusedTopo, imgstore + "eval_main_counter_control", [5199, 1831, 505, 1295] )
	CropImage (FusedTopo, imgstore + "eval_temp_counter", [6100, 2941, 1028, 580] )
	CropImage (FusedTopo, imgstore + "eval_oam_address_tran", [6042, 2588, 1038, 366] )	
	# FIFO
	CropImage (FusedTopo, imgstore + "fifo_attr", [5490, 8394, 563, 470] )
	CropImage (FusedTopo, imgstore + "fifo_counter", [5499, 9212, 557, 1263] )
	CropImage (FusedTopo, imgstore + "fifo_counter_control", [5507, 9081, 545, 315] )
	CropImage (FusedTopo, imgstore + "fifo_prio0", [5694, 6990, 320, 583] )
	CropImage (FusedTopo, imgstore + "fifo_prio1", [4336, 6988, 907, 585] )
	CropImage (FusedTopo, imgstore + "fifo_prio2", [3363, 7051, 887, 502] )
	CropImage (FusedTopo, imgstore + "fifo_prio3", [2335, 7018, 804, 555] )
	CropImage (FusedTopo, imgstore + "fifo_prio4", [1546, 7008, 771, 546] )
	CropImage (FusedTopo, imgstore + "fifo_sr", [5516, 7466, 519, 977] )
	CropImage (FusedTopo, imgstore + "hinv", [6055, 7541, 470, 1077] )
	# Data Reader
	CropImage (FusedTopo, imgstore + "par_high", [8551, 7163, 1889, 710] )
	CropImage (FusedTopo, imgstore + "par_vinv", [10345, 7167, 673, 689] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgc0", [10384, 9613, 641, 955] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgc1", [9737, 9836, 637, 728] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgc2", [9103, 9625, 637, 941] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgc3", [8476, 9622, 852, 939] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgcol_control_left", [8266, 9617, 675, 929] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgcol_control_right", [11022, 9970, 146, 394] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgcol_out", [7833, 9729, 566, 650] )
	# SCCX
	CropImage (FusedTopo, imgstore + "dualregs_fh", [7704, 9173, 705, 492] )
	CropImage (FusedTopo, imgstore + "dualregs_fv", [8424, 9159, 525, 458] )
	CropImage (FusedTopo, imgstore + "dualregs_nt", [8951, 9154, 385, 464] )
	CropImage (FusedTopo, imgstore + "dualregs_th", [10213, 9171, 829, 441] )
	CropImage (FusedTopo, imgstore + "dualregs_tv", [9368, 9178, 844, 436] )
	# Tile Counters + PPU Address MUX
	CropImage (FusedTopo, imgstore + "ppu_pamux_control", [8298, 7929, 409, 579] )
	CropImage (FusedTopo, imgstore + "ppu_tile_counters_control_bot", [7720, 8329, 1104, 882] )
	CropImage (FusedTopo, imgstore + "ppu_tile_counters_control_top", [7638, 7535, 628, 1013] )
	CropImage (FusedTopo, imgstore + "ppu_tile_counters_fv", [8384, 8417, 488, 787] )
	CropImage (FusedTopo, imgstore + "ppu_tile_counters_nt", [8880, 8398, 407, 796] )
	CropImage (FusedTopo, imgstore + "ppu_tile_counters_th", [10168, 8452, 881, 763] )
	CropImage (FusedTopo, imgstore + "ppu_tile_counters_tv", [9319, 8396, 900, 824] )
	CropImage (FusedTopo, imgstore + "ppu_pamux_high", [8705, 7807, 580, 649] )
	CropImage (FusedTopo, imgstore + "ppu_pamux_low", [9323, 7795, 1671, 679] )
	CropImage (FusedTopo, imgstore + "tho_latches_tran", [6168, 6631, 872, 290] )
	# Misc
	CropImage (FusedTopo, imgstore + "pclk", [1927, 2910, 609, 647] )
	CropImage (FusedTopo, imgstore + "mux", [4973, 5416, 1567, 1523] )
	CropImage (FusedTopo, imgstore + "readbuffer_tran", [6062, 8987, 722, 1413] )
	CropImage (FusedTopo, imgstore + "vram_control_tran", [5453, 10513, 1944, 920] )
	# Video Out
	CropImage (FusedTopo, imgstore + "vout_dac", [1419, 3230, 799, 1844] )
	CropImage (FusedTopo, imgstore + "vout_emphasis", [1678, 4974, 313, 399] )
	CropImage (FusedTopo, imgstore + "vout_level_select", [1986, 4891, 230, 478] )
	CropImage (FusedTopo, imgstore + "vout_phase_decoder", [1346, 2339, 1070, 572] )
	CropImage (FusedTopo, imgstore + "vout_phase_shifter", [1505, 1873, 1001, 594] )
	# Pads etc.
	CropImage (FusedTopo, imgstore + "clk", [1553, 2919, 463, 165] )
	CropImage (FusedTopo, imgstore + "pad_a", [4406, 10804, 797, 794] )
	CropImage (FusedTopo, imgstore + "pad_ad", [11729, 7888, 1006, 955] )
	CropImage (FusedTopo, imgstore + "pad_ale", [11700, 7076, 838, 804] )
	CropImage (FusedTopo, imgstore + "pad_clk", [246, 3410, 1071, 726] )
	CropImage (FusedTopo, imgstore + "pad_d", [11730, 4371, 1013, 958] )
	CropImage (FusedTopo, imgstore + "pad_dbe", [3052, 408, 767, 911] )
	CropImage (FusedTopo, imgstore + "pad_ext", [1707, 405, 969, 1019] )
	CropImage (FusedTopo, imgstore + "pad_int", [437, 4398, 825, 680] )
	CropImage (FusedTopo, imgstore + "pad_rd", [442, 9163, 824, 807] )
	CropImage (FusedTopo, imgstore + "pad_res", [258, 7384, 1042, 881] )
	CropImage (FusedTopo, imgstore + "pad_rs", [3886, 405, 741, 916] )
	CropImage (FusedTopo, imgstore + "pad_rw", [11732, 5328, 1004, 732] )
	CropImage (FusedTopo, imgstore + "pad_wr", [446, 8348, 815, 812] )

def CoreShredder (FusedTopo):
	imgstore = "../BreakingNESWiki/imgstore/6502/"
	# Top
	# TBD.
	# Bot
	CropMaskImage (FusedTopo, imgstore + "wr_latch_tran", [3792, 2573, 333, 339], [(3781,2534,290,159)] )
	CropMaskImage (FusedTopo, imgstore + "abl02_tran", [312, 2868, 594, 240], [(361,2851,453,55),(877,3023,60,70)] )
	CropMaskImage (FusedTopo, imgstore + "abl37_tran", [319, 3498, 553, 203] )
	CropMaskImage (FusedTopo, imgstore + "data_bit_tran", [3357, 2844, 1224, 284], [(3340,2875,61,63),(3919,2843,196,76),(3361,3101,147,72),(3564,3111,351,73),(4405,3081,149,75),(3361,2822,369,93)] )
	CropMaskImage (FusedTopo, imgstore + "abh_tran", [604, 4508, 302, 462] )
	# Bus Mpx
	CropImage (FusedTopo, imgstore + "busmpx1", [1059, 2892, 192, 222] )
	CropImage (FusedTopo, imgstore + "busmpx2", [3349, 2898, 222, 211] )
	CropImage (FusedTopo, imgstore + "busmpx3", [2613, 2885, 296, 317] )
	CropImage (FusedTopo, imgstore + "busmpx4", [2514, 3002, 169, 543] )
	CropImage (FusedTopo, imgstore + "busmpx5", [3222, 3658, 192, 794] )
	CropImage (FusedTopo, imgstore + "busmpx6", [727, 2845, 202, 543] )
	CropImage (FusedTopo, imgstore + "busmpx7", [2521, 2982, 131, 351] )
	CropImage (FusedTopo, imgstore + "busmpx8", [2347, 2914, 196, 218] )
	return

if __name__ == '__main__':
	if len( sys.argv ) <= 1:
		PrintHelp ()
	else:
		mode = sys.argv[1]
		if mode == "-apu":
			print ("TopoShredder Start")
			print ("APU:")
			ApuShredder ("../Docs/APU/2A03_Topo_Fused_2x")
			print ("TopoShredder End")
		elif mode == "-ppu":
			print ("TopoShredder Start")
			print ("PPU:")
			PpuShredder ("../Docs/PPU/2C02_Topo_Fused_2x")
			print ("TopoShredder End")
		elif mode == "-6502":
			print ("TopoShredder Start")
			print ("6502:")
			CoreShredder ("../Docs/6502/6502")
			print ("TopoShredder End")
		elif mode == "-all":
			print ("TopoShredder Start")
			print ("APU:")
			ApuShredder ("../Docs/APU/2A03_Topo_Fused_2x")
			print ("PPU:")
			PpuShredder ("../Docs/PPU/2C02_Topo_Fused_2x")
			print ("6502:")
			CoreShredder ("../Docs/6502/6502")
			print ("TopoShredder End")
		else:
			PrintHelp ()
