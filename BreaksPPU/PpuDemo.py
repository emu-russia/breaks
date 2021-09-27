"""
	Various experiments with PPU.

"""

import os

from PPU import *


def TestCounterStage():
	print ("TestCounterStage:")
	bit0 = CounterStage()

	# Run 4 pixels (in PPU terms)

	not_carry = 1
	CLR = 0
	RES = 0

	for i in range(4):
		print("PCLK Cycle:", i)
		PCLK = 0
		res = bit0.sim(not_carry, PCLK, CLR, RES)
		bit0.dump()
		PCLK = 1
		res = bit0.sim(not_carry, PCLK, CLR, RES)
		bit0.dump()
	print (" ")


def TestCounter():
	print ("TestCounter:")
	cnt = HVCounter()

	not_carry = 1 				# Input carry for the very first bit
	CLR = 0
	RES = 0	

	for i in range(4):
		PCLK = 0
		cnt.sim (not_carry, PCLK, CLR, RES)
		PCLK = 1
		cnt.sim (not_carry, PCLK, CLR, RES)
		cnt.dump()
		print(" ")

if __name__ == '__main__':
	TestCounterStage()
	TestCounter()
