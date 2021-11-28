# Random Logic

![6502_locator_random](/BreakingNESWiki/imgstore/6502_locator_random.jpg)

The name has nothing to do with random numbers, it simply reflects the essence of randomly scattered circuits here and there.

This logic is the thinking organ of the processor and completely determines its behavior when processing and executing instructions.

From the hardware point of view, the random logic is a "handmade" product of [MOS](.../MOS.md) engineers, which is a mess of transistors and wires. Therefore, it would be more correct to use the name "chaotic logic" instead of random logic.

There is no need to give a full-size transistor circuit here, because it will be easier to master it by component parts.

Below you can see all the function blocks of the random logic:
- [Register control](regs_control.md)
- [ALU control](alu_control.md)
- [Program counter (PC) control](pc_control.md)
- [Bus control](bus_control.md)
- [Execution logic (dispatch)](dispatch.md)
- [Flags control logic](flags_control.md)
- [Flags](flags.md)
- [Conditional branch logic](branch_logic.md)

## Principle of Operation

In general, the operation of the logic is quite complex (did you think I would say simple again? :smiley:):
- The execution logic (dispatch) conducts the work of the entire processor. It determines when to terminate an instruction and also controls the PC increment and the cycle counter. Additionally it includes a processor readiness circuit (RDY) which is controlled by the RDY pin.
- After the execution logic has started executing the next instruction - the code of that instruction as well as the current cycle is fed to the decoder
- Depending on the results of decoding the control circuitry of registers, ALU, PC and buses give outward to the lower part special [control commands](context_control.md)
- Additionally, the behavior of the processor is affected by its flags as well as interrupt handling logic. And flags are also affected by executable instructions.

All this is closely coupled to control the lower part of the processor, where its context (registers), ALU and communication with the outside world via buses are located.

## Auxiliary Signals

This section contains a table of auxiliary signals exchanged between all parts of the random logic (for reference):

|Name|From|To|Description|
|---|---|---|---|
|BR2|Decoder|PC Control, PC Increment|Branch T2|
|BR3|Decoder|PC Control, PC Increment|Branch T3|
|BRFW|Branch Logic, ALU Control|PC Control|Branch forward (whenever taken)|
|BRK5|Decoder|Interrupts, Regs Control|Used to obtain the `STKOP` signal and also goes into the [interrupt handling](interrupts.md) circuit|
|/BRTAKEN|Branch Logic|PC Control|Branch taken|
|JSR2|Decoder|Bus Control|To obtain the `JSXY` signal and other bus control circuits|
|/JSR2|Bus Control|Regs Control|Intermediate signal, JSR2 inversion|
|RTI/5|Decoder|Regs Control, ALU Control|Used to obtain `STKOP` and `NOADL` signals|
|SBXY|Regs Control|Bus Control|Intermediate signal|
|STK2|Decoder|Regs Control, ALU Control|Auxiliary signal from decoder (X35)|
|STKOP|Regs Control|ALU Control|Intermediate signal|
|STOR|Dispatcher|Regs Control, ALU Control, RW Control|Intermediate signal|
|STXY|Regs Control|Bus Control|Intermediate signal|

Do not look for any sacred meaning in the auxiliary signals - just take them as intermediate values of combinatorial logic.
