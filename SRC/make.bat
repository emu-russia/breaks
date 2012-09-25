set PATH=c:\lcc\bin

lrc Breaks.rc -o Breaks.res
lc -Ic:\lcc\include -g Breaks.c Cart.c Motherboard.c Debug.c debugconsole.c Joypads.c TVOut.c -o ../Build/Breaks.exe -subsystem windows -s Breaks.res comctl32.lib
