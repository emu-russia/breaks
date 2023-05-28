# Breaks - Nintendo Entertainment System (NES) / Famicom / Famiclones chip reversing

This project is aimed to reverse engineer following integrated circuits:
- MOS 6502
- Ricoh 2A03 (known as NES APU)
- Ricoh 2C02 (known as NES PPU)

Project goals:
- Get complete transistor circuits ✅
- Convert transistor circuits to more high-level logic gates ✅
- Simulate circuits and write logic gate-level emulator (Moved to another repo - [Breaknes](https://github.com/emu-russia/breaknes)) ✅

The project has fully completed all its tasks, the repository will be used for some time to refine the schematics and rearrange them as HDL, but in general we can say that the research is complete.

## Books

The contents of the Wiki are recompiled into books in pdf format, you can print them at your local publisher.

<img src="https://github.com/emu-russia/breaks/raw/master/Docs/NES/Books/bnb_6502.jpg" width="200px"> <img src="https://github.com/emu-russia/breaks/raw/master/Docs/NES/Books/bnb_apu.jpg" width="200px"> <img src="https://github.com/emu-russia/breaks/raw/master/Docs/NES/Books/bnb_ppu.jpg" width="200px">

The latest book revisions:
- 6502 Core Book: https://github.com/emu-russia/breaks/releases/tag/6502-book-revB5
- APU Book: https://github.com/emu-russia/breaks/releases/tag/apu-book-revA6
- PPU Book: https://github.com/emu-russia/breaks/releases/tag/ppu-book-revB8

The contents may differ from the Wiki, so be careful. From time to time updated revisions of the books are released with updates.

## HDL

All schematics from the Wiki are formalized as much as possible in the form of an HDL. We do not aim to make a synthesizable HDL, instead we use a "Die-Perfect" approach - the HDL repeats the netlist of the original chips as closely as possible.

![chip-perfect-approach.png](/HDL/Design/chip-perfect-approach.png)

## Chip Images

This section contains links from where you can download datasets - photographs of various chips, as well as links to forum threads with discussions.

### NES/Famicom

- 6502: https://drive.google.com/drive/folders/17EJCpvw_i7w55upLx1uWYqEYnycqkMSk

- RP2A03G: http://www.visual6502.org/images/pages/Nintendo_RP2A_die_shots.html

- RP2A03G (mirror): https://drive.google.com/drive/folders/10FeSOP4EUiLFMSUXYdi00ia0c3cAPzQL

- RP2C02G-0: http://www.visual6502.org/images/pages/Nintendo_RP2C02_die_shots.html

- RP2A03(Revision?): https://siliconpr0n.org/map/nintendo/rp2a03/

- RP2C04-0003: https://siliconpr0n.org/map/nintendo/rp2c04-0003/

- RP2C02G (another rev): https://drive.google.com/drive/folders/1aaNk9dVwvTbCpsACfet-5hX65iNZr6AO

- RP2A07A: https://drive.google.com/drive/folders/17tl0-CY6gGMZEBJe4ZxIZ_b5cpO6CX0H

- RP2C07-0: https://drive.google.com/drive/folders/1nA9thbA0Vy0MzFepm7ZRhWfzq0dq9eZ1

- RP2C02H: https://drive.google.com/drive/folders/1OUf1Gd0u7skPt9ujQPBdxpfTswRuTjja

- RP2A03H: https://drive.google.com/drive/folders/14dvUUHoQiwdQZn2hNI18k5rU2ekNybQO

- RP2A03E: https://drive.google.com/drive/u/0/folders/191C8i1kv71A5rL_eK0WnclIbhIeOeXYf

- RP2C02E-0: https://drive.google.com/drive/u/0/folders/1eFJ7IFV61QnKHoS3X7aPmuwZv40ac3B5

### Famiclones

- UMC 6527P, 6538, TA, 1818P etc: https://drive.google.com/drive/folders/1splfmyjpisDjYkXpbjlSoudwbgEAuS1P

- https://forums.nesdev.org/viewtopic.php?t=23682

## Why Breaks? 

We're breaking chips here :)
