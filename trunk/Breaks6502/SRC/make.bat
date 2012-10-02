set PATH=c:\lcc\bin

lc -nw -g2 IR.c MISC.c TIME_REG.c INTERRUPT.c RANDOM_LOGIC.c PREDECODE.c PLA.c REGS.c PROGRAM_COUNTER.c ALU.c ADDR_BUS.c DATA_BUS.c Breaks6502.c ASM.c ROM2364.c TestSuite.c -o Breaks6502.exe
lc -nw -g2 IR.c MISC.c TIME_REG.c INTERRUPT.c RANDOM_LOGIC.c PREDECODE.c PLA.c REGS.c PROGRAM_COUNTER.c ALU.c ADDR_BUS.c DATA_BUS.c Breaks6502.c -o ../../Build/Breaks6502.dll -subsystem windows -dll -s

Breaks6502.exe

DEL OUTPUT.DIS
TRACER -o -C -N PRG.BIN