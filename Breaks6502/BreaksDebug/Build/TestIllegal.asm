; A sandbox to check illegal opcodes.

org $200

Reset:

	nop
	byte  #$c3
	byte  #$00
	#byte  #$00

	nop
	
	brk

org $fffa
word Reset
word Reset
word Reset
