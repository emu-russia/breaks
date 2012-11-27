set PATH=c:\lcc\bin

lc -nw -g2 APU.c APU_CLOCK.c BUS.c DAC.c DEBUGREGS.c DIVIDER.c DPCM.c IO_PORT.c LFO.c NOISE.c REGSELECT.c SPRITE_DMA.c SQUARE1.c SQUARE2.c TRIANGLE.c TestSuite.c -o APU.exe
lc -nw -g2 APU.c APU_CLOCK.c BUS.c DAC.c DEBUGREGS.c DIVIDER.c DPCM.c IO_PORT.c LFO.c NOISE.c REGSELECT.c SPRITE_DMA.c SQUARE1.c SQUARE2.c TRIANGLE.c -o ../../Build/Ricoh2A03.dll -subsystem windows -dll -s

APU.exe
