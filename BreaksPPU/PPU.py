"""
	PPU implementation in Python.

	Both NTSC version of the chip (Ricoh 2C02) and PAL (Ricoh 2C07) are supported.

	All related documentation can be found here: https://github.com/emu-russia/breaks/tree/master/BreakingNESWiki_DeepL/PPU

"""

from BaseLogic import *


"""
	One stage of H/V counters.

"""
class CounterStage:
	def __init__(self):
		self.ff = 0 		# This variable is used as a replacement for the hybrid FF built on MUX
		self.latch = DLatch()

	def sim(self, Carry, PCLK, CLR, RES):
		self.ff = MUX(PCLK, NOR(NOT(self.ff), RES), NOR(self.latch.get(), CLR))
		self.latch.set (MUX(Carry, NOT(self.ff), self.ff), NOT(PCLK))
		out = NOR(NOT(self.ff), RES)
		CarryOut = NOR (NOT(self.ff), NOT(Carry))
		return [ out, CarryOut ]

	def get(self):
		return self.ff

	def dump(self):
		print ("ff, latch: ", self.ff, self.latch.get())


"""
	Implementation of a full counter (H or V).

	This does not simulate the propagation delay carry optimization for
	the low-order bits of the counter, as is done in the real circuit.

	The `bits` constructor parameter specifies the bits of the counter.

"""
class HVCounter:
	def __init__(self, bits):
		self.stages = [CounterStage() for i in range(bits)]

	def sim(self, Carry, PCLK, CLR, RES):
		for s in self.stages:
			Carry = s.sim(Carry, PCLK, CLR, RES) [1]

	def get(self):
		val = 0
		# The counter stages must be enumerated backwards, so that the msb is shifted to the left.
		for s in reversed(self.stages):
			val <<= 1
			val |= s.get()
		return val

	def dump(self):
		print ("val: ", self.get(), ", bits: ", end='')
		# The counter stages must be enumerated backwards, so that the msb is shifted to the left.
		for s in reversed(self.stages):
			print (s.get(), end='')
		print(" ")


# TODO: Make a generalized PLA simulation.


"""
	H PLA.

	Essentially every PLA output is a big multi-input NOR, but we take a different
	approach instead, so that the PLA matrix is comparable to the chip image.

	- VB: Active when the invisible part of the video signal is output (used only in H Decoder)
	- BLNK: Active when PPU rendering is disabled (by BLACK signal) or during VBlank

"""
class HDecoder:
	NumOuts = 24 		# Number of decoder outputs

	def __init__(self, ntsc):
		self.pla = [None] * 20
		if ntsc:
			self.pla[0]  = "001010101010000100000000"
			self.pla[1]  = "110001000100001001111111"
			self.pla[2]  = "111101101100000001111111"
			self.pla[3]  = "000000010000000000000000"
			self.pla[4]  = "110100101100000001011010"
			self.pla[5]  = "001001010000001000100101"
			self.pla[6]  = "111101000000001001110101"
			self.pla[7]  = "000000110000000000001010"
			self.pla[8]  = "011100000000001001100100"
			self.pla[9]  = "100001110000000000011011"
			self.pla[10] = "111101000000000000011111"
			self.pla[11] = "000000110000000001100000"
			self.pla[12] = "011001000001000010101100"
			self.pla[13] = "100000110000110001010011"
			self.pla[14] = "011000000001010000101011"
			self.pla[15] = "100001110000100011010100"
			self.pla[16] = "010000000000000001101011"
			self.pla[17] = "101001110000000000010100"
		else:
			self.pla[0]  = "001010101010000100100000"
			self.pla[1]  = "110001000100001001011111"
			self.pla[2]  = "111101101100000001111111"
			self.pla[3]  = "000000010000000000000000"
			self.pla[4]  = "110100101100000001111010"
			self.pla[5]  = "001001010000001000000101"
			self.pla[6]  = "111101000000001001110101"
			self.pla[7]  = "000000110000000000001010"
			self.pla[8]  = "011100000000001001101100"
			self.pla[9]  = "100001110000000000010011"
			self.pla[10] = "111101000000000001110111"
			self.pla[11] = "000000110000000000001000"
			self.pla[12] = "011001000001000011000110"
			self.pla[13] = "100000110000110000111001"
			self.pla[14] = "111000000001010001110101"
			self.pla[15] = "000001110000100010001010"
			self.pla[16] = "010000000000000001101011"
			self.pla[17] = "101001110000000000010100"
		# Common (VB & BLNK)
		self.pla[18] = "000010000010000000000000"
		self.pla[19] = "001001111111001100000000"			

	def sim(self, cnt, VB, BLNK):
		outs = [None] * self.NumOuts
		h = [None] * 9
		for n in range(9): 		# Get counter bits to speed up checking
			h[n] = (cnt >> n) & 1
		for i in range(self.NumOuts):
			# Initially, the output of a single PLA line is 1. A one-bit intersection will zero the output.
			out = 1
			for n in range(9):
				if self.pla[2*n][i] == '1' and h[8-n] != 0:
					out = 0
				if self.pla[2*n+1][i] == '1' and NOT(h[8-n]) != 0:
					out = 0
				if out == 0:
					break
			if self.pla[18][i] == '1' and VB != 0:
				out = 0
			if self.pla[19][i] == '1' and BLNK != 0:
				out = 0
			outs[i] = out
		return outs


