# Registers Control

![6502_locator_regs_control](/BreakingNESWiki/imgstore/6502/6502_locator_regs_control.jpg)

Most likely this control circuit will be observed first, so I will write here: be prepared to see a large number of intermediate signals in the control circuits, which can come sometimes from all other parts of the random logic. A summary table of all the intermediate signals can be found in the main section with the [random logic overview](random_logic.md).

The register control circuit is responsible for generating [control commands](context_control.md) to exchange registers with the internal buses.

![regs_control](/BreakingNESWiki/imgstore/6502/regs_control.jpg)

Inputs:

|Signal|Description|
|---|---|
|X0-X26|Outputs from the decoder|
|/JSR2|Intermediate signal from the [bus control circuit](bus_control.md)|
|STK2|Just an auxiliary signal from another part of the decoder (X35)|
|STOR|Auxiliary signal from the [dispatcher circuit](dispatch.md)|
|/ready|Global processor readiness signal|

Outputs:

|Signal|Description|
|---|---|
|SBXY|Intermediate signal for [bus control circuitry](bus_control.md). This signal is actually in inverse logic (`#SBXY`)|
|STXY|Intermediate signal for bus control circuitry|
|STKOP|Intermediate signal ("Stack Operation") for the [ALU control circuit](alu_control.md)|
|#Y/SB|Intermediate signal to latch, to obtain a Y/SB command|
|#X/SB|Intermediate signal to latch, to obtain a X/SB command|
|#SB/X|Intermediate signal to latch, to obtain a SB/X command|
|#SB/Y|Intermediate signal to latch, to obtain a SB/Y command|
|#S/SB|Intermediate signal to latch, to obtain a S/SB command|
|#S/ADL|Intermediate signal to latch, to obtain a S/ADL command|
|#SB/S|Intermediate signal to latch, to obtain a SB/S command|
|BRK5|Output X22 from decoder. Used to obtain the `STKOP` signal and also goes to the [interrupt circuitry](interrupts.md)|
|RTI/5|Output X26 from decoder. Used to obtain `STKOP` and `NOADL` signals|

The `TXS` (X13) signal is used within this circuit and does not go outside.

The intermediate signals from the register control circuitry go to the input of the control command latches:

![regs_control_commands_tran](/BreakingNESWiki/imgstore/6502/regs_control_commands_tran.jpg)

Register control commands:

|Command|Description|
|---|---|
|X/SB|Place the value of register X on the SB bus|
|Y/SB|Place the value of register Y on the SB bus|
|SB/X|Place the SB bus value on the X register|
|SB/Y|Place the SB bus value on the Y register|
|S/SB|Place the value of register S on the SB bus|
|S/ADL|Place the value of register S on the ADL bus|
|SB/S|Place the SB bus value on the S register|
|S/S|Refresh the value of the S register. The S/S control command is obtained by a complement of the SB/S signal (active when the SB/S command is inactive)|

## Logic

![regs_control_logisim](/BreakingNESWiki/imgstore/logisim/regs_control_logisim.jpg)

## Optimized Schematics

![26_regs_control_logisim](/BreakingNESWiki/imgstore/6502/ttlworks/26_regs_control_logisim.png)
