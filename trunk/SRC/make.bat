set PATH=c:\lcc\bin

lc -Ic:\lcc\include -g Breaks.c Cart.c Motherboard.c Debug.c Joypads.c TVOut.c -o Breaks.exe -subsystem windows -s
