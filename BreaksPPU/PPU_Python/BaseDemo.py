"""
	Demonstration of the use of basic logic primitives.

"""

import os

from BaseLogic import *

if __name__ == '__main__':

	# Demonstration of basic logic primitives

	a = 0
	print ("not(0): ", NOT(a))

	a = 0
	b = 1
	print ("nor(0,1): ", NOR(a, b))

	a = 0
	b = 1
	print ("nand(0,1): ", NAND(a, b))

	# Attempting to set the latch when D=0. The value on the latch should not change (/out = 1)

	latch1 = DLatch()
	latch1.set (1, 0)
	print ("latch1: ", latch1.nget())

	# Attempting to set the latch when D=1. The value on the latch must update (1) and therefore the output must be /out = 0 (inverted latch value).

	latch1.set (1, 1)
	print ("latch1: ", latch1.nget())

	# Multiplexer demonstration

	out = MUX(1, 0, 1)
	print ("MUX out:", out)