"""
	V PLA.

	Essentially every PLA output is a big multi-input NOR, but we take a different
	approach instead, so that the PLA matrix is comparable to the chip image.

"""
class VDecoder:
	def __init__(self, ntsc):
		self.pla = [None] * 18
		if ntsc:
			self.pla[0]  = "000001000"
			self.pla[1]  = "001000011"
			self.pla[2]  = "001001011"
			self.pla[3]  = "110110100"
			self.pla[4]  = "001001011"
			self.pla[5]  = "110110100"
			self.pla[6]  = "001001011"
			self.pla[7]  = "110110100"
			self.pla[8]  = "001001011"
			self.pla[9]  = "110110100"
			self.pla[10] = "111111111"
			self.pla[11] = "000000000"
			self.pla[12] = "000111100"
			self.pla[13] = "111000011"
			self.pla[14] = "011111111"
			self.pla[15] = "100000000"
			self.pla[16] = "010001100"
			self.pla[17] = "101110011"
			self.NumOuts = 9
		else:
			self.pla[0]  = "0010010000"
			self.pla[1]  = "1100000111"
			self.pla[2]  = "1110010111"
			self.pla[3]  = "0001101000"
			self.pla[4]  = "1110010111"
			self.pla[5]  = "0001101000"
			self.pla[6]  = "1110010001"
			self.pla[7]  = "0001101110"
			self.pla[8]  = "0110010001"
			self.pla[9]  = "1001101110"
			self.pla[10] = "1011111110"
			self.pla[11] = "0100000001"
			self.pla[12] = "1011111001"
			self.pla[13] = "0100000110"
			self.pla[14] = "1111111001"
			self.pla[15] = "0000000110"
			self.pla[16] = "1001011000"
			self.pla[17] = "0110100111"
			self.NumOuts = 10

	def sim(self, cnt):
		outs = [None] * self.NumOuts
		v = [None] * 9
		for n in range(9): 		# Get counter bits to speed up checking
			v[n] = (cnt >> n) & 1
		for i in range(self.NumOuts):
			# Initially, the output of a single PLA line is 1. A one-bit intersection will zero the output.
			out = 1
			for n in range(9):
				if self.pla[2*n][i] == '1' and v[8-n] != 0:
					out = 0
				if self.pla[2*n+1][i] == '1' and NOT(v[8-n]) != 0:
					out = 0
				if out == 0:
					break
			outs[i] = out
		return outs


