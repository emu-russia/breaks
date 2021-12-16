# Wiring

This section contains a summary table of all signals.

TBD: The inversion of some signals can be corrected after clarification. At present, the main task is to understand their essence.

If a signal is repeated somewhere, it is usually not specified again, except in cases where it is important.

The signals for the PAL version of the PPU are marked in the pictures only where there are differences from NTSC.

## Left Side

![ppu_locator_rails_left](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_left.jpg)

|NTSC|PAL|
|---|---|
|![ntsc_rails1](/BreakingNESWiki/imgstore/ppu/ntsc_rails1.jpg)|![pal_rails1](/BreakingNESWiki/imgstore/ppu/pal_rails1.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|PCLK|PCLK Gen|All|The PPU is in the PCLK=1 state|
|/PCLK|PCLK Gen|All|The PPU is in the PCLK=0 state|
|RC|/RES Pad|Regs|"Registers Clear"|
|EXT0-3 IN|EXT Pads|MUX|Input subcolor from Master PPU|
|EXT0-3 OUT|EXT Pads|MUX|Output color for Slave PPU|
|/SLAVE|Regs $2000\[6\]|EXT Pads|PPU operating mode (Master/Slave)|
|R/W|R/W Pad|RW Decoder, Reg Select|CPU interface operating mode (read/write)|
|/DBE|/DBE Pad|Regs|"Data Bus Enable", enable CPU interface|
|RS0-3|RS Pads|Reg Select|Selecting a register for the CPU interface|
|/W6/1|Reg Select| |First write to $2006|
|/W6/2|Reg Select| |Second write to $2006|
|/W5/1|Reg Select| |First write to $2005|
|/W5/2|Reg Select| |Second write to $2005|
|/R7|Reg Select| |Read $2007|
|/W7|Reg Select| |Write $2007|
|/W4|Reg Select| |Write $2004|
|/W3|Reg Select| |Write $2003|
|/R2|Reg Select| |Read $2002|
|/W1|Reg Select| |Write $2001|
|/W0|Reg Select| |Write $2000|
|/R4|Reg Select| |Read $2004|
|V0-7|VCounter| |Digits of V counter|
|RESCL| | |"RES FF Clear". Clear the /RES latch|
|OMFG| | | |
|BLNK| | | |
|PAR/O| | | |
|ASAP| | | |
|/VIS| | | |
|I/OAM2| | | |
|/H2'| | | |
|SPR_OV| | | |
|EVAL| | | |
|H0'| | | |

|NTSC|PAL|
|---|---|
|![ntsc_rails2](/BreakingNESWiki/imgstore/ppu/ntsc_rails2.jpg)|![pal_rails2](/BreakingNESWiki/imgstore/ppu/pal_rails2.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|E/EV| | | |
|S/EV| | | |
|/H1'| | | |
|/H2'| | | |
|/FO| | | |
|F/AT| | | |
|F/NT| | | |
|F/TA| | | |
|F/TB| | | |
|CLIP_O| | | |
|CLIP_B| | | |
|VBL|Regs $2000\[7\]| | |
|/TB|Regs $2001\[7\]| |"Tint Blue". Modifying value for Emphasis|
|/TG|Regs $2001\[6\]| |"Tint Green". Modifying value for Emphasis|
|/TR|Regs $2001\[5\]| |"Tint Red". Modifying value for Emphasis|
|SC/CNT| | | |
|0/HPOS| | | |
|I2SEV| | | |
|/OBCLIP|Regs $2001\[2\]| | |
|/BGCLIP|Regs $2001\[1\]| | |
|H0'' - H5''| | | |
|BLACK| | | |
|DB0-7| | | |
|B/W|Regs $2001\[0\]| | |
|TH/MUX| | | |
|DB/PAR| | | |

|NTSC|PAL|
|---|---|
|![ntsc_rails3](/BreakingNESWiki/imgstore/ppu/ntsc_rails3.jpg)|![pal_rails3](/BreakingNESWiki/imgstore/ppu/pal_rails3.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|PAL0-4| | | |

## Right Side

![ppu_locator_rails_right](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_right.jpg)

|PPU Version|Image|
|---|---|
|NTSC|![ntsc_rails4](/BreakingNESWiki/imgstore/ppu/ntsc_rails4.jpg)|
|PAL|![pal_rails4](/BreakingNESWiki/imgstore/ppu/pal_rails4.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|/OAM0-2| | | |
|OAM8| | | |

|NTSC|PAL|
|---|---|
|![ntsc_rails5](/BreakingNESWiki/imgstore/ppu/ntsc_rails5.jpg)|![rails5](/BreakingNESWiki/imgstore/ppu/pal_rails5.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|/OAM0-7| | | |
|OAM8| | | |
|OAMCTR2| | | |
|OB0-7'| | | |

|NTSC|PAL|
|---|---|
|![ntsc_rails6](/BreakingNESWiki/imgstore/ppu/ntsc_rails6.jpg)|![rails6](/BreakingNESWiki/imgstore/ppu/pal_rails6.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|OV0-3| | | |
|OB7| | | |
|0/FIFO| | | |
|I1/32|Regs $2000\[2\]| |Increment PPU address 1/32. PAL PPU uses an inverse version of the signal (#I1/32)|
|OBSEL|Regs $2000\[3\]| | |
|BGSEL|Regs $2000\[4\]| | |
|O8/16|Regs $2000\[5\]| |Object lines 8/16 (sprite size). The PAL PPU uses an inverse version of the signal (#O8/16)|

|NTSC|PAL|
|---|---|
|![ntsc_rails7](/BreakingNESWiki/imgstore/ppu/ntsc_rails7.jpg)|![rails7](/BreakingNESWiki/imgstore/ppu/pal_rails7.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|SH2| | | |
|SH3| | | |
|SH5| | | |
|SH7| | | |
|SPR0HIT| | | |
|BGC0-3| | | |
|ZCOL0-3| | | |
|ZPRIO| | | |
|THO0-4'| | | |

## Bottom Part

![ppu_locator_rails_bottom](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_bottom.jpg)

|PPU Version|Image|
|---|---|
|NTSC|![ntsc_rails8](/BreakingNESWiki/imgstore/ppu/ntsc_rails8.jpg)|
|PAL|![pal_rails8](/BreakingNESWiki/imgstore/ppu/pal_rails8.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|OB0-7| | | |
|CLPO| | | |
|CLPB| | | |
|0/FIFO| | | |
|BGSEL| | | |
|OV0-3| | | |

|NTSC|PAL|
|---|---|
|![ntsc_rails9](/BreakingNESWiki/imgstore/ppu/ntsc_rails9.jpg)|![pal_rails9](/BreakingNESWiki/imgstore/ppu/pal_rails9.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|/PA0-7| | | |
|/PA8-13| | | |
|THO0-4| | | |
|TSTEP| | | |
|TVO1| | | |
|FH0-2| | | |

`/PA0-7` are not shown in the picture, they are on the right side of the [PPU address generator](pargen.md).

|NTSC|PAL|
|---|---|
|![ntsc_rails10](/BreakingNESWiki/imgstore/ppu/ntsc_rails10.jpg)|![pal_rails10](/BreakingNESWiki/imgstore/ppu/pal_rails10.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|PD0-7| | | |
|THO1| | | |
|TVO1| | | |
|BGC0-3| | | |
|FH0-2| | | |

|PPU Version|Image|
|---|---|
|NTSC|![ntsc_rails11](/BreakingNESWiki/imgstore/ppu/ntsc_rails11.jpg)|
|PAL|![pal_rails11](/BreakingNESWiki/imgstore/ppu/pal_rails11.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|PD/RB| | | |
|XRB| | | |
|RD| | | |
|WR| | | |
|/ALE| | | |
