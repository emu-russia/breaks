# Breaking NES Wiki

This resource contains comprehensive information on three chips: [MOS](MOS.md) [6502](6502/Readme.md), [Ricoh](Ricoh.md) 2A03 and Ricoh 2C02.

The 2A03 ([APU](APU/Readme.md)) and 2C02 ([PPU](PPU/Readme.md)) chips are the basis of the Nintendo NES, Famicom and their [numerous analogs](Dendy.md) game consoles.

Since the 6502 processor is part of the 2A03 chip in a slightly "stripped-down" version, it is studied separately.

The 6502 processor:

<img src="/BreakingNESWiki/imgstore/mos_6502ad_top.jpg" width="300px">

APU and PPU chips of different revisions:

<img src="/BreakingNESWiki/imgstore/2701408_600px.jpg" width="400px">

## Source of information

The source of the information is high-resolution microphotographs of the ICs.

At that time ICs were very simple and were produced by [[NMOS]] technology, with one surface layer of metal. Therefore, to obtain vector masks, two types of photos were sufficient: a photo of the surface with metal and a photo without metal. Usually boiling acid is used to remove metal from old ICs.

The chips under the microscope look like this (6502, APU and PPU, respectively):

<img src="/BreakingNESWiki/imgstore/6502_die_shot.jpg" width="180px"> <img src="/BreakingNESWiki/imgstore/apu_die_shot.jpg" width="200px"> <img src="/BreakingNESWiki/imgstore/ppu_die_shot.jpg" width="210px">

After the vector masks are obtained, they are used to search for transistors, which eventually form a logic circuit.
The process of creating vector masks, drawing transistors and logic circuits is covered in detail in my streams.

## Structure and purpose of the wiki

All basic photo and video materials can be found at [main project website](http://breaknes.com).

The functions of the wiki include a detailed description of all the functional blocks of the chips, with the results of the software simulation of each block. Thus we gradually replace the "Read" section from the main site, as it was not very convenient to keep track of changes there. Here you can find out what's new at once :smiley:

The wiki is divided into 3 sections, according to the number of chips being studied. Through the navigation menu you can get acquainted with the main functional blocks of each chip.

Each section is a detailed look at first the transistor circuit, then the logic circuit and the result is a simulation of the entire block, to check the logic of its operation. The following C "primitives" are used as "basic" logic:
```c
#define BIT(n)     ( (n) & 1 )    // cut out all unnecessary stuff
int NOT(int a) { return (~a & 1); }
int NAND(int a, int b) { return ~((a & 1) & (b & 1)) & 1; }
int NOR(int a, int b) { return ~((a & 1) | (b & 1)) & 1; }
```

As usual, a knowledge of microelectronics and programming is required to understand the material. Earlier a tightly packed joint was required, but after various interviews in different companies when I showed the wiki as my portfolio - this joke was taken literally, so I removed this requirement.

Note on the English version of the Wiki: the translation was done with the service [DeepL.com](http://DeepL.com), so it may seem awkward somewhere for native speakers. You are free to contribute your own edits to make it `human'.

Enjoy watching it!
