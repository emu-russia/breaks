# Flags Control

![6502_locator_flags_control](/BreakingNESWiki/imgstore/6502_locator_flags_control.jpg)

The flag control circuits are divided into two parts for convenience:
- Intermediate control signals from the decoder (opcode selection)
- Flag control signals

As you can guess, the purpose of the circuit is to control [processor flags](flags.md), depending on the currently executed instruction.

I think it makes sense to show here the relevant part of the wonderful 6502 circuit made by Donald F. Hanson:

![flags_control_hanson](/BreakingNESWiki/imgstore/flags_control_hanson.jpg)

(The missing `0/V` signal has been corrected in the schematic)

## Opcode Selection

|![flags_control_tran1](/BreakingNESWiki/imgstore/flags_control_tran1.jpg)|![flags_control_tran2](/BreakingNESWiki/imgstore/flags_control_tran2.jpg)|![flags_control_tran3](/BreakingNESWiki/imgstore/flags_control_tran3.jpg)|
|---|---|---|

Input signals:

- /T0: Processor executes cycle T0 of the current instruction
- /T1X: Processor executes T1 cycle of the current instruction
- T6: Processor executes T6 cycle of current instruction

Output signals:

|Signal|Decoder outputs|Dedicated instructions|
|---|---|---|
|!POUT|98,99|Working with flags outward (saving context after interrupt, `PHP` instruction)|
|/CSI|108|Instructions `CLI`, `SEI`|
|BIT1|109|Instruction `BIT`, cycle T1|
|X110|110|The 110th decoder output (instructions `CLC`, `SEC`), for convenience is left in these circuits. It just goes on to the main flag control circuitry.|
|AVR/V|112|Instructions `ADC`, `SBC`. This signal is the control signal for [flag V](flags.md)|
|/ARIT|107,112,116-119|Matrix of comparison (`CMP`, `CPX`, `CPY`) and shift instructions (`ASL`, `ROL`) where flags are used|
|BIT0|113|Instruction `BIT`, cycle T0|
|!PIN|114,115|Working with flags inside (context loading after `RTI`, instruction `PLP`)|
|/CSD|120|Instructions `CLD`, `SED`|
|CLV|127|Instruction `CLV`|

All of these control signals (except `AVR/V`) are intermediate signals and are not used anywhere else except for the flag control circuitry.

## Flags Control

|![flags_control_tran1](/BreakingNESWiki/imgstore/flags_control_tran4.jpg)|![flags_control_tran1](/BreakingNESWiki/imgstore/flags_control_tran5.jpg)|
|---|---|

Input signals:

|Signal|Purpose|
|---|---|
|/CSI|see above|
|X110|see above|
|!POUT|see above|
|BIT1|see above|
|ZTST|Comes from SB/DB [bus control circuitry](bus_control.md)|
|/ARIT|see above|
|SR|Shift instruction from [ALU control logic](alu_control.md)|
|/ready|Global internal processor readiness signal|
|!PIN|see above|
|BIT0|see above|
|/CSD|see above|
|CLV|see above|

[Flag](flags.md) control output signals:

|Signal|Flag|Purpose|
|---|---|---|
|IR5/C|C|Change the value of the flag according to the IR5 bit|
|ACR/C|C|Change the value of the flag according to the ACR value|
|DB/C|C|Change the value of the flag according to DB0 bit|
|DBZ/Z|Z|Change the value of the flag according to the /DBZ value|
|IR5/I|I|Change the value of the flag according to the IR5 bit|
|IR5/D|D|Change the value of the flag according to the IR5 bit|
|DB/V|V|Change the value of the flag according to DB6 bit|
|0/V|V|Clear flag V|
|DB/N|N|Change the value of the flag according to DB7 bit|
|P/DB|All|Place the value of the flags register P on the DB bus|
|DB/P|All|Place the DB bus value on the flag register P|

The control signal `1/V` is obtained by the input contact `SO` and is not shown here.