"""
	Implementation of the H/V state machine. This part is the main "brain" of the PPU, which controls all other parts.

	- n_OBCLIP ($2001[2]): To generate the CLIP_O control signal
	- n_BGCLIP ($2001[1]): To generate the CLIP_B control signal
	- BLACK ($2001[3] and $2001[4]): Active when PPU rendering is disabled
	- RES: Global reset signal (from /RES Pad)

	The simulation of FSM sequential circuits is separated from the acquisition of output signals, for convenience.

"""
class HV_FSM:
	def __init__(self, ntsc):
		self.ntsc = ntsc

		self.EvenOddFF_1 = 0
		self.EvenOddFF_2 = 0

		self.fp_latch1 = DLatch()
		self.fp_latch2 = DLatch()
		self.FPORCH_FF = 0

		self.sev_latch1 = DLatch()
		self.sev_latch2 = DLatch()
		self.clpo_latch1 = DLatch()
		self.clpo_latch2 = DLatch()
		self.clpb_latch1 = DLatch()
		self.clpb_latch2 = DLatch()
		self.hpos_latch1 = DLatch()
		self.hpos_latch2 = DLatch()
		self.eval_latch1 = DLatch()
		self.eval_latch2 = DLatch()
		self.eev_latch1 = DLatch()
		self.eev_latch2 = DLatch()
		self.oam_latch1 = DLatch()
		self.oam_latch2 = DLatch()
		self.paro_latch1 = DLatch()
		self.paro_latch2 = DLatch()
		self.nvis_latch1 = DLatch()
		self.nvis_latch2 = DLatch()
		self.fnt_latch1 = DLatch()
		self.fnt_latch2 = DLatch()
		self.ftb_latch1 = DLatch()
		self.ftb_latch2 = DLatch()
		self.fta_latch1 = DLatch()
		self.fta_latch2 = DLatch()
		self.fo_latch1 = DLatch()
		self.fo_latch2 = DLatch()
		self.fo_latch3 = DLatch()
		self.fat_latch1 = DLatch()

		self.bp_latch1 = DLatch()
		self.bp_latch2 = DLatch()
		self.hb_latch1 = DLatch()
		self.hb_latch2 = DLatch()
		self.cb_latch1 = DLatch()
		self.cb_latch2 = DLatch()
		self.sync_latch1 = DLatch()
		self.sync_latch2 = DLatch()
		self.BPORCH_FF = 0
		self.HBLANK_FF = 0
		self.BURST_FF = 0

		self.vsync_latch1 = DLatch()
		self.pic_latch1 = DLatch()
		self.pic_latch2 = DLatch()
		self.vset_latch1 = DLatch()
		self.vb_latch1 = DLatch()
		self.vb_latch2 = DLatch()
		self.blnk_latch1 = DLatch()
		self.vclr_latch1 = DLatch()
		self.vclr_latch2 = DLatch()
		self.VSYNC_FF = 0
		self.PICTURE_FF = 0
		self.VB_FF = 0
		self.BLNK_FF = 0

		self.ctrl_latch1 = DLatch()
		self.ctrl_latch2 = DLatch()

	def sim(self, PCLK, h, v, hpla_in, vpla_in, RES):
		self.fp_latch1.set (hpla_in[0], NOT(PCLK))
		self.fp_latch2.set (hpla_in[1], NOT(PCLK))
		self.FPORCH_FF = NOR (self.fp_latch2.get(), NOR(self.fp_latch1.get(), self.FPORCH_FF) )
		n_FPORCH = self.FPORCH_FF

		self.sev_latch1.set (hpla_in[2], NOT(PCLK))
		self.sev_latch2.set (self.sev_latch1.nget(), PCLK)
		self.clpo_latch1.set (hpla_in[3], NOT(PCLK))
		self.clpb_latch1.set (hpla_in[4], NOT(PCLK))
		clpnor = NOR(self.clpo_latch1.get(), self.clpb_latch1.nget())
		self.clpo_latch2.set (clpnor, PCLK)
		self.clpb_latch2.set (clpnor, PCLK)
		self.hpos_latch1.set (hpla_in[5], NOT(PCLK))
		self.hpos_latch2.set (self.hpos_latch1.nget(), PCLK)
		self.eev_latch1.set (hpla_in[7], NOT(PCLK))
		self.eev_latch2.set (self.eev_latch1.nget(), PCLK)
		self.eval_latch1.set (hpla_in[6], NOT(PCLK))
		self.eval_latch2.set ( NOR3(self.hpos_latch1.get(), self.eval_latch1.get(), self.eev_latch1.get()), PCLK)
		self.oam_latch1.set (hpla_in[8], NOT(PCLK))
		self.oam_latch2.set (self.oam_latch1.nget(), PCLK)
		self.paro_latch1.set (hpla_in[9], NOT(PCLK))
		self.paro_latch2.set (self.paro_latch1.nget(), PCLK)
		self.nvis_latch1.set (hpla_in[10], NOT(PCLK))
		self.nvis_latch2.set (self.nvis_latch1.nget(), PCLK)
		self.fnt_latch1.set (hpla_in[11], NOT(PCLK))
		self.fnt_latch2.set (self.fnt_latch1.nget(), PCLK)
		self.ftb_latch1.set (hpla_in[12], NOT(PCLK))
		self.ftb_latch2.set (self.ftb_latch1.nget(), PCLK)
		self.fta_latch1.set (hpla_in[13], NOT(PCLK))
		self.fta_latch2.set (self.fta_latch1.nget(), PCLK)
		self.fo_latch1.set (hpla_in[14], NOT(PCLK))
		self.fo_latch2.set (hpla_in[15], NOT(PCLK))
		fonor = NOR(self.fo_latch1.get(), self.fo_latch2.get())
		self.fo_latch3.set (fonor, PCLK)
		self.fat_latch1.set (hpla_in[16], NOT(PCLK))

		self.bp_latch1.set (hpla_in[17], NOT(PCLK))
		self.bp_latch2.set (hpla_in[18], NOT(PCLK))
		self.BPORCH_FF = NOR ( self.bp_latch1.get(), NOR(self.bp_latch2.get(), self.BPORCH_FF) )
		self.hb_latch1.set (hpla_in[19], NOT(PCLK))
		self.hb_latch2.set (hpla_in[20], NOT(PCLK))
		self.HBLANK_FF = NOR (self.hb_latch2.get(), NOR(self.hb_latch1.get(), self.HBLANK_FF) )
		self.cb_latch1.set (hpla_in[21], NOT(PCLK))
		self.cb_latch2.set (hpla_in[22], NOT(PCLK))
		self.BURST_FF = NOR (self.cb_latch2.get(), NOR(self.cb_latch1.get(), self.BURST_FF) )
		self.sync_latch1.set (self.BURST_FF, PCLK)
		self.sync_latch2.set (NOT(n_FPORCH), PCLK)

		n_HB = self.HBLANK_FF
		self.VSYNC_FF = NOR ( AND(n_HB, vpla_in[0]), NOR(AND(n_HB, vpla_in[1]), self.VSYNC_FF) )
		self.vsync_latch1.set (NOR(n_HB, self.VSYNC_FF), PCLK)
		BPORCH = self.BPORCH_FF
		self.PICTURE_FF = NOR ( AND(BPORCH, vpla_in[2]), NOR(AND(BPORCH, vpla_in[3]), self.PICTURE_FF) )
		self.pic_latch1.set (self.PICTURE_FF, PCLK)
		self.pic_latch2.set (BPORCH, PCLK)
		self.vset_latch1.set (vpla_in[4], NOT(PCLK))
		self.vb_latch1.set (vpla_in[5], NOT(PCLK))
		self.vb_latch2.set (vpla_in[6], NOT(PCLK))
		self.VB_FF = NOR ( self.vb_latch2.get(), NOR(self.vb_latch1.get(), self.VB_FF) )
		self.blnk_latch1.set (vpla_in[7], NOT(PCLK))
		self.BLNK_FF = NOR (self.blnk_latch1.get(), NOR(self.vb_latch2.get(), self.BLNK_FF) )
		self.vclr_latch1.set (vpla_in[8], NOT(PCLK))
		self.vclr_latch2.set (self.vclr_latch1.nget(), PCLK)

		if self.ntsc:
			V8 = (v >> 8) & 1
			self.EvenOddFF_1 = NOT ( NOT(MUX(V8, NOT(self.EvenOddFF_2), self.EvenOddFF_1)) )
			self.EvenOddFF_2 = NOR ( NOT(MUX(V8, self.EvenOddFF_2, self.EvenOddFF_1)), RES )
			RESCL = self.vclr_latch2.nget()
			EvenOddOut = NOR3 (self.EvenOddFF_2, NOT(hpla_in[5]), NOT(RESCL))
			self.ctrl_latch1.set (NOR(hpla_in[23], EvenOddOut), NOT(PCLK))
			self.ctrl_latch2.set (vpla_in[2], NOT(PCLK))
		else:
			self.ctrl_latch1.set (NOT(hpla_in[23]), NOT(PCLK))
			self.ctrl_latch2.set (vpla_in[8], NOT(PCLK))

	def GetHPosControls(self, n_OBCLIP, n_BGCLIP, BLACK):
		hctrl = {}
		hctrl['/FPORCH'] = self.FPORCH_FF
		hctrl['S/EV'] = self.sev_latch2.nget()
		hctrl['CLIP_O'] = NOR(n_OBCLIP, self.clpo_latch2.get())
		hctrl['CLIP_B'] = NOR(n_BGCLIP, self.clpb_latch2.get())
		hctrl['0/HPOS'] = self.hpos_latch2.nget()
		hctrl['EVAL'] = NOT(self.eval_latch2.nget())
		hctrl['E/EV'] = self.eev_latch2.nget()
		hctrl['I/OAM2'] = self.oam_latch2.nget()
		hctrl['PAR/O'] = self.paro_latch2.nget()
		hctrl['/VIS'] = NOT(self.nvis_latch2.nget())
		hctrl['F/NT'] = NOT(self.fnt_latch2.nget())
		hctrl['F/TB'] = NOR(self.ftb_latch2.get(), self.fo_latch3.get())
		hctrl['F/TA'] = NOR(self.fta_latch2.get(), self.fo_latch3.get())
		hctrl['/FO'] = self.fo_latch3.nget()
		hctrl['F/AT'] = NOR( NOR(self.fo_latch1.get(), self.fo_latch2.get()), self.fat_latch1.nget() )
		hctrl['BPORCH'] = self.BPORCH_FF;
		hctrl['SC/CNT'] = NOR(BLACK, NOT(self.HBLANK_FF))
		hctrl['/HB'] = self.HBLANK_FF
		VSYNC = self.vsync_latch1.get()
		hctrl['SYNC'] = NOR(self.sync_latch2.get(), VSYNC)
		hctrl['BURST'] = NOR(self.sync_latch1.get(), hctrl['SYNC'])
		return hctrl

	def GetVPosControls(self, BLACK):
		vctrl = {}
		vctrl['VSYNC'] = self.vsync_latch1.get()
		vctrl['PICTURE'] = NOT(NOR(self.pic_latch1.get(), self.pic_latch2.get()))
		vctrl['/VSET'] = self.vset_latch1.nget()
		vctrl['VB'] = NOT(self.VB_FF)
		vctrl['BLNK'] = NAND(NOT(self.BLNK_FF), NOT(BLACK))
		vctrl['RESCL'] = self.vclr_latch2.nget()
		return vctrl

	def GetHC(self):
		return self.ctrl_latch1.nget()

	def GetVC(self):
		return NOR (NOT(self.ctrl_latch1.nget()), self.ctrl_latch2.nget())

	def dump(self, n_OBCLIP, n_BGCLIP, BLACK):
		# The n_OBCLIP/n_BGCLIP/BLACK signals are involved in getting output values, so they are rooted here
		print (self.GetHPosControls(n_OBCLIP, n_BGCLIP, BLACK))
		# DEBUG: Disabled for now as unnecessary
		#print (self.GetVPosControls(BLACK))


