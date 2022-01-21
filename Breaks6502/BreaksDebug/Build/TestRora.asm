; A piece of the test for the `ROR A` instruction, ripped from nestest.

org $200

Reset:

	sec
	lda #$01
	ror a
	bcc BadRoar
	beq BadRoar
	bpl BadRoar
	cmp #$80
	bne BadRoar
	clv
	clc
	lda #$55
	ror a
	bcc BadRoar
	beq BadRoar
	bmi BadRoar
	bvs BadRoar
	cmp #$2a
	bne BadRoar

Good:
	jmp 	Good

BadRoar:
; ROAR!!!1
	brk

org $fffa
word Reset
word Reset
word Reset
