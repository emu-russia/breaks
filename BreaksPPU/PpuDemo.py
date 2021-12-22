"""
	Various experiments with PPU.

"""

from PPU import *
import time


def TestCounterStage():
	print ("TestCounterStage:")
	bit0 = CounterStage()

	res = bit0.sim(0, 0, 0, 1)
	print ("PCLK=0: out, carry_out", res[0], res[1])
	res = bit0.sim(0, 1, 0, 1)
	print ("PCLK=1: out, carry_out", res[0], res[1])

	res = bit0.sim(1, 0, 0, 1)
	print ("PCLK=0: out, carry_out", res[0], res[1])
	res = bit0.sim(1, 1, 0, 1)
	print ("PCLK=1: out, carry_out", res[0], res[1])

	print ("After reset:")
	print (" ")

	# Run 4 pixels (in PPU terms)

	carry = 1
	CLR = 0
	RES = 0

	for i in range(2):
		print("PCLK Cycle:", i)
		PCLK = 0
		res = bit0.sim(carry, PCLK, CLR, RES)
		print ("PCLK=0: out, carry_out", res[0], res[1])
		PCLK = 1
		res = bit0.sim(carry, PCLK, CLR, RES)
		print ("PCLK=1: out, carry_out", res[0], res[1])
	print (" ")


def TestCounter():
	print ("TestCounter:")
	cnt = HVCounter(2)

	carry = 1 			# Input carry for the very first bit
	CLR = 0
	RES = 0	

	for i in range(4):
		print("PCLK Cycle:", i)
		PCLK = 0
		cnt.sim (carry, PCLK, CLR, RES)
		PCLK = 1
		cnt.sim (carry, PCLK, CLR, RES)
		cnt.dump()
		print(" ")


def TestHDecoder(ntsc):
	print ("TestHDecoder:")
	pla = HDecoder(ntsc)
	hist = []

	# Simulate one full line (HCounter = 0-340) and print all active PLA outputs.
	for i in range(341):
		outs = pla.sim(i, 0, 0)
		hist.append(outs)
		print (i, ": ", end='')
		for n in range(len(outs)):
			if outs[n] != 0:
				print (f"{n}, ", end='')
		print (" ")

	# Now perform the transpose operation - list all the history of outputs and output at what values of `H` this or that output is active
	for i in range(pla.NumOuts):
		print (f"PLA Output {i}: ", end='')
		n = 0
		for h in hist:
			if h[i] == 1:
				print (f"{n}, ", end='')
			n = n + 1
		print (" ")


def TestVDecoder(ntsc):
	print ("TestVDecoder:")
	pla = VDecoder(ntsc)
	hist = []

	if ntsc:
		Vmax = 262
	else:
		Vmax = 312

	# Simulate one full field (VCounter = 0-Vmax) and print all active PLA outputs.
	for i in range(Vmax):
		outs = pla.sim(i)
		hist.append(outs)
		print (i, ": ", end='')
		for n in range(len(outs)):
			if outs[n] != 0:
				print (f"{n}, ", end='')
		print (" ")

	# Now perform the transpose operation - list all the history of outputs and output at what values of `V` this or that output is active
	for i in range(pla.NumOuts):
		print (f"PLA Output {i}: ", end='')
		n = 0
		for h in hist:
			if h[i] == 1:
				print (f"{n}, ", end='')
			n = n + 1
		print (" ")


def TestFSM(ntsc):
	print ("TestFSM:")

	# Create the parts necessary for the H/V FSM to work

	hcnt = HVCounter(9)
	vcnt = HVCounter(9)
	hpla = HDecoder(ntsc)
	vpla = VDecoder(ntsc)

	fsm = HV_FSM(ntsc)

	# Simulate reset
	# Required for cleaning the H/V counters. Everything else is independent of the RES signal. (Actually EVEN/ODD logic relies on the RES signal, but this can be ignored).

	RES = 1
	PCLK = 0

	for step in range(8):
		hcnt.sim(0, PCLK, 0, RES)
		vcnt.sim(0, PCLK, 0, RES)
		if PCLK:
			PCLK = 0
		else:
			PCLK = 1		

	RES = 0

	# Make dummy outputs from control registers $2000/$2001

	BLACK = 0
	n_OBCLIP = 1
	n_BGCLIP = 1

	# Perform the number of half-cycles required to simulate a full frame

	start_time = time.time()

	timeStamp = 0.0
	frames = 1

	if ntsc:
		maxSteps = 262 * 341 * 2 * frames
		stepMcs = 0.093
	else:
		maxSteps = 312 * 341 * 2 * frames
		stepMcs = 0.0935

	maxSteps = 2 * 341 * 2 		# DEBUG!!! Only first 2 visible lines

	for step in range(maxSteps):
		vctrl = fsm.GetVPosControls(BLACK)

		hpla_out = hpla.sim(hcnt.get(), vctrl['VB'], vctrl['BLNK'])
		vpla_out = vpla.sim(vcnt.get())

		V_IN = hpla_out[23]

		fsm.sim(PCLK, hcnt.get(), vcnt.get(), hpla_out, vpla_out, RES)

		print (f"H: {hcnt.get()}; ", end='')
		print (f"PCLK: {PCLK}; ", end='')
		fsm.dump(n_OBCLIP, n_BGCLIP, BLACK)

		hcnt.sim(1, PCLK, fsm.GetHC(), RES)
		vcnt.sim(V_IN, PCLK, fsm.GetVC(), RES)

		if PCLK:
			PCLK = 0
		else:
			PCLK = 1

		timeStamp += stepMcs

	end_time = time.time()
	time_elapsed = (end_time - start_time)
	print(f"Real time elapsed: {time_elapsed} seconds; PPU time: {timeStamp} mcs.")


if __name__ == '__main__':
	#TestCounterStage()
	#TestCounter()
	#TestHDecoder(ntsc=True)
	#TestVDecoder(ntsc=True)
	TestFSM(ntsc=True)
