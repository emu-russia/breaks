'''
	Script for automatic generation of NOR decoders.
'''

import os
import sys

def Main (decoder_txt):
	print (f"Using {decoder_txt} as bitmask");

	bitmask_dump = open(decoder_txt, 'r')
	lines = bitmask_dump.readlines()

	decoder_out = 0
	for line in lines:
		decoder_in = 0
		first = True
		print (f"assign dec_out[{decoder_out}] = ~|{{", end = '') 	# Reducing nor
		for bit in line[::-1]: 		# msb first in input vector, need to reverse string
			if (bit == '0' or bit == '1'):
				if (bit == '1'):
					if (not first): print (",", end = '')
					print (f"d[{decoder_in}]", end = '')
					first = False
				decoder_in += 1
		print ("};")
		decoder_out += 1

if __name__ == '__main__':
	if (len(sys.argv) < 2):
		print ("Use: python3 decoder.py <decoder.txt>")
	else:
		Main(sys.argv[1])
