# Signal Manifest

The connections inside the chips are made with metal wires and sometimes with polysilicon tracks. Between each other we call the connections "signals", "wires", "cords", "hoses" or "tentacles".

This section contains a variety of information on this subject area.

## Agreements by Name

The names of the signals were given at different times, sometimes even when the circuits were not yet fully understood.

Therefore, sometimes there may be names like `LOL`, `MILF`, `WTF` etc. Over time, we try to give the signals proper names.

Now a little bit about names:
- The inverse logic (where it is exactly known) is reflected by a dash in the signal name `/`, e.g. `/T0`, `/ready`.
- Sometimes `#` is used instead of a dash, for example `#PCL/PCL`
- The connection of two parts of a circuit is sometimes designated as `A/B`, e.g. `X/SB`
- If the signal is part of a bus, then a digit is indicated at the end, e.g. `DB0`

But in general the naming practice is quite chaotic, so be prepared, for example, that `I/OAM2` does not mean "connect I and OAM2" but "init OAM2".

## Difficulties With Inversion

Sometimes it is not immediately clear that the signal is in inverse logic. So, for example, although the signal is called `SPR0HIT` - actually it should be called `/SPR0HIT` (in inverse logic), but you do not want to rename it in all places, so wherever it is mentioned, it is additionally indicated that it is actually in inverse logic.

Also names with `/` and `#` are not suitable for Verilog, so Verilog uses the prefix `n_` instead, e.g. `n_ready`, `n_T0`.

## Renaming Procedure

It is necessary to change, if possible, all the places where the signal to be renamed is mentioned:

- Vector masks from Photoshop (not very actual anymore, because it's a pain to edit them in Photoshop every time)
- Pictures from the `Docs` folder - essentially now this is the "basic" set of schematics from which all the others are made
- Diagrams for Logisim: folders `Docs\6502\6502_logisim`, `Docs\PPU\PPU_logisim`, `Docs\APU\APU_logisim`.
- BreakingNES Wiki pages (including translations in various languages)

The http://breaknes.com site has moved to the stage of closure, so it is no longer updated. Now everything is in one place, on GitHub.

## 6502

There are questions about the `BRK7` signal. From the description of 6502 - BRK-sequence consists of cycles T0-T6, so from the name of the signal it may seem that from somewhere cycle T7 came. But no, it's just an abbreviation of `BRK7` :)

## PPU

Correction history:

|Was|Still|
|---|---|
|BAKA|0/FIFO|
|MILF|OAMCTR2|
|WTF|SPR_OV|
|LOL|I2SEV|
|OMFG|To avoid renaming the signal for the abbreviation OMFG was invented decoding - "OAM Mode Four". Defines the mode of the OAM counter (+1 / +4)|
|ASAP|The purpose of the signal is still unclear|
|SH5, SH7|Were mixed up|
|EXT0-3 OUT|/EXT0-3 OUT|
|SH2, SH3, SH5, SH7|/SH2, /SH3, /SH5, /SH7|
|CLK, /CLK|Were mixed up|
|ZCOL0, ZCOL1|/ZCOL0, /ZCOL1|
|ZPRIO|/ZPRIO|
|SPR0HIT|/SPR0HIT|
|FVO0-2|/FVO0-2|
|CB/DB|#CB/DB (inverse polarity)|
|DB/CB|#DB/CB (inverse polarity)|
|DB/OB|OB/OAM|

## APU

TBD.
