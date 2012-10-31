set PATH=c:\lcc\bin

lc -nw -g2 PPU.c BUS.c COUNTERS.c DATAREAD.c HV.c HV_LOGIC.c MUX.c OAM.c OAM_EVAL.c PALETTE.c PPU_CLOCK.c REGSELECT.c VIDOUT.c DEBUG.c -o PPU.exe
lc -nw -g2 PPU.c BUS.c COUNTERS.c DATAREAD.c HV.c HV_LOGIC.c MUX.c OAM.c OAM_EVAL.c PALETTE.c PPU_CLOCK.c REGSELECT.c VIDOUT.c -o ../../Build/Ricoh2C02.dll -subsystem windows -dll -s

PPU.exe
