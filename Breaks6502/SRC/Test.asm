; Test program

LABEL1:

    PROCESSOR 6502
    ORG     $100

    DEFINE  KONST   #$15

    LDX     KONST
    LDX     $1
    LDX     $1,y
    LDX     $aabb
    ldx     LABEL1,y
    ldx     $aabb,a

    DEFINE  KONST   #1

    end

AGAIN:
    NOP
    LDA     X, SOMEDATA         ; Load some data
    JSR     ADDSOME             ; Call sub
    STA     X, SOMEDATA
    CLC
    BCC     AGAIN               ; Test branch logic

ADDSOME:                        ; Test ALU
    ADC     KONST
    PHP                         ; Test flags in/out
    PlP
    RTS

SOMEDATA:
    BYTE    12, $FF, "Hello, world"
    WORD    AGAIN
    