"""
	Processing of a VBlank interrupt. Part of the H/V FSM.

	- n_VSET: "VBlank Set". VBlank period start event.
	- VCLR (RESCL): VBlank period end event.
	- VBL: $2000[7]
	- n_R2: Register $2002 read operation
	- n_DBE: Enable the CPU interface

"""
class VBlank:
	def sim(self, PCLK, n_VSET, VCLR, VBL, n_R2, n_DBE):
		return	


"""
	Pythonized PPU.

	- Instead of the real CLK, the PCLK is used for now.
	- Some of the control signals (like RES, counter clearing signals, etc.)
	  are preset to certain values so that the circuit does something

"""
class PPU:
	def __init__(self, ntsc):
		self.ntsc = ntsc
		self.hcnt = HVCounter(9)
		self.vcnt = HVCounter(9)
		self.hpla = HDecoder(ntsc)
		self.vpla = VDecoder(ntsc)

	def sim(self, CLK):
		CLK = 0
		RES = 0

		self.hcnt.sim (1, CLK, CLR, RES)
		self.vcnt.sim (1, CLK, CLR, RES)

		VB = 0
		BLNK = 0

		hplaOut = self.hpla.sim (self.hcnt.get(), VB, BLNK)
		vplaOut = self.vpla.sim (self.vcnt.get())
