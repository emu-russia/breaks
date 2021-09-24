"""
	Basic logic primitives used in N-MOS chips.

"""

def NOT(a):
	return ~a & 1

def NOR(a, b):
	return (~(a | b)) & 1

def NAND(a, b):
	return (~(a & b)) & 1

"""
	The real latch works as a pair of N-MOS transistors.

	The first transistor is the tri-state (`d`). It opens the input to the gate of the second transistor,
	where the value is stored.
	After closing the tri-state the value is stored as a `floating` value on the gate of the second transistor.

	The output from the second transistor is the DLatch output.
	Since the second transistor is essentially an inverter, the output will also be in inverse logic (`/out`)

	Circuit:

                o  (Vdd)
                |
                Z  (N-Channel Depletion MOSFET)
                |
        d       .--------------> /out
        _       |
       | |    --
 in ---   ---|
              --
                |
                =  (Vss)

	This kind of latch is also called `transparent D-latch`.

"""
class DLatch:
	g = 0

	def set(self, a, d):
		if d:
			self.g = a & 1

	def get(self):
		return NOT(self.g)
