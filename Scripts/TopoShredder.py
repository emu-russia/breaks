"""

	A script for slicing the topology/tran pictures into small pieces.

	I'm tired of doing it by hand every time.

"""

# https://stackoverflow.com/questions/5953373/how-to-split-image-into-multiple-pieces-in-python

import os
import sys
from PIL import Image

# DecompressionBombWarning: Image size (166166000 pixels) exceeds limit of 89478485 pixels, could be decompression bomb DOS attack.
Image.MAX_IMAGE_PIXELS = None

def CropImage (src, dest, rect):
	im = Image.open(src + ".jpg")
	a = im.crop([rect[0], rect[1], rect[0]+rect[2], rect[1]+rect[3]])
	a.save("%s.jpg" % dest, quality=85)

def PrintHelp ():
	print ("Use: python3 TopoShredder <-apu|-ppu|-6502|-all>")

def ApuShredder (FusedTopo):
	imgstore = "../BreakingNESWiki/imgstore/apu/"
	# DPCM chan
	CropImage (FusedTopo, imgstore + "dpcm_addr_in_tran", [5001, 9557, 219, 1291] )
	CropImage (FusedTopo, imgstore + "dpcm_address_high_tran", [5210, 9878, 565, 1153] )
	CropImage (FusedTopo, imgstore + "dpcm_address_low_tran", [5208, 8581, 567, 1300] )
	CropImage (FusedTopo, imgstore + "dpcm_control_reg_tran", [4976, 8545, 213, 1015] )
	CropImage (FusedTopo, imgstore + "dpcm_debug_tran", [1190, 5219, 284, 1238] )
	CropImage (FusedTopo, imgstore + "dpcm_decoder_tran", [4030, 9256, 973, 811] )
	CropImage (FusedTopo, imgstore + "dpcm_dma_control_tran", [4654, 7304, 556, 510] )
	CropImage (FusedTopo, imgstore + "dpcm_enable_control_tran", [3860, 7476, 588, 456] )
	CropImage (FusedTopo, imgstore + "dpcm_freq_counter_lfsr_tran", [4466, 7959, 536, 1264] )
	CropImage (FusedTopo, imgstore + "dpcm_int_control_tran", [3478, 7414, 551, 622] )
	CropImage (FusedTopo, imgstore + "dpcm_output_tran", [1635, 5193, 621, 1200] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_bit_counter_tran", [3642, 8123, 563, 477] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_buffer_control_tran", [4413, 6798, 795, 546] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_buffer_tran", [4627, 5420, 569, 1396] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_counter_control_tran1", [4258, 7447, 545, 393] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_counter_control_tran2", [4200, 8013, 373, 347] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_counter_in_tran", [4402, 5533, 203, 1296] )
	CropImage (FusedTopo, imgstore + "dpcm_sample_counter_tran", [3863, 5516, 543, 1952] )
	CropImage (FusedTopo, imgstore + "DMC_A15", [5756, 11015, 366, 170] )
	# Length counters
	CropImage (FusedTopo, imgstore + "length_counter_control_tran", [3450, 9533, 554, 327] )
	CropImage (FusedTopo, imgstore + "length_counter_tran", [3469, 9887, 584, 1301] )
	CropImage (FusedTopo, imgstore + "length_decoder_tran", [4174, 10011, 810, 1339] )
	# Noise chan
	CropImage (FusedTopo, imgstore + "noise_debug_tran", [1173, 8757, 274, 697] )
	CropImage (FusedTopo, imgstore + "noise_decoder_tran", [3459, 8618, 768, 798] )
	CropImage (FusedTopo, imgstore + "noise_envelope_control_tran", [1681, 8050, 788, 605] )
	CropImage (FusedTopo, imgstore + "noise_envelope_counter_tran", [1871, 8665, 591, 652] )
	CropImage (FusedTopo, imgstore + "noise_envelope_rate_counter_tran", [1679, 7372, 751, 682] )
	CropImage (FusedTopo, imgstore + "noise_feedback_tran", [2700, 7132, 346, 507] )
	CropImage (FusedTopo, imgstore + "noise_freq_control_tran", [3063, 9173, 512, 259] )
	CropImage (FusedTopo, imgstore + "noise_freq_in_tran", [4232, 8649, 208, 663] )
	CropImage (FusedTopo, imgstore + "noise_freq_lfsr_tran", [3023, 7705, 456, 1467] )
	CropImage (FusedTopo, imgstore + "noise_output_tran", [1629, 8514, 295, 783] )
	CropImage (FusedTopo, imgstore + "noise_random_lfsr_tran", [2394, 7634, 631, 1715] )
	# Pads
	CropImage (FusedTopo, imgstore + "out_tran", [7882, 1426, 334, 568] )
	#CropImage (FusedTopo, imgstore + "pad_a", [11240, 4100, 1658, 5412] )
	CropImage (FusedTopo, imgstore + "pad_clk", [11890, 8649, 987, 849] )
	#CropImage (FusedTopo, imgstore + "pad_d", [11240, 4100, 1658, 5412] )
	CropImage (FusedTopo, imgstore + "pad_dbg", [12027, 7710, 851, 868] )
	CropImage (FusedTopo, imgstore + "pad_in", [10898, 111, 952, 1099] )
	CropImage (FusedTopo, imgstore + "pad_irq", [11811, 3162, 1068, 947] )
	CropImage (FusedTopo, imgstore + "pad_m2", [11809, 4102, 1076, 1018] )
	CropImage (FusedTopo, imgstore + "pad_nmi", [11819, 2236, 1052, 948] )
	CropImage (FusedTopo, imgstore + "pad_out", [8120, 120, 943, 1102] )
	#CropImage (FusedTopo, imgstore + "pad_res", [11240, 4100, 1658, 5412] )
	#CropImage (FusedTopo, imgstore + "pad_rw", [11240, 4100, 1658, 5412] )
	# Core integration + SoftCLK
	CropImage (FusedTopo, imgstore + "6502_core_clock", [11240, 4100, 1658, 5412] )
	CropImage (FusedTopo, imgstore + "6502_core_pads_tran", [6859, 5636, 4446, 949] )
	CropImage (FusedTopo, imgstore + "aclk_gen_tran", [7866, 2012, 540, 1536] )
	CropImage (FusedTopo, imgstore + "apu_core_irq", [7279, 6244, 409, 343] )
	CropImage (FusedTopo, imgstore + "apu_core_irqnmi_logic1", [8549, 5691, 182, 291] )
	CropImage (FusedTopo, imgstore + "apu_core_irqnmi_logic2", [7716, 5658, 267, 324] )
	CropImage (FusedTopo, imgstore + "apu_core_nmi", [6854, 6223, 412, 282] )
	CropImage (FusedTopo, imgstore + "apu_core_phi_internal", [9660, 6075, 791, 397] )
	CropImage (FusedTopo, imgstore + "apu_core_phi1_ext", [7736, 6065, 294, 413] )
	CropImage (FusedTopo, imgstore + "apu_core_phi2_ext", [8734, 6077, 623, 373] )
	CropImage (FusedTopo, imgstore + "apu_core_rdy", [7994, 6217, 271, 265] )
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
	CropImage (FusedTopo, imgstore + "square_barrel_shifter_tran1", [5055, 1517, 297, 1771] )
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
	CropImage (FusedTopo, imgstore + "square_volume_envelope_tran", [6742, 1474, 764, 648] )
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

