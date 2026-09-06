# PPU HDL

PPU implementation on Verilog.

Status: WIP (the full datapath — registers, scroll regs, VRAM control, PAMUX, PAR, tile counters, BG colour, OAM, sprite evaluation, object FIFO, CRAM and the composite DAC — is now modelled; PAL (RP2C07) and pixel-accurate OAM/CRAM timing still need refinement)

The PPU revision is selected by the macro: `RP2C02` or `RP2C07`. Other PPU revisions (RGB, clones) will be added over time.

![ppu_schematic](/HDL/Design/ppu/ppu_schematic.png)