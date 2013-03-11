set PATH=c:\lcc\bin

lc -nw -g2 DECODER.c TOP.c -o 6502.exe
REM lc -nw -g2 6502.c debug.c -o 6502.exe
6502.exe > out.txt
