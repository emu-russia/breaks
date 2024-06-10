# Bus Multiplexer

All scattered pieces of schematics of the lower part, where internal buses are connected to each other or buses are connected to constants, it was decided to separate them into a separate section.

The reason for this is that working with buses is a "favorite topic" when designing circuits and it is better to have all places where work with buses happens in one place.

## Precharge

All buses are precharged during PHI2. This is done to form constants: from the value 0xff, which was obtained during precharge, other values are obtained by connecting the required bits to 0.
Note that the charged bus value is retained for the next half-cycle (PHI1), where the required constants are generated.

The SB bus is being precharged in the S register:

![busmpx1](/BreakingNESWiki/imgstore/6502/busmpx1.jpg)

The DB bus is precharged in DataLatch:

![busmpx2](/BreakingNESWiki/imgstore/6502/busmpx2.jpg)

The ADL bus is precharged around the PC register (bits 0-3), with the other FETs scattered between PC and DL:

![busmpx3](/BreakingNESWiki/imgstore/6502/busmpx3.jpg)
![busmpx5](/BreakingNESWiki/imgstore/6502/busmpx5.jpg)

The ADH bus is precharged in the AC register (bits 0-2), with the remaining FETs scattered between PC and DL:

![busmpx4](/BreakingNESWiki/imgstore/6502/busmpx4.jpg)
![busmpx5](/BreakingNESWiki/imgstore/6502/busmpx5.jpg)

## 0/ADL

The commands 0/ADL0, 0/ADL1, 0/ADL2 are used to generate the interrupt address. The FETs are located next to terminals A0-A2.

![busmpx6](/BreakingNESWiki/imgstore/6502/busmpx6.jpg)

## 0/ADH

The 0/ADH0 and 0/ADH17 commands are applied next to the AC register. The 0/ADH0 command applies to bit 0. The 0/ADH17 command applies to bits 1-7.

![busmpx7](/BreakingNESWiki/imgstore/6502/busmpx7.jpg)

## Connection of buses to buses

The SB/DB and SB/ADH commands are used to connect the buses to each other. The FETs to apply these commands are located next to the AC register.

![busmpx8](/BreakingNESWiki/imgstore/6502/busmpx8.jpg)

These commands cause the most trouble when porting 6502 circuits to Verilog or simulation because the bus connection is implemented by a bidirectional FETs.
