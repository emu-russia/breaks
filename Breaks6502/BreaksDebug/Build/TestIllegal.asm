; A sandbox to check illegal opcodes.

org $200

Reset:

	jmp Test_ATX

; DCP Tests ripped from nestest.nes

	LDA #$FF
	STA $1
	LDX #$FF	

; Test 1

DCP_Test_1:

	LDA #$EB
	STA $0647
	BIT $01	
	CLC
	LDA #$40

	BYTE #$DF 	; DCP $0548,X
	BYTE #$48
	BYTE #$05
	NOP

	BVC BadDCP
	BCS BadDCP
	BMI BadDCP
	CMP #$40
	BNE BadDCP
	LDA $0647
	CMP #$EA
	BNE BadDCP

; Test 2

DCP_Test_2:

	LDA #$00
	STA $0647
	CLV
	SEC
	LDA #$FF

	BYTE #$DF 	; DCP $0548,X
	BYTE #$48
	BYTE #$05
	NOP   

	BVS BadDCP
	BNE BadDCP
	BMI BadDCP
	BCC BadDCP
	CMP #$FF
	BNE BadDCP
	LDA $0647
	CMP #$FF
	BNE BadDCP

; Test 3

DCP_Test_3:

	LDA #$37
	STA $0647
	BIT $01
	LDA #$F0

	BYTE #$DF 	; DCP $0548,X
	BYTE #$48
	BYTE #$05
	NOP 

	BVC BadDCP
	BEQ BadDCP
	BPL BadDCP
	BCC BadDCP
	CMP #$F0
	BNE BadDCP
	LDA $0647
	CMP #$36
	BNE BadDCP

GoodDCP:
	jmp GoodDCP

BadDCP:
	brk

; AND byte with accumulator, then transfer accumulator to X register.
; Status flags: N,Z

Test_ATX:
	lda   #$12
	byte  #$AB
	byte  #$ab
	nop


org $fffa
word Reset
word Reset
word Reset
