; Visual6502 demo program, for simulation comparison.
; The only difference is that the program starts at $C000 instead of $0.

    PROCESSOR 6502
    ORG $C000

RESET:
NMI:
IRQ:
    LDA     #0
AGAIN:
    JSR     PROC1
    JMP     AGAIN

    BRK
    BRK
    BRK
    BRK
    BRK
    BRK
    BRK
    RTI

PROC1:
    INX
    DEY
    INC $0F
    SEC
    ADC #$02
    RTS
    BRK

    ORG $FFFA

    WORD NMI
    WORD RESET
    WORD IRQ

END
