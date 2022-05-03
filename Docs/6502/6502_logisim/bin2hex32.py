'''
	A script to convert a binary file into HEX Logisim format.

	A modified version that works with 32-bit data.

'''

import os
import sys

def swap32(x):
    return (((x << 24) & 0xFF000000) |
            ((x <<  8) & 0x00FF0000) |
            ((x >>  8) & 0x0000FF00) |
            ((x >> 24) & 0x000000FF))

def Main (file_bin, file_hex):
	f = open(file_bin, 'rb')
	binarycontent = f.read(-1)
	f.close()

	text = "v2.0 raw\n"

	byteCount = 0
	val = 0

	for b in binarycontent:
		if byteCount != 0:
			val <<= 8
		val |= b
		byteCount += 1
		if byteCount == 4:
			byteCount = 0
			text += ("%0x" % swap32(val)) + " "
			val = 0

	text_file = open(file_hex, "w")
	text_file.write(text)
	text_file.close()

if __name__ == '__main__':
	if (len(sys.argv) < 2):
		print ("Use: py -3 bin2hex.py <file.bin> <file.hex>")
	else:
		Main(sys.argv[1], sys.argv[2])
