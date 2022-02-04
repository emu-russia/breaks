; A sandbox to check illegal opcodes.

org $200

Reset:

	nop
	byte  #$df 			; dcp  abs, x
	byte  #$00
	byte  #$00

	nop

	brk

org $fffa
word Reset
word Reset
word Reset
