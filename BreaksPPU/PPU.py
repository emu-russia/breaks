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


"""
	H PLA.

	Essentially every PLA output is a big multi-input NOR, but we take a different
	approach instead, so that the PLA matrix is comparable to the chip image.

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

"""
class HV_FSM:
	def __init__(self):
		return

	def sim(self):
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
