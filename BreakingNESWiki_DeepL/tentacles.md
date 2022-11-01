# Signal Manifest

:warning: Corrections to signal names are no longer accepted.

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
|THZ,THZB|Pairwise renamed (THZ -> THZB, THZB -> THZ)|
|TVZ,TVZB|Pairwise renamed (TVZ -> TVZB, TVZB -> TVZ)|
|/OE|/WE (OAM Buffer Control)|
|F/NT|#F/NT (inverse polarity)|
|PICTURE|/PICTURE (inverse polarity)|
|x/EN|#x/EN (inverse polarity), OAM FIFO|
|x/COL0, x/COL1|#x/COL0, #x/COL1 (inverse polarity), OAM FIFO|
|Tx|/Tx (inverse polarity), OAM FIFO|
|0/H|#0/H (inverse polarity), OAM FIFO|
|0/FIFO|PD/FIFO|
|M4_OVZ|COPY_OVF|
|DDD|COPY_STEP|
|/I2|DO_COPY|
|I2SEV|/SPR0_EV|
|CLPB|/CLPB (inverse polarity)|
|EVAL|/EVAL (inverse polarity)|
|P123|PBLACK (Phase Shifter)|

## APU

|Was|Still|
|---|---|
|FLOAD,FSTEP,SLOAD,SSTEP|DFLOAD,DFSTEP,DSLOAD,DSSTEP (DPCM)|
|FLOAD,FSTEP,LOAD,STEP,ERES,ESTEP|NFLOAD,NFSTEP,NLOAD,NSTEP,NERES,NESTEP (noise)|
|ENV0..3,VOL0..3,V0..3,ENVEN,ENVDIS|NENV0..3,NVOL0..3,NV0..3,NENVEN,NENVDIS (noise)|
|F0..3,NF0..10,RELOAD,ECO|NF0..3,NNF0..10,NRELOAD,NECO (noise)|
|FLOAD,FSTEP,LOAD,STEP,TSTEP|TFLOAD,TFSTEP,TLOAD,TSTEP,TTSTEP (triangle)|
|SWRELOAD,INC,DEC,COUT,SWCTRL|ASWRELOAD,AINC,ADEC,ACOUT,ASWCTRL (SQ0)|
|SR0,SR1,SR2,SLOAD,SSTEP,/SCO1, SCO|ASR0,ASR1,ASLOAD,ASSTEP,/ASCO1,ASCO (SQ0)|
|RELOAD,ECO,VCO,ENVDIS,ENVEN|ARELOAD,AECO,AVCO,AENVDIS,AENVEN (SQ0)|
|EPOL,ERES,ESTEP,LOAD,RSTEP|AEPOL,AERES,ALOAD,ARSTEP (SQ0)|
|ENV0..3,VOL0..3,V0..3,SWEEP,DUTY|AENV0..3,AVOL0..3,AV0..3,ASWEEP,ADUTY (SQ0)|
|FLOAD,FSTEP,FCO,SD0..2,DT0..1|AFLOAD,AFSTEP,AFCO,ASD0..2,ADT0..1 (SQ0)|
|SRZ,ADDOUT,SWDIS,/C0|ASRZ,AADDOUT,ASWDIS,/AC0 (SQ0)|
|F0..10,G0..10,S0..10,Q0..10|AF0..10,AG0..10,AS0..10,AQ0..10 (SA0)|
|/ACLK2|/ACLK3A (square0)|
|/ACLK2|/ACLK3B (square1)|
