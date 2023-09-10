# NES

List of motherboard revisions:

|Board|Description|
|---|---|
|NES-CPU-02|2A03E/2C02E-0; 1985 copyright on PCB; VRAM and WRAM are NDIP-only; 3193 Non-A CIC; (This is the first one "released" in the USA, in the first 10,000? or so test release NES consoles, before wide release)|
|NES-CPU-03|unclear if this was even shipped|
|NES-CPU-04|2A03E/2C02E-0; 1986 copyright on PCB; VRAM and WRAM are NDIP-only; 3193 Non-A or 3193A CIC (release day consoles?, not sure of pcb changes to above); some have a 74HC139 at U3 instead of 74LS139|
|NES-CPU-05|2A03G/2C02G-0; 1986 copyright on PCB; VRAM and WRAM are NDIP-only; 3193A CIC (not sure of changes to above)|
|NES-CPU-06|2A03G/2C02G-0; 1987 copyright on PCB; VRAM and WRAM are NDIP or DIP|
|NES-CPU-07|2A03G/2C02G-0; 1987 copyright on PCB; VRAM and WRAM are NDIP or DIP (not sure of changes to above)|
|NES-CPU-08|2A03G/2C02G-0; 1989 copyright on PCB; VRAM and WRAM are NDIP or DIP|
|NES-CPU-09|2A03G/2C02G-0 or 2A07/2C07-0; 1987 copyright on PCB; VRAM and WRAM are NDIP or DIP; Has one resistor between CIC pin (data?) and cart connector to thwart some CIC STUN attacks|
|NES-CPU-10|2A03G/2C02G; 1987 copyright on PCB; VRAM and WRAM are NDIP or DIP; Has two resistors between CIC pins (clock and data?) and cart connector to thwart more CIC STUN attacks, some later pcbs have a hand-added-at-factory diode or diodes to nearby GND vias as well to prevent the -5V attack|
|NES-CPU-11|2A03G/2C02G or 2A07A/2C07A; 1987 Copyright on PCB; VRAM and WRAM are NDIP or DIP; Has two resistors and two diodes between CIC pins, cart connector and GND to prevent CIC STUN and -5V attacks|
|NESN-CPU-01 (1993)|U1: RAM: LH5216AD-10L; U2: HD74LS373P; U3: HD74LS139P; U5: PPU: RP2C02G-0; U6: CPU: RP2A03G; U7, U8: SN74HC368N; U9: +5V Regulator: 7805|
|NESN-CPU-JI0-01 (1993)|U1: WRAM: LH5216AD-10L; U2: SN74LS373N; U3: BU3266S; U4: VRAM: LH5216AD-10L; U5: PPU: RP2C02H-0; U6: CPU: RP2A03H; U7: +5V Regulator: 7805|
|NESN-CPU-AV-01 (1994)|U1: RAM: BR6216B-10LL; U2: MB74LS373; U3: BU3270S; U4: RAM: BR6216B-10LL; U5: PPU: RP2C02H-0; U6: CPU: RP2A03H; U7: +5V Regulator: 7805|

TODO: PAL versions, rebrandings like the Indian SAMURAI.

Source: https://forums.nesdev.org/viewtopic.php?p=196688#p196688

Source: https://wiki.console5.com/tw/index.php?title=Nintendo_NES-101

## Generic NES

![nes](/BreakingNESWiki/MB/imgstore/nes.png)

## CIC

CIC is a special chip for Copy Protection implementation. The chip on the motherboard "communicates" with a similar chip on the cartridge and if the check is not passed - the system goes into endless RESET.

In new revisions of NES (TopLoader) this protection is absent, because it is bypassed with minimal effort.

TBD.

## Expansion Port

The expansion port is located on the bottom of the console under the cover and is also routed to the cartridge pins (unlike the Famicom's expansion port, which only connects to the CPU I/O terminals).

TBD.

## 40H368

This IC is an array of TriState (in Verilog terms, the notif0 array):

![40H368](/BreakingNESWiki/MB/imgstore/40H368.jpg)

## LS139

Coupled demultiplexer with inverse outputs:

![LS139](/BreakingNESWiki/MB/imgstore/LS139.jpg)

Used to control Chip Select depending on the address value.

## LS373

8-bit latch for PPU A/D bus multiplexing:

![LS373](/BreakingNESWiki/MB/imgstore/LS373.jpg)

Latch schematic:

![LS373_Transparent_Latch](/BreakingNESWiki/MB/imgstore/LS373_Transparent_Latch.jpg)
