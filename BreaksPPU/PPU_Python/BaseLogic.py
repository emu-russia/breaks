"""
	Basic logic primitives used in N-MOS chips.

	Combinational primitives are implemented using ordinary methods.

	Sequential primitives are implemented using classes.

"""

"""
	The simplest element, implemented with a single N-MOS FET.

	Circuit:

                   o (Vdd)
                   |
             in    Z (N-Channel Depletion MOSFET)
             --    |
            |  |   |
 (Vss)  ||--    ---.---> /out

"""
def NOT(a):
	return ~a & 1


"""
	2-nor

	Circuit:

                   o (Vdd)
                   |
             a     Z    b
             --    |    --
            |  |   |   |  |
 (Vss)  ||--    ---.---    --|| (Vss)
                   |
                    ---> /out


"""
def NOR(a, b):
	return (~(a | b)) & 1

def NOR3(a, b, c):
	return (~(a | b | c)) & 1


"""
	2-nand

	Circuit:

                          o (Vdd)
                          |
             a      b     Z (N-Channel Depletion MOSFET)
             --     --    |
            |  |   |  |   |
 (Vss)  ||--    ---    ---.---> /out

"""
def NAND(a, b):
	return (~(a & b)) & 1

def AND(a, b):
	return NOT(NAND(a, b))


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

	This kind of latch is also called `transparent` or `static` D-latch.

"""
class DLatch:
	def __init__(self):
		self.g = 0;

	def set(self, a, d):
		if d:
			self.g = a & 1

	def get(self):
		return self.g

	def nget(self):
		return NOT(self.g)


"""
	The most tricky element, as it is difficult to identify at first glance.

	The peculiarity is that its output is usually not connected to the "drive" (Depleted FET), but is connected to various other elements indirectly.

	Example MUX:


        /sel
         ---   
        |   |  
 in0 ---     ---.
                |
         sel    |
         ---    |
        |   |   |
 in1 ---     ---.----->out

	The transistors used are essentially complementary tri-states. (The values on their gates can never be the same).

"""
def MUX(sel, in0, in1):
	if sel & 1 == 0:
		return in0 & 1
	else:
		return in1 & 1
