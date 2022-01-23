'''
	A script to convert a binary file into HEX Logisim format.

'''

import os
import sys

def Main (file_bin, file_hex):
	f = open(file_bin, 'rb')
	binarycontent = f.read(-1)
	f.close()

	text = "v2.0 raw\n"

	for b in binarycontent:
		text += ("%0x" % b) + " "

	text_file = open(file_hex, "w")
	text_file.write(text)
	text_file.close()

if __name__ == '__main__':
	if (len(sys.argv) < 2):
		print ("Use: py -3 bin2hex.py <file.bin> <file.hex>")
	else:
		Main(sys.argv[1], sys.argv[2])
