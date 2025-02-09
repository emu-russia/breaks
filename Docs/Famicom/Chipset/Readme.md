# Famicom Chipset

Always wondered what was inside the chipset of your beloved Famicom? Was it a pain to break it yourself? Nobody wanted to decap these "insignificant" chips? And here we are. We don't care.

Press F :-)

## Donor

Revision: HVC-CPU-GPM-01

![donor](imgstore/donor.jpg)

Following are photos of the chip package, a photo of the chip with DSLR in natural colours, and a microphotograph of the crystal.

## 40H368

A pair of these chips serves the Famicom's IO subsystem. Each chip is an array of inverting tristate buffers (`notif1` in Verilog terminology).
In addition, one of the tristates is used as an inverting amplifier for the main audio channel and another to invert the PA13 signal (to get its complement so that millions of cartridges will save on PA13 inverting).

![40H368_package](imgstore/40H368_package.jpg)

![40H368_natural](imgstore/40H368_natural.jpg)

![40H368_Fused_sm](imgstore/40H368_Fused_sm.jpg)

## LS139

Acts as a "bridge" for mapping different CPU memory areas (PPU registers, PRG memory located on the cartridge, internal RAM of the motherboard).

![LS139_package](imgstore/LS139_package.jpg)

![LS139_natural](imgstore/LS139_natural.jpg)

![LS139_Fused_sm](imgstore/LS139_Fused_sm.jpg)

## LS373

This chip "remembers" (latches) the lower 8 bits of the PPU address, because the PPU address and data buses are multiplexed.

![LS373_package](imgstore/LS373_package.jpg)

![LS373_natural](imgstore/LS373_natural.jpg)

![LS373_Fused_sm](imgstore/LS373_Fused_sm.jpg)

## S-RAM (LH5116D-12)

Typical static memory from the 80s/90s.

![SRAM_package](imgstore/SRAM_package.jpg)

![SRAM_natural](imgstore/SRAM_natural.jpg)

![SRAM_Fused_sm](imgstore/SRAM_Fused_sm.jpg)