"""
	PPU implementation in Python.

	Both NTSC version of the chip (Ricoh 2C02) and PAL (Ricoh 2C07) are supported.

"""

from BaseLogic import *


"""
	One stage of H/V counters.

	https://github.com/emu-russia/breaks/blob/master/BreakingNESWiki_DeepL/PPU/hv.md

"""
class CounterStage:
	def __init__(self):
		self.ff = 0 		# This variable is used as a replacement for the hybrid FF built on MUX
		self.latch = DLatch()		

	def sim(self, nCarry, PCLK, CLR, RES):
		self.ff = MUX(PCLK, NOR(NOT(self.ff), RES), NOR(self.latch.get(), CLR))
		self.latch.set (MUX(nCarry, NOT(self.ff), self.ff), NOT(PCLK))
		out = NOR(NOT(self.ff), RES)
		nCarryOut = NOR (NOT(self.ff), NOT(nCarry))
		return [ out, nCarryOut ]

	def get(self):
		return self.ff

	def dump(self):
		print ("ff, latch: ", self.ff, self.latch.get())


"""
	Implementation of a full counter (H or V).

	The `bits` constructor parameter specifies the bits of the counter.

"""
class HVCounter:
	def __init__(self, bits):
		self.stages = [CounterStage() for i in range(bits)]

	def sim(self, nCarry, PCLK, CLR, RES):
		for s in self.stages:
			nCarry = s.sim(nCarry, PCLK, CLR, RES) [1]

	def get(self):
		val = 0
		for s in reversed(self.stages): 		# The counter stages must be enumerated backwards, so that the msb is shifted to the left.
			val <<= 1
			val |= s.get()
		return val

	def dump(self):
		print ("val: ", self.get(), ", bits: ", end='')
		for s in reversed(self.stages): 		# The counter stages must be enumerated backwards, so that the msb is shifted to the left.
			print (s.get(), end='')
		print(" ")


"""
	Pythonized PPU (nothing here yet, we need more circuits to get something rolling)

"""
class PPU:
	pass
