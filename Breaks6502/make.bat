set PATH=c:\lcc\bin

lc -nw -g2 debug.c 6502.c ALU.c -o 6502.exe
6502.exe > out.txt
