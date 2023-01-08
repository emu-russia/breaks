# ALU Control

![6502_locator_alu_control](/BreakingNESWiki/imgstore/6502/6502_locator_alu_control.jpg)

The [ALU](alu.md) control is designed to generate ALU [control commands](context_control.md).

## Intermediate Signals

|/ROR|SR|AND|CSET|
|---|---|---|---|
|![alu_setup_ror_tran](/BreakingNESWiki/imgstore/6502/alu_setup_ror_tran.jpg)|![alu_setup_sr_tran](/BreakingNESWiki/imgstore/6502/alu_setup_sr_tran.jpg)|![alu_setup_and_tran](/BreakingNESWiki/imgstore/6502/alu_setup_and_tran.jpg)|![alu_setup_cset_tran](/BreakingNESWiki/imgstore/6502/alu_setup_cset_tran.jpg)|

Table of auxiliary and intermediate signals, which are found further in the schematics:

|Signal|Description|
|---|---|
|/ROR|Intermediate signal, used in the ADD/SB7 circuit|
|SR|Intermediate signal|
|AND|Intermediate signal|
|T0|Comes from the cycle counter of short instructions|
|T6 RMW|Comes from the cycle counter of long instructions|
|T7 RMW|Comes from the cycle counter of long instructions|
|/C_OUT|[Flag](flags.md) C value (inverted value)|
|CSET|Intermediate signal ("Carry Set"), used in the main ALU control circuit|
|STK2|Decoder X35|
|RET|Decoder X47|
|SBC0|Decoder X51|
|JSR2|Decoder X48|
|/BR3|Decoder X93 (inverted value). The inversion circuit was lost somewhere in the optimization process.|
|BRK6E|Comes from the [interrupts processing](interrupts.md) circuit|
|STKOP|Comes from [register control](regs_control.md) circuitry|
|/ready|Global internal processor readiness signal|
|INC_SB|Intermediate signal ("Increment SB"), used in the main control circuitry as well as in the [bus control](bus_control.md) circuitry|
|JSR/5|Decoder X56|
|PGX|Comes from the bus control circuitry|
|NOADL|Comes from the bus control circuitry|
|BRFW|Comes from the conditional [branch logic](branch_logic.md)|
|T1|Comes from the PC increment circuit (see [dispatcher](dispatch.md))|
|D_OUT|Flag D value|
|C_OUT|Flag C value|

## ALU Сontrol (Main Part)

The circuit is a mess of gates and 4 latches to generate the input carry for the ALU (control signal `/ACIN`).

![alu_setup_main_tran](/BreakingNESWiki/imgstore/6502/alu_setup_main_tran.jpg)

## BCD Correction Control

BCD correction is applied in the following cases:
- If the BCD mode is enabled with flag D and the current instruction `SBC` (control signal DSATemp)
- If the BCD mode is enabled with flag D and the current instruction `ADC` (control signal DAATemp)

![alu_setup_bcd_tran](/BreakingNESWiki/imgstore/6502/alu_setup_bcd_tran.jpg)

## ADD/SB7

The attentive reader will notice that the processor has support for bit rotation instructions (ROL/ROR). The additional processing associated with these instructions is just handled by this circuit.

![alu_setup_addsb7_tran](/BreakingNESWiki/imgstore/6502/alu_setup_addsb7_tran.jpg)

Logic:

![alu_control_addsb7](/BreakingNESWiki/imgstore/logisim/alu_control_addsb7.jpg)

Optimized schematics:

![27_alu_control_addsb7](/BreakingNESWiki/imgstore/6502/ttlworks/27_alu_control_addsb7.png)

## ALU Control Commands

![alu_control_commands_tran](/BreakingNESWiki/imgstore/6502/alu_control_commands_tran.jpg)

|Command|Description|
|---|---|
|Setting the ALU input values||
|NDB/ADD|Load inverse value from DB bus to the BI latch|
|DB/ADD|Load direct value from DB bus to the BI latch|
|0/ADD|Write 0 to the AI latch|
|SB/ADD|Load a value from the SB bus to the AI latch|
|ADL/ADD|Load a value from the ADL bus to the BI latch|
|ALU operation commands||
|ANDS|Logical AND operation (AI & BI)|
|EORS|Logical XOR operation (AI ^ BI)|
|ORS|Logical OR operation (AI \| BI)|
|SRS|Shift Right|
|SUMS|Summation (AI + BI)|
|Control commands of the intermediate ALU result||
|ADD/SB06|Place the value of the ADD latch on the SB bus (bits 0-6)|
|ADD/SB7|Place the value of the ADD latch on the SB bus (bit 7)|
|ADD/ADL|Place the ADD latch value on the ADL bus|
|Additional signals||
|/ACIN|Input carry|
|/DAA|Perform correction after addition|
|/DSA|Perform correction after subtraction|

## Logic

![alu_control_logisim](/BreakingNESWiki/imgstore/logisim/alu_control_logisim.jpg)

## Optimized Schematics

![28_alu_control_logisim](/BreakingNESWiki/imgstore/6502/ttlworks/28_alu_control_logisim.png)
