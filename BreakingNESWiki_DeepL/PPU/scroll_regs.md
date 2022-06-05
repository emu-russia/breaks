# Scrolling Registers

![ppu_locator_scroll_regs](/BreakingNESWiki/imgstore/ppu/ppu_locator_scroll_regs.jpg)

The scrolling registers are tricky:
- Two consecutive writes to $2005 or $2006 put values into the same FF
- The best way to see when and where they are written is in the tables below
- The Name Table also uses a similar duality when writing to the $2000 register

Anyone who has been programming NES for a long time is familiar with these features. They are usually referred to in the context of `loopy`, by the nickname of the person who reviewed their features for emulation purposes.

Who is just starting to get familiar with the NES, it's ... arrgh...

![SCC_Regs](/BreakingNESWiki/imgstore/ppu/SCC_Regs.png)

FF circuit used to store values:

![SCC_FF](/BreakingNESWiki/imgstore/ppu/SCC_FF.png)

## Fine HScroll

![ppu_dataread_dualregs_fh](/BreakingNESWiki/imgstore/ppu/ppu_dualregs_fh.jpg)

![SCC_FineH](/BreakingNESWiki/imgstore/ppu/SCC_FineH.png)

|W5/1|FH|
|---|---|
|DB0|0|
|DB1|1|
|DB2|2|

## Fine VScroll

![ppu_dataread_dualregs_fv](/BreakingNESWiki/imgstore/ppu/ppu_dualregs_fv.jpg)

![SCC_FineV](/BreakingNESWiki/imgstore/ppu/SCC_FineV.png)

|W5/2|W6/1|FV|
|---|---|---|
|DB0|DB4|0|
|DB1|DB5|1|
|DB2|`0`|2|

Writing `0` to FV2 instead of $2006\[6\] is because the value for the FV counter is forcibly limited to the range 0-3, because otherwise its value would be outside the PPU address space.

## Name Table Select

![ppu_dataread_dualregs_nt](/BreakingNESWiki/imgstore/ppu/ppu_dualregs_nt.jpg)

![SCC_NTSelect](/BreakingNESWiki/imgstore/ppu/SCC_NTSelect.png)

|W0|W6/1|NT|
|---|---|---|
|DB0|DB2|NTH|
|DB1|DB3|NTV|

## Tile V

![ppu_dataread_dualregs_tv](/BreakingNESWiki/imgstore/ppu/ppu_dualregs_tv.jpg)

![SCC_TileV](/BreakingNESWiki/imgstore/ppu/SCC_TileV.png)

|W5/2|W6/1|W6/2|TV|
|---|---|---|---|
|DB3| |DB5|0|
|DB4| |DB6|1|
|DB5| |DB7|2|
|DB6|DB0| |3|
|DB7|DB1| |4|

## Tile H

![ppu_dataread_dualregs_th](/BreakingNESWiki/imgstore/ppu/ppu_dualregs_th.jpg)

![SCC_TileH](/BreakingNESWiki/imgstore/ppu/SCC_TileH.png)

|W5/1|W6/2|TH|
|---|---|---|
|DB3|DB0|0|
|DB4|DB1|1|
|DB5|DB2|2|
|DB6|DB3|3|
|DB7|DB4|4|
