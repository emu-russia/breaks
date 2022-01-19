; A test to check all opcodes, and at the same time check Breakasm.

org $c000
processor 6502

Reset:
	brk

BogusNMI:
	inx
	rti

BogusIRQBrk:
	iny
	rti

org $fffa
word BogusNMI
word Reset
word BogusIRQBrk
