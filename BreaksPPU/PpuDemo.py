"""
	Various experiments with PPU.

"""

import os

from PPU import *

if __name__ == '__main__':
	bit0 = CounterStage()
	bit1 = CounterStage()

	# Run 4 pixels (in PPU terms)

	not_carry = 1
	CLR = 0
	RES = 0

	for i in range(4):
		print("PCLK Cycle:", i)
		res = bit0.sim(not_carry, 0, CLR, RES) 	 	# PCLK=0
		bit0.dump()
		res = bit0.sim(not_carry, 1, CLR, RES) 		# PCLK=1
		bit0.dump()
