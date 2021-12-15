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
|PCLK| | | |
|/PCLK| | | |
|RC| | | |
|EXT0-3 IN| | | |
|EXT0-3 OUT| | | |
|/SLAVE| | | |
|R/W| | | |
|/DBE| | | |
|RS0-3| | | |
|/W6/1| | | |
|/W6/2| | | |
|/W5/1| | | |
|/W5/2| | | |
|/R7| | | |
|/W7| | | |
|/W4| | | |
|/W3| | | |
|/R2| | | |
|/W1| | | |
|/W0| | | |
|/R4| | | |
|V0-7| | | |
|RESCL| | | |
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
|VBL| | | |
|/TB| | | |
|/TG| | | |
|/TR| | | |
|SC/CNT| | | |
|0/HPOS| | | |
|I2SEV| | | |
|/OBCLIP| | | |
|/BGCLIP| | | |
|H0'' - H5''| | | |
|BLACK| | | |
|DB0-7| | | |
|B/W| | | |
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
|O8/16| | | |
|OB7| | | |
|0/FIFO| | | |
|I1/32| | | |

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
