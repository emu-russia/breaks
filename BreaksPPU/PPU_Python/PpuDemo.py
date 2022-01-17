"""
	Various experiments with PPU.

"""

from PPU import *
import time
import json


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


def BeginEvent(trace, tid, ts, name):
	entry = {}
	entry['pid'] = 1
	entry['tid'] = tid
	entry['ts'] = ts
	entry['ph'] = "B"
	entry['name'] = name
	trace.append(entry)	

def EndEvent(trace, tid, ts):
	entry = {}
	entry['pid'] = 1
	entry['tid'] = tid
	entry['ts'] = ts
	entry['ph'] = "E"
	trace.append(entry)

def TestFSM(ntsc):
	print ("TestFSM:")

	# Create the parts necessary for the H/V FSM to work

	hcnt = HVCounter(9)
	vcnt = HVCounter(9)
	hpla = HDecoder(ntsc)
	vpla = VDecoder(ntsc)

	fsm = HV_FSM(ntsc)

	# Make dummy outputs from control registers $2000/$2001

	BLACK = 0
	n_OBCLIP = 1
	n_BGCLIP = 1	

	# Simulate reset

	RES = 1
	PCLK = 0

	for step in range(8):
		vctrl = fsm.GetVPosControls(BLACK)
		hcnt.sim(0, PCLK, 0, RES)
		vcnt.sim(0, PCLK, 0, RES)
		hpla_out = hpla.sim(hcnt.get(), vctrl['VB'], vctrl['BLNK'])
		vpla_out = vpla.sim(vcnt.get())
		h = hcnt.get()
		v = vcnt.get()
		fsm.sim(PCLK, h, v, hpla_out, vpla_out, RES)
		if PCLK:
			PCLK = 0
		else:
			PCLK = 1		

	RES = 0

	# Configure simulation parameters

	start_time = time.time()

	timeStamp = 0.0
	frames = 1
	trace = []

	if ntsc:
		maxSteps = 262 * 341 * 2 * frames
		stepMcs = 0.093121696
	else:
		maxSteps = 312 * 341 * 2 * frames
		stepMcs = 0.093978913

	spamLog = False

	maxSteps = 2 * 341 * 2 		# DEBUG!!! Only first 2 visible lines

	BeginEvent (trace, 1, timeStamp, "TestFSM")

	prev_hctrl = fsm.GetHPosControls(n_OBCLIP, n_BGCLIP, BLACK)
	prev_vctrl = fsm.GetVPosControls(BLACK)

	# Some signals need to be "closed" after the simulation ends, so as not to leave open trace segments.

	closeScan = False
	closeVis = False
	closeBporch = False
	closeFnt = False

	# Some signals are already active from the beginning of the simulation when the previous H/V logic values have not yet changed.
	# NotYet logic is used to display these signals.

	Ioam2Nyet = True
	VisNyet = True
	FntYet = True
	FoNyet = True
	BporchNyet = True
	FporchNyet = True
	BurstNyet = True

	# Perform the number of half-cycles required

	for step in range(maxSteps):
		vctrl = fsm.GetVPosControls(BLACK)

		hpla_out = hpla.sim(hcnt.get(), vctrl['VB'], vctrl['BLNK'])
		vpla_out = vpla.sim(vcnt.get())

		V_IN = hpla_out[23]

		h = hcnt.get()
		v = vcnt.get()

		if h == 0 and PCLK == 0:
			if closeScan:
				EndEvent (trace, 1, timeStamp)
			BeginEvent (trace, 1, timeStamp, "ScanLine " + str(v))
			closeScan = True

		fsm.sim(PCLK, h, v, hpla_out, vpla_out, RES)

		hctrl = fsm.GetHPosControls(n_OBCLIP, n_BGCLIP, BLACK)
		vctrl = fsm.GetVPosControls(BLACK)

		if hctrl['S/EV'] == 1 and prev_hctrl['S/EV'] == 0:
			BeginEvent (trace, 3, timeStamp, "S/EV")
		if hctrl['S/EV'] == 0 and prev_hctrl['S/EV'] == 1:
			EndEvent (trace, 3, timeStamp)
		if hctrl['0/HPOS'] == 1 and prev_hctrl['0/HPOS'] == 0:
			BeginEvent (trace, 4, timeStamp, "0/HPOS")
		if hctrl['0/HPOS'] == 0 and prev_hctrl['0/HPOS'] == 1:
			EndEvent (trace, 4, timeStamp)
		if hctrl['EVAL'] == 0 and prev_hctrl['EVAL'] == 1:
			BeginEvent (trace, 5, timeStamp, "EVAL")
		if hctrl['EVAL'] == 1 and prev_hctrl['EVAL'] == 0:
			EndEvent (trace, 5, timeStamp)
		if hctrl['E/EV'] == 1 and prev_hctrl['E/EV'] == 0:
			BeginEvent (trace, 6, timeStamp, "E/EV")
		if hctrl['E/EV'] == 0 and prev_hctrl['E/EV'] == 1:
			EndEvent (trace, 6, timeStamp)
		if hctrl['I/OAM2'] == 1 and (prev_hctrl['I/OAM2'] == 0 or Ioam2Nyet):
			BeginEvent (trace, 7, timeStamp, "I/OAM2")
			Ioam2Nyet = False
		if hctrl['I/OAM2'] == 0 and prev_hctrl['I/OAM2'] == 1:
			EndEvent (trace, 7, timeStamp)
		if hctrl['PAR/O'] == 1 and prev_hctrl['PAR/O'] == 0:
			BeginEvent (trace, 8, timeStamp, "PAR/O")
		if hctrl['PAR/O'] == 0 and prev_hctrl['PAR/O'] == 1:
			EndEvent (trace, 8, timeStamp)
		if hctrl['/VIS'] == 1 and (prev_hctrl['/VIS'] == 0 or VisNyet):
			BeginEvent (trace, 9, timeStamp, "/VIS")
			closeVis = True
			VisNyet = False
		if hctrl['/VIS'] == 0 and prev_hctrl['/VIS'] == 1:
			EndEvent (trace, 9, timeStamp)
			closeVis = False

		if hctrl['F/NT'] == 0 and (prev_hctrl['F/NT'] == 1 or FntYet):
			BeginEvent (trace, 10, timeStamp, "F/NT")
			closeFnt = True
			FntYet = False
		if hctrl['F/NT'] == 1 and prev_hctrl['F/NT'] == 0:
			EndEvent (trace, 10, timeStamp)
			closeFnt = False
		if hctrl['F/AT'] == 1 and prev_hctrl['F/AT'] == 0:
			BeginEvent (trace, 11, timeStamp, "F/AT")
		if hctrl['F/AT'] == 0 and prev_hctrl['F/AT'] == 1:
			EndEvent (trace, 11, timeStamp)
		if hctrl['F/TA'] == 1 and prev_hctrl['F/TA'] == 0:
			BeginEvent (trace, 12, timeStamp, "F/TA")
		if hctrl['F/TA'] == 0 and prev_hctrl['F/TA'] == 1:
			EndEvent (trace, 12, timeStamp)
		if hctrl['F/TB'] == 1 and prev_hctrl['F/TB'] == 0:
			BeginEvent (trace, 13, timeStamp, "F/TB")
		if hctrl['F/TB'] == 0 and prev_hctrl['F/TB'] == 1:
			EndEvent (trace, 13, timeStamp)

		if hctrl['/FO'] == 1 and (prev_hctrl['/FO'] == 0 or FoNyet):
			BeginEvent (trace, 14, timeStamp, "/FO")
			FoNyet = False
		if hctrl['/FO'] == 0 and prev_hctrl['/FO'] == 1:
			EndEvent (trace, 14, timeStamp)
		if hctrl['BPORCH'] == 0 and (prev_hctrl['BPORCH'] == 1 or BporchNyet):
			BeginEvent (trace, 15, timeStamp, "BPORCH")
			closeBporch = True
			BporchNyet = False
		if hctrl['BPORCH'] == 1 and prev_hctrl['BPORCH'] == 0:
			EndEvent (trace, 15, timeStamp)
			closeBporch = False
		if hctrl['/FPORCH'] == 0 and (prev_hctrl['/FPORCH'] == 1 or FporchNyet):
			BeginEvent (trace, 16, timeStamp, "/FPORCH")
			FporchNyet = False
		if hctrl['/FPORCH'] == 1 and prev_hctrl['/FPORCH'] == 0:
			EndEvent (trace, 16, timeStamp)			
		if hctrl['SC/CNT'] == 1 and prev_hctrl['SC/CNT'] == 0:
			BeginEvent (trace, 17, timeStamp, "SC/CNT")
		if hctrl['SC/CNT'] == 0 and prev_hctrl['SC/CNT'] == 1:
			EndEvent (trace, 17, timeStamp)
		if hctrl['/HB'] == 1 and prev_hctrl['/HB'] == 0:
			BeginEvent (trace, 18, timeStamp, "/HB")
		if hctrl['/HB'] == 0 and prev_hctrl['/HB'] == 1:
			EndEvent (trace, 18, timeStamp)
		if hctrl['SYNC'] == 1 and prev_hctrl['SYNC'] == 0:
			BeginEvent (trace, 19, timeStamp, "SYNC")
		if hctrl['SYNC'] == 0 and prev_hctrl['SYNC'] == 1:
			EndEvent (trace, 19, timeStamp)
		if hctrl['BURST'] == 1 and (prev_hctrl['BURST'] == 0 or BurstNyet):
			BeginEvent (trace, 20, timeStamp, "BURST")
			BurstNyet = False
		if hctrl['BURST'] == 0 and prev_hctrl['BURST'] == 1:
			EndEvent (trace, 20, timeStamp)

		if spamLog:
			print (f"H: {str(hcnt.get()).rjust(3)}; ", end='')
			print (f"PCLK: {PCLK}; ", end='')
			fsm.dump(n_OBCLIP, n_BGCLIP, BLACK)

		hcnt.sim(1, PCLK, fsm.GetHC(), RES)
		vcnt.sim(V_IN, PCLK, fsm.GetVC(), RES)

		if PCLK:
			PCLK = 0
		else:
			PCLK = 1

		timeStamp += stepMcs

		prev_hctrl = hctrl
		prev_vctrl = vctrl

	# Close open tracing segments

	if closeScan:
		EndEvent (trace, 1, timeStamp)
	if closeVis:
		EndEvent (trace, 9, timeStamp)
	if closeFnt:
		EndEvent (trace, 10, timeStamp)
	if closeBporch:
		EndEvent (trace, 15, timeStamp)

	# Output statistics and tracing to a file

	end_time = time.time()
	time_elapsed = (end_time - start_time)
	print(f"Real time elapsed: {time_elapsed} seconds; PPU time: {timeStamp} mcs.")

	EndEvent (trace, 1, timeStamp)

	if ntsc:
		file = open('ntsc_trace.json', 'w')
		print ("Saving ntsc_trace")
	else:
		file = open('pal_trace.json', 'w')
		print ("Saving pal_trace")
	file.write(json.dumps(trace))
	file.close()


if __name__ == '__main__':
	#TestCounterStage()
	#TestCounter()
	#TestHDecoder(ntsc=True)
	#TestVDecoder(ntsc=True)
	TestFSM(ntsc=True)
