# Breaking NES Wiki

This resource contains comprehensive information on three chips:
- [MOS](MOS.md) [6502](6502/Readme.md)
- [Ricoh](Ricoh.md) 2A03
- Ricoh 2C02

The 2A03 ([APU](APU/Readme.md)) and 2C02 ([PPU](PPU/Readme.md)) chips are the basis of the Nintendo NES, Famicom and their [numerous analogs](Dendy.md) game consoles.

Since the 6502 processor is part of the 2A03 chip in a slightly "stripped-down" version, it is studied separately.

## Source of information

The source of the information is high-resolution microphotographs of the ICs.

At that time ICs were very simple and were produced by [NMOS](nmos.md) technology, with one surface layer of metal. Therefore, to obtain vector masks, two types of photos were sufficient: a photo of the surface with metal and a photo without metal. Usually boiling acid is used to remove metal from old ICs.

The chips under the microscope look like this:

|6502|APU|PPU|
|---|---|---|
|<img src="/BreakingNESWiki/imgstore/6502_die_shot.jpg" width="180px">|<img src="/BreakingNESWiki/imgstore/apu_die_shot.jpg" width="200px">|<img src="/BreakingNESWiki/imgstore/ppu_die_shot.jpg" width="210px">|

After the vector masks are obtained, they are used to search for transistors, which eventually form a logic circuit.

## Structure and purpose of the wiki

The functions of the wiki include a detailed description of all the functional blocks of the chips.

The wiki is divided into 3 sections, according to the number of chips being studied. Through the navigation menu you can get insight into the main functional blocks of each chip.

Each section is a detailed review of the transistor circuit, the logic circuit and, if possible, an analysis of the operation.

Also in some places at the end of the section is a Verilog for the circuit being studied.

As usual, a knowledge of microelectronics and programming is required to understand the material.

Note on the English version: the translation was done with the service [DeepL.com](http://DeepL.com), so it may seem awkward somewhere for native speakers. You are free to contribute your own edits to make it "human".

Enjoy watching it!
