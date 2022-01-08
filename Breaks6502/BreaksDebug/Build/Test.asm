; Test program

LABEL1:

    PROCESSOR 6502
;    ORG     $100

    DEFINE  KONST   #5

    LDX     KONST

AGAIN:
    NOP
    LDA     SOMEDATA, X         ; Load some data
    JSR     ADDSOME             ; Call sub
    STA     $12, X
    CLC
    BCC     AGAIN               ; Test branch logic

ADDSOME:                        ; Test ALU
    ADC     KONST
    PHP                         ; Test flags in/out
    PLP
    RTS

    ASL     A

SOMEDATA:
    BYTE    12, $FF, "Hello, world" 
    WORD    AGAIN

END