"""
def PpuShredder (FusedTopo):
	# H/V
	CropImage (FusedTopo, imgstore + "h_counter_output", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "H_trans", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "CARRYH", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "CARRYV", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "even_odd_tran", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "h0_dash_dash_tran", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "hv_counters_control", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "hv_fporch", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "hv_fsm_horz", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "hv_fsm_int", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "hv_fsm_vert", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "HV_stage", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "V_trans", [116, 5237, 903, 2106] )
	# CRAM
	CropImage (FusedTopo, imgstore + "color_buffer_bit", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "cb_control", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "cbout_cc", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "cbout_ll", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "cram_decoder", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "cram_precharge", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "cram_col_outputs", [116, 5237, 903, 2106] )
	# Regs
	CropImage (FusedTopo, imgstore + "clp_tran", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "control_regs", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "r4_enabler_tran", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "reg_select", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "rw_decoder", [116, 5237, 903, 2106] )
	# OAM
	CropImage (FusedTopo, imgstore + "oam_address_tran", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "oam_buffer_bit", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "oam_buffer_control", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "oam_buffer_readback", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "oam_col_decoder", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "oam_row_decoder", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "oam_row_outputs1", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "oam_row_outputs2", [116, 5237, 903, 2106] )
	# OAM Eval
	CropImage (FusedTopo, imgstore + "oam_cmpr", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "oam_counters_control", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "oam_eval_control", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "oam_index_counter", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "oam_index_counter_control", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "oam2_index_counter", [116, 5237, 903, 2106] )
	# FIFO
	CropImage (FusedTopo, imgstore + "fifo_attr", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "fifo_counter", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "fifo_counter_control", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "fifo_prio0", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "fifo_prio1", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "fifo_prio2", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "fifo_prio3", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "fifo_prio4", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "fifo_sr", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "hinv", [116, 5237, 903, 2106] )
	# Data Reader
	CropImage (FusedTopo, imgstore + "patgen_high", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "patgen_vinv", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgc0", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgc1", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgc2", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgc3", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgcol_control_left", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgcol_control_right", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_dataread_bgcol_out", [116, 5237, 903, 2106] )
	# SCCX
	CropImage (FusedTopo, imgstore + "ppu_dualregs_fh", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_dualregs_fv", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_dualregs_nt", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_dualregs_th", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_dualregs_tv", [116, 5237, 903, 2106] )
	# PAR
	CropImage (FusedTopo, imgstore + "ppu_par_control", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_par_counters_control_bot", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_par_counters_control_top", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_par_counters_fv", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_par_counters_nt", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_par_counters_th", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_par_counters_tv", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_par_high", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_par_low", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "tho_latches_tran", [116, 5237, 903, 2106] )
	# Misc
	CropImage (FusedTopo, imgstore + "pclk", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "mux", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "ppu_readbuffer", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "vram_control_tran", [116, 5237, 903, 2106] )
	# VideOut
	CropImage (FusedTopo, imgstore + "vout_dac", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "vout_emphasis", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "vout_level_select", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "vout_phase_decoder", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "vout_phase_shifter", [116, 5237, 903, 2106] )
	# Pads etc.
	CropImage (FusedTopo, imgstore + "clk", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_a", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_ad", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_ale", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_clk", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_d", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_dbe", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_ext", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_int", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_rd", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_res", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_rs", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_rw", [116, 5237, 903, 2106] )
	CropImage (FusedTopo, imgstore + "pad_wr", [116, 5237, 903, 2106] )
"""

def PpuShredder (FusedTopo):
	# TBD.
	return

def CoreShredder (FusedTopo):
	# TBD.
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
