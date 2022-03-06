# Ricoh

![ricoh](/BreakingNESWiki/imgstore/ricoh.png)

**Ricoh** is Nintendo's contractor, whose factories produced the major **RP** chips for the Famicom and NES.

Surprisingly, the company's history given [on the site](http://www.ricoh.com/about/company/history/) is silent about this partnership.

The list of chips is:
- RP2C02 / RP2C07: NTSC and PAL versions of the PPU respectively
- RP2A03 / RP2A07: NTSC and PAL versions of APUs, respectively
- There are also RGB versions of PPUs for NES-based arcade machines: RP2C03, RP2C04 and RP2C05

## Borrowing 6502

The APU is known to contain the 6502 processor core.

It is not known exactly how Ricoh got the 6502 masks - by licensing from MOS or by reverse engineering.

All that is known is that the design of the 6502 embedded topology is exactly the same as the original 6502 topology, but done in the "Ricoh style" (each company has its own unique "style" of creating masks for the chips).

It is also known that at that time there was a patent for binary-decimal number correction, under the authorship of MOS (http://www.google.com/patents/US3991307), so in order not to make patent deductions Ricoh simply "turned off" the BCD-correction. After studying the microphotos, it became clear that this disabling consisted in "cutting out" a few transistors, but the circuit itself is still present.

But this is a thing of the bygone days and nobody cares :smiley:
