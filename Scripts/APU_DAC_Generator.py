"""

	APU DAC table generator, separately for AUX A/B channels.

	Produced by simple calculations based on the internal resistance of the APU DAC transistors and 
	external resistance on the motherboard. 

"""

import os
import sys

IntRes = 5.1 * 1000 	# Internal single MOSFET resistance
IntUnloaded = 999999 	# Non-loaded DAC internal resistance 
ExtRes = 75 			# On-board pull-down resistor to GND
Vdd = 5.0

# According to the results of comparisons with real measurements, the internal resistance of the FET is out of the nominal resistance range (E24 5.1k)

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
	stage_reciprocal = [8, 3, 2, 1]

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
			r = r + 1 / IntRes / stage_reciprocal[i]
			any_exists = True
		if sqb_r_exists[i]:
			r = r + 1 / IntRes / stage_reciprocal[i]
			any_exists = True

	if any_exists == False:
		return IntUnloaded

	return 1 / r

if __name__ == '__main__':
	#SchoolTest()

	for sqb in range(16):
		for sqa in range(16):
			r = AUX_A_Resistance (sqa, sqb)
			i = Vdd / (r + ExtRes)
			aux_v = i * ExtRes
			print (f"sqb:{sqb} sqa:{sqa}: {aux_v * 1000} mV")
