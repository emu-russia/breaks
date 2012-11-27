set PATH=c:\lcc\bin

lrc Breaks.rc -o Breaks.res
lc -Ic:\lcc\include -g ASM.c Breaks.c Cart.c Motherboard.c Debug.c DebugUtils.c -o ../Build/Breaks.exe -subsystem windows -s Breaks.res comctl32.lib
