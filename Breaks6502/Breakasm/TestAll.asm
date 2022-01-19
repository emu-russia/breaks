; A test to check all opcodes, and at the same time check Breakasm.

org $200
processor 6502

Reset:

; Branches / Jump / JSR

	bpl BplLabel
BplLabel:
	bmi BmiLabel
BmiLabel:
	bvc BvcLabel
BvcLabel:
	bvs BvsLabel
BvsLabel:
	bcc BccLabel
BccLabel:
	bcs BcsLabel
BcsLabel:
	bne BneLabel
BneLabel:
	beq BeqLabel
BeqLabel:

	jsr Sub1
	jmp JumpOverSub
Sub1:
	rts
JumpOverSub:

	jmp (IndirectJumpAddr)
IndirectLabel:

; TwoCycle opcodes

	ldy #1
	cpy #1
	cpx #1
	ldx #1

	clc
	sec
	cli
	sei
	clv
	sed 			; First set the D flag, then reset it. We don't want to use BCD yet.
	cld

	dey
	tya
	tay
	iny
	inx

	ora #1
	and #1
	eor #1
	adc #1
	lda #1
	cmp #1
	sbc #1

	asl a
	rol a
	lsr a
	ror a

	txa
	tax	
	txs
	tsx
	dex
	nop

; ind

	ora x, $1
	ora $1, y
	and x, $1
	and $1, y
	eor x, $1
	eor $1, y
	adc x, $1
	adc $1, y
	sta x, $1
	sta $1, y
	lda x, $1
	lda $1, y
	cmp x, $1
	cmp $1, y
	sbc x, $1
	sbc $1, y

; zpg

	bit $1
	sty $1
	sty $1, x
	ldy $1
	ldy $1, x
	cpy $1
	cpx $1

	ora $1
	ora $1, x
	and $1
	and $1, x
	eor $1
	eor $1, x
	adc $1
	adc $1, x
	sta $1
	sta $1, x
	lda $1
	lda $1, x
	cmp $1
	cmp $1, x
	sbc $1
	sbc $1, x

	asl $1
	asl $1, x
	rol $1
	rol $1, x
	lsr $1
	lsr $1, x
	ror $1
	ror $1, x
	stx $1
	stx $1, y
	ldx $1
	ldx $1, y
	dec $1
	dec $1, x
	inc $1
	inc $1, x

; abs, Y

define ABS_ADDR $700

	ora ABS_ADDR, y
	and ABS_ADDR, y
	eor ABS_ADDR, y
	adc ABS_ADDR, y
	sta ABS_ADDR, y
	lda ABS_ADDR, y
	cmp ABS_ADDR, y
	sbc ABS_ADDR, y

; abs

	ora ABS_ADDR
	asl ABS_ADDR
	bit ABS_ADDR
	and ABS_ADDR
	rol ABS_ADDR
	eor ABS_ADDR
	lsr ABS_ADDR
	adc ABS_ADDR
	ror ABS_ADDR
	sty ABS_ADDR
	sta ABS_ADDR
	stx ABS_ADDR
	ldy ABS_ADDR
	lda ABS_ADDR
	ldx ABS_ADDR
	cpy ABS_ADDR
	cmp ABS_ADDR
	dec ABS_ADDR
	cpx ABS_ADDR
	sbc ABS_ADDR
	inc ABS_ADDR

; abs, X (except LDX)

	ora ABS_ADDR, x
	asl ABS_ADDR, x
	and ABS_ADDR, x
	rol ABS_ADDR, x
	eor ABS_ADDR, x
	lsr ABS_ADDR, x
	adc ABS_ADDR, x
	ror ABS_ADDR, x
	sta ABS_ADDR, x
	ldy ABS_ADDR, x
	lda ABS_ADDR, x
	ldx ABS_ADDR, Y   ; Care!
	cmp ABS_ADDR, x
	dec ABS_ADDR, x
	sbc ABS_ADDR, x
	inc ABS_ADDR, x

; pp

	php
	plp
	pha
	pla

; Check BRK and go into an infinite loop.

	brk
Halt:
	jmp Halt

IndirectJumpAddr:
	word IndirectLabel

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
