# Breakasm

As simple and dumb assembler as possible, to generate code.

To run:

```
Breakasm test.asm test.prg
```

PRG file is always 64 Kbytes (the size of 6502 address space). The current assembly pointer (`ORG`) can be set anywhere in the PRG.

## Syntax

The source text is split into lines of the following format:

```
[LABEL:] COMMAND [OPERAND1, OPERAND2, OPERAND3] ; Comments
```

The label (`LABEL`) is optional. The command (`COMMAND`) contains 6502 instruction or one of the assebmler directives. The operands depend on the command.

## Embedded Directives

|Directive|Description|
|---|---|
|ORG|Set the current PRG assembly position.|
|DEFINE|Define a simple constant|
|BYTE|Output a byte or string|
|WORD|Output uint16_t in little-endian order. You can use both numbers as well as labels and addresses.|
|END|Finish the assembling|
|PROCESSOR|Defines type of processor for informational purposes|

## Example Source Code

Not to write too much, I will just show you an example of the source code. Do it the same way and it should work.

```asm
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
```

## Limitations

- Maximum number of labels: 1024
- Maximum number of XREFs: 1024
- Maximum number of Defines: 1024

If you need more, you need to override the values in `ASM.h`.
