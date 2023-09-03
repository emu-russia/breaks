# Pinout

The study of any integrated circuit begins with the pinout.

![6502_pads_map](/BreakingNESWiki/imgstore/6502/6502_pads_map.jpg)

![6502_pinout](/BreakingNESWiki/imgstore/6502/6502_pinout.png)

|Name|Direction|Description|
|---|---|---|
|VCC| => 6502     |Power +5 V|
|VSS| 6502 =>     |Ground|
|/NMI| => 6502  |Non-maskable interrupt signal, active low|
|/IRQ| => 6502  |Maskable interrupt signal, active low|
|/RES| => 6502  |Reset signal, active low|
|PHI0| => 6502 |Reference clock signal|
|PHI1| 6502 =>  |First half-cycle, processor in `Set address+RW` mode|
|PHI2| 6502 => |Second half-cycle, processor in `Read/Write Data` mode|
|RDY| => 6502 |Processor Ready (1: ready)|
|SO| => 6502 |Forced setting of the overflow flag (V)|
|R/W| 6502 => |Data bus direction (R/W=1: processor reads data, R/W=0: processor writes)|
|SYNC| 6502 => |The processor is on cycle T1 (opcode fetch)|
|A0-A15| 6502 => |Address bus|
|D0-D7| 6502 <=> |Data bus (bidirectional)|
|N.C.| -- |Not connected|

## VDD/VSS

From the official datasheet we know that the operating range of VDD = +5.0 volts +/- 5%.

## Clock Generator

The clock signals are described in a separate section (see [clock generator](clock.md)).

## /NMI, /IRQ, /RES

![intpads_trans](/BreakingNESWiki/imgstore/6502/intpads_trans.jpg)

Each terminal circuitry contains a FF where the interrupt arrival event is stored. The FF value corresponds to the control signals `/NMIP`, `/IRQP` and `RESP` (the value from FF for the /RES terminal is output as active-high value).

The "P" in the name of the control signals stands for "Pad" (bonding pad).

:warning: Note that the `Q` output is used for NMI and IRQ FF, and the `#Q` output is used for RES FF. The FF circuitry features cyclically closed AOI-21 elements.

![inf_ff](/BreakingNESWiki/imgstore/6502/inf_ff.png)

## RDY

|![rdy_tran](/BreakingNESWiki/imgstore/6502/rdy_tran.jpg)|![rdy_nice](/BreakingNESWiki/imgstore/6502/rdy_nice.jpg)|
|---|---|

The RDY pin goes to the internal `RDY` signal and also through the DLATCH delay chain as the `/PRDY` ("Previous Ready") signal.
/PRDY goes to the [decoder](decoder.md) input `Branch T0`.

The RDY pin can be used to temporarily suspend the processor, e.g. while an external device performs a DMA.

## SYNC

|![sync_tran](/BreakingNESWiki/imgstore/6502/sync_tran.jpg)|![sync_nice](/BreakingNESWiki/imgstore/6502/sync_nice.jpg)|
|---|---|

The SYNC signal comes from the internal T1 signal (opcode fetch).

## SO

![so_tran](/BreakingNESWiki/imgstore/6502/so_tran.jpg)

The internal signal `SO` is fed to the [flag V](flags.md) input to process the control signal `1/V`.

## R/W

![rw_tran](/BreakingNESWiki/imgstore/6502/rw_tran.jpg)

The `WR` signal comes from [dispatcher](dispatch.md) and defines the operating mode of the processor (WR:1 - processor writes data, WR:0 - processor reads data).

## Address Bus

See [Address Bus](address_bus.md).

## Data Bus

See [Data Bus](data_bus.md).

## Optimized Schematics

![19_pads](/BreakingNESWiki/imgstore/6502/ttlworks/19_pads.png)
