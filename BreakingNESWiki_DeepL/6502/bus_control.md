# Bus Control

![6502_locator_bus_control](/BreakingNESWiki/imgstore/6502/6502_locator_bus_control.jpg)

Bus control is most of all "scattered" around the processor surface. It is easiest to describe all the bus [control commands](context_control.md) first, and then to look at the corresponding circuits individually.

Bus control commands:

|Command|Description|
|---|---|
|External address bus control||
|ADH/ABH|Set the high 8 bits of the external address bus, in accordance with the value of the internal bus ADH|
|ADL/ABL|Set the low-order 8 bits of the external address bus, in accordance with the value of the internal bus ADL|
|ALU connection to SB, DB buses||
|AC/DB|Place the AC value on the DB bus|
|SB/AC|Place the value from the SB bus/BCD correction circuit into the accumulator|
|AC/SB|Place the AC value on the SB bus|
|Control of the SB, DB and ADH internal buses||
|SB/DB|Connect the SB and DB buses|
|SB/ADH|Connect SB and ADH buses|
|0/ADH0|Forced to clear the ADH\[0\] bit|
|0/ADH17|Forced to clear the ADH\[1-7\] bits|
|External data bus control||
|DL/ADL|Write the DL value to the ADL bus|
|DL/ADH|Write the DL value to the ADH bus|
|DL/DB|Exchange the value of the DL and the internal bus DB. The direction of the exchange depends on the operating mode of the external data bus (read/write)|

The motive of all the circuits is roughly as follows:
- The control circuits get a lot of input from the decoder and other auxiliary signals
- All circuits are mostly combinatorial (no triggers, just a mess of gates)
- The outputs from the control circuits go to the output latches of the commands to control the lower part of the processor.

## Auxiliary Signals

Circuits for obtaining auxiliary signals:

|NOADL, IND|JSXY|
|---|---|
|![bus_noadl_ind_tran](/BreakingNESWiki/imgstore/6502/bus_noadl_ind_tran.jpg)|![bus_jsxy_tran](/BreakingNESWiki/imgstore/6502/bus_jsxy_tran.jpg)|

In the `IND` circuit the decoder output X90 is additionally modified by the Push/Pull signal (X129).

The other auxiliary and intermediate signals that can be found in the schematics in this section:

|Signal|Description|
|---|---|
|RTS/5|Decoder X84|
|RTI/5|Decoder X26|
|STXY|Comes from [register control circuitry](regs_control.md)|
|BR0|Decoder X73. Additionally modified with the /PRDY signal|
|T6 RMW|Comes from the cycle counter of long instructions|
|T7 RMW|Comes from the cycle counter of long instructions|
|PGX|Output signal from ADL/ABL circuit|
|JSR/5|Decoder X56|
|T2|Decoder X28|
|!PCH/PCH|Comes from the [PC control circuitry](pc_control.md)|
|SBA|The signal comes out of the #SB/ADH circuit, used in the #ADH/ABH circuit|
|/ready|Global internal processor readiness signal|
|BR3|Decoder X93|
|0/ADL0|Comes from the interrupt vector setting circuit|
|AND|Comes from the [ALU control](alu_control.md) circuit|
|STA|Decoder X79|
|STOR|Intermediate signal from the dispatcher|
|SBXY|Comes from a register control circuit (not to be confused with STXY)|
|T1|Comes from the PC increment circuit (see [dispatcher](dispatch.md))|
|BR2|Decoder X80|
|ZTST|Output signal for [flags control](flags_control.md) from SB/DB circuit|
|ACRL2|One of the ACR Latch outputs|
|T0|Comes from the cycle counter of short instructions|
|ABS/2|Decoder X83. Additionally modified with Push/Pull signal (X129)|
|JMP/4|Decoder X101|
|IMPL|Decoder X128. Additionally modified with Push/Pull (X129) and IR0 signals.|
|JSR2|Decoder X48|
|/JSR|Inversion of JSR2 for the register control circuit|
|BRK6E|Comes from the [interrupts processing](interrupts.md) circuit|
|INC_SB|Comes from the ALU control circuit|
|DL/PCH|Comes from the PC control circuitry|

The signals are arranged in the order they appear in the schematics.

## External Address Bus Control

Circuits for the generation of intermediate signals:

|#ADL/ABL|#ADH/ABH (1)|#ADH/ABH (2)|
|---|---|---|
|![bus_adlabl_tran](/BreakingNESWiki/imgstore/6502/bus_adlabl_tran.jpg)|![bus_adhabh_tran1](/BreakingNESWiki/imgstore/6502/bus_adhabh_tran1.jpg)|![bus_adhabh_tran2](/BreakingNESWiki/imgstore/6502/bus_adhabh_tran2.jpg)|

The first piece of the #ADH/ABH circuit is to the right of flag B, the second piece is in the interrupt address generation circuitry. The #ADH/ABH signal connects directly between these two pieces.

The output latches of the ADL/ABL and ADH/ABH control commands:

![bus_addr_bus_commands_tran](/BreakingNESWiki/imgstore/6502/bus_addr_bus_commands_tran.jpg)

## ALU Connection to SB, DB

Circuits for the generation of intermediate signals:

|#AC/DB|#SB/AC, #AC/SB|
|---|---|
|![bus_acdb_tran](/BreakingNESWiki/imgstore/6502/bus_acdb_tran.jpg)|![bus_acsb_tran](/BreakingNESWiki/imgstore/6502/bus_acsb_tran.jpg)|

AC/DB, SB/AC, AC/SB control command output latches:

![bus_alu_commands_tran](/BreakingNESWiki/imgstore/6502/bus_alu_commands_tran.jpg)

## SB, DB, ADH Control

Circuits for generating intermediate signals (for 0/ADH0 you get the control command at once):

|#SB/DB (also #0/ADH17)|0/ADH0|#SB/ADH|
|---|---|---|
|![bus_control_tran1](/BreakingNESWiki/imgstore/6502/bus_control_tran1.jpg)|![bus_0adh0_tran](/BreakingNESWiki/imgstore/6502/bus_0adh0_tran.jpg)|![bus_sbadh_tran](/BreakingNESWiki/imgstore/6502/bus_sbadh_tran.jpg)|

SB/DB, SB/ADH, 0/ADH17 control command output latches:

![bus_sb_commands_tran](/BreakingNESWiki/imgstore/6502/bus_sb_commands_tran.jpg)

(0/ADH0 above)

## External Data Bus Control

Circuits for the generation of intermediate signals:

|#DL/ADL|#DL/DB (1)|#DL/DB (2)|
|---|---|---|
|![bus_dladl_tran](/BreakingNESWiki/imgstore/6502/bus_dladl_tran.jpg)|![bus_dldb_tran](/BreakingNESWiki/imgstore/6502/bus_dldb_tran.jpg)|![bus_dldb_tran2](/BreakingNESWiki/imgstore/6502/bus_dldb_tran2.jpg)|

The first piece of #DL/DB circuitry is next to the ACR Latch, the second piece is right inside the ALU control circuitry. The #DL/DB signal connects directly between these two pieces.

DL/ADL, DL/ADH, DL/DB control command output latches:

![bus_data_latch_commands_tran](/BreakingNESWiki/imgstore/6502/bus_data_latch_commands_tran.jpg)

## Logic

![bus_control_logisim](/BreakingNESWiki/imgstore/logisim/bus_control_logisim.jpg)

## Optimized Schematics

![7_bus_control_logisim](/BreakingNESWiki/imgstore/6502/ttlworks/7_bus_control_logisim.png)
