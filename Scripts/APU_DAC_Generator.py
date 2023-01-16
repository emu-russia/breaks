"""

	APU DAC table generator, separately for AUX A/B channels.

	Produced by simple calculations based on the internal resistance of the APU DAC transistors and 
	external resistance on the motherboard. 

"""

import os
import sys
import csv
import struct

IntRes = 39 * 1000 		# Internal single MOSFET resistance
IntUnloaded = 999999 	# Non-loaded DAC internal resistance 
ExtRes = 100 			# On-board pull-down resistor to GND
Vdd = 5.0

"""
	Recall the school curriculum.
"""
def SchoolTest():
	print (f"Internal resistance: {IntRes} ohm, external resistance: {ExtRes} ohm");
	
	# Calculate the total current in the circuit
	r = IntRes + ExtRes
	i = Vdd / r
	print (f"Current: {i * 1000} mA")

	# Calculate the voltage across the external aux resistor, and convert it to mV (multiply by 1000)
	v_aux = i * ExtRes
	print (f"Aux voltage: {v_aux * 1000} mV")

"""
	Return the internal resistance of the AUX A terminal based on the SQA/SQB digital inputs.
"""
def AUX_A_Resistance (sqa, sqb):
	sqa_r_exists = [0, 0, 0, 0]
	sqb_r_exists = [0, 0, 0, 0]
	stage_reciprocal = [1, 2, 4, 8]

	# First determine which resistances are present
	for bit in range(4):
		if (sqa >> bit) & 1:
			sqa_r_exists[bit] = 1
		if (sqb >> bit) & 1:
			sqb_r_exists[bit] = 1

	# Calculate the total resistance
	any_exists = False
	r = 0
	for i in range(4):
		if sqa_r_exists[i]:
			r = r + 1 / (IntRes / stage_reciprocal[i])
			any_exists = True
		if sqb_r_exists[i]:
			r = r + 1 / (IntRes / stage_reciprocal[i])
			any_exists = True

	if any_exists == False:
		return IntUnloaded

	return 1 / r

"""
	Return the internal resistance of the AUX B terminal based on the TRI/RND/DMC digital inputs.
"""
def AUX_B_Resistance (tri, rnd, dmc):
	tri_r_exists = [0, 0, 0, 0]
	rnd_r_exists = [0, 0, 0, 0]
	dmc_r_exists = [0, 0, 0, 0, 0, 0, 0]
	tri_reciprocal = [2, 4, 8, 16]
	rnd_reciprocal = [1, 2, 4, 8]
	dmc_reciprocal = [0.5, 1, 2, 4, 8, 16, 32]

	# First determine which resistances are present
	for bit in range(4):
		if (tri >> bit) & 1:
			tri_r_exists[bit] = 1
		if (rnd >> bit) & 1:
			rnd_r_exists[bit] = 1
	for bit in range(7):
		if (dmc >> bit) & 1:
			dmc_r_exists[bit] = 1

	# Calculate the total resistance
	any_exists = False
	r = 0
	for i in range(4):
		if tri_r_exists[i]:
			r = r + 1 / (IntRes / tri_reciprocal[i])
			any_exists = True
		if rnd_r_exists[i]:
			r = r + 1 / (IntRes / rnd_reciprocal[i])
			any_exists = True
	for i in range(7):
		if dmc_r_exists[i]:
			r = r + 1 / (IntRes / dmc_reciprocal[i])
			any_exists = True

	if any_exists == False:
		return IntUnloaded

	return 1 / r

def DumpCsv():
	with open('auxa.csv', 'w', encoding='UTF8', newline='') as f:
		writer = csv.writer(f)
		header = ['sqb.sqa', 'mV']
		writer.writerow(header)
		for sqb in range(16):
			for sqa in range(16):
				r = AUX_A_Resistance (sqa, sqb)
				i = Vdd / (r + ExtRes)
				aux_v = i * ExtRes
				row = [(sqb << 4) | sqa, aux_v * 1000]
				writer.writerow(row)
	with open('auxb.csv', 'w', encoding='UTF8', newline='') as f:
		writer = csv.writer(f)
		header = ['dmc.rnd.tri', 'mV']
		writer.writerow(header)
		for dmc in range(128):
			for rnd in range(16):
				for tri in range(16):
					r = AUX_B_Resistance (tri, rnd, dmc)
					i = Vdd / (r + ExtRes)
					aux_v = i * ExtRes
					row = [(dmc << 8) | (rnd << 4) | tri, aux_v * 1000]
					writer.writerow(row)

# https://stackoverflow.com/questions/23624212/how-to-convert-a-float-into-hex
def float_to_hex(f):
    return hex(struct.unpack('<I', struct.pack('<f', f))[0])

"""
	Output all the same, but for Verilog. Use volts instead of millivolts.
"""
def DumpVerilogMem(gain):
	with open('auxa.mem', 'w', encoding='UTF8', newline='') as f:
		print (f"// AUX A dump as floats (normalized to [-0.5;0.5] and scaled by {gain}). The array is indexed as: {{SQB[3:0],SQA[3:0]}}\n", file=f)
		vmax = 0
		for sqb in range(16):
			for sqa in range(16):
				r = AUX_A_Resistance (sqa, sqb)
				i = Vdd / (r + ExtRes)
				aux_v = i * ExtRes
				if aux_v > vmax:
					vmax = aux_v
		for sqb in range(16):
			for sqa in range(16):
				r = AUX_A_Resistance (sqa, sqb)
				i = Vdd / (r + ExtRes)
				aux_v = ((i * ExtRes) / vmax) - 0.5
				aux_hex = float_to_hex (aux_v * gain)[2:]
				print (f"{aux_hex} ", file=f, end = '')
	with open('auxb.mem', 'w', encoding='UTF8', newline='') as f:
		print (f"// AUX B dump as floats (normalized to [-0.5;0.5] and scaled by {gain}). The array is indexed as: {{DMC[6:0],RND[3:0],TRI[3:0]}}\n", file=f)
		vmax = 0
		for dmc in range(128):
			for rnd in range(16):
				for tri in range(16):
					r = AUX_B_Resistance (tri, rnd, dmc)
					i = Vdd / (r + ExtRes)
					aux_v = i * ExtRes
					if aux_v > vmax:
						vmax = aux_v
		for dmc in range(128):
			for rnd in range(16):
				for tri in range(16):
					r = AUX_B_Resistance (tri, rnd, dmc)
					i = Vdd / (r + ExtRes)
					aux_v = ((i * ExtRes) / vmax) - 0.5
					aux_hex = float_to_hex (aux_v * gain)[2:]
					print (f"{aux_hex} ", file=f, end = '')

if __name__ == '__main__':
	#SchoolTest()
	DumpCsv()
	DumpVerilogMem(2)
