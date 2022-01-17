set PATH=c:\lcc\bin

lc -nw -g2 SWEEP.c debug.c APU.c -o APU.exe
APU.exe > APU.txt