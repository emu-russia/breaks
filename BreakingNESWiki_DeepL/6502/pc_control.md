# Program Counter Control

![6502_locator_pc_control](/BreakingNESWiki/imgstore/6502_locator_pc_control.jpg)

The program counter (PC) control circuitry is designed to generate [control commands](context_control.md) to exchange the PC value and the internal buses ADL, ADH and DB.

Nearby is the PC increment circuit, which is discussed in another section on [dispatcher](dispatch.md).

Transistor circuit for obtaining intermediate signals:

![pc_control_trans](/BreakingNESWiki/imgstore/pc_control_trans.jpg)

Output latches and control commands:

![pc_control_commands_tran](/BreakingNESWiki/imgstore/pc_control_commands_tran.jpg)

Inputs:

|Signal|Description|
|---|---|
|BR0|Decoder X73. Additionally modified with the /PRDY signal|
|BR2|Decoder X80|
|BR3|Decoder X93|
|T0|Comes from the cycle counter of short instructions|
|T1|Comes from the PC increment circuit (see [dispatcher](dispatcher.md))|
|ABS/2|Decoder X83. Additionally modified with Push/Pull signal (X129)|
|RTS/5|Decoder X84|
|JSR/5|Decoder X56|
|/ready|Global internal processor readiness signal|

Outputs:

|Signal|Description|
|---|---|
|DL/PCH|Auxiliary output signal for DL/ADH [bus control circuitry](bus_control.md)|
|PC/DB|Auxiliary output signal for the RW Control circuit that is part of the dispatcher|

Control commands:

|Command|Description|
|---|---|
|ADH/PCH|Load ADH bus value into the PCHS latch|
|PCH/PCH|If ADH/PCH is not running, this command is executed (refresh PCH)|
|PCH/ADH|Write the PCH register value to the ADH bus|
|PCH/DB|Write the PCH register value to the DB bus|
|ADL/PCL|Load the ADL bus value into the PCLS latch|
|PCL/PCL|If ADL/PCL is not running, this command is executed (refresh PCL)|
|PCL/ADL|Write the PCL register value to the ADL bus|
|PCL/DB|Write the PCL register value to the DB bus|
