# Instruction Register

![6502_locator_ir](/BreakingNESWiki/imgstore/6502/6502_locator_ir.jpg)

The Instruction Register (IR) stores the current operation code, for processing on [decoder](decoder.md). The operation code is loaded into the IR from [predecode logic](predecode.md).

## Transistor Circuit

![ir_tran](/BreakingNESWiki/imgstore/ir_tran.jpg)

The outputs in the schematic are on the left because the decoder is topologically located on the left side.

- IR0 and IR1 are combined into one common line `IR01` to save lines
- IR0 is used only for the 128th decoder line (IMPL) (this operation with IR0 is part of the random logic)
- /IR5 goes additionally to flags and is used in set/clear flags instructions (SEI/CLI, SED/CLD, SEC/CLC)

## Logic

![ir_logic](/BreakingNESWiki/imgstore/ir_logic.jpg)

- During PHI1 the IR value is overloaded from the [Predecode (PD)](predecode.md) latch, but only if the `FETCH` command is active
- During PHI2 the IR is "refreshed" (this is not shown in logic circuit)

It should be noted that an inverted operation code (PD) value is fed to the IR input and is also stored on the latch in an inverted form.

## Optimized Schematics

![18_ir_logic](/BreakingNESWiki/imgstore/6502/ttlworks/18_ir_logic.png)
