# Control Commands

![6502_locator_controls](/BreakingNESWiki/imgstore/6502/6502_locator_controls.jpg)

"Control Commands" is the conventional name for the large number of control signals that go from the top of the processor to the bottom and control the context (registers, buses) and ALU.

![6502_controls_tran1](/BreakingNESWiki/imgstore/6502_controls_tran1.jpg)

![6502_controls_tran2](/BreakingNESWiki/imgstore/6502_controls_tran2.jpg)

![6502_controls_tran3](/BreakingNESWiki/imgstore/6502_controls_tran3.jpg)

![6502_controls_tran4](/BreakingNESWiki/imgstore/6502_controls_tran4.jpg)

The control commands for the flag register are discussed in the corresponding section on [flag management](flags_control.md), since they do not go beyond the top of the processor.

Each control signal usually contains an output latch and sometimes a special "cutoff" transistor that turns the signal off at a certain half-cycle (usually some of the signals are turned off during PHI2). This is because the internal buses are pre-charged during PHI2, and the registers are usually "refreshed" at that time.

Most signals have names like `A/B` which means that the line "connects" `A` to `B`. For example SB/X means that the value from the internal bus SB is placed in register X.

## List

All commands are discussed in more detail in their respective sections. The summary table is just for reference.

|Name|PHI1|PHI2|Description|
|---|---|---|---|
|Register control commands||||
|Y/SB|√| |Y => SB|
|SB/Y|√| |SB => Y|
|X/SB|√| |X => SB|
|SB/X|√| |SB => X|
|S/ADL|√|√|S => ADL|
|S/SB|√|√|S => SB|
|SB/S|√| |SB => S|
|S/S|√| |The S/S command is active if the SB/S command is inactive. This command simply "refreshes" the current state of the S register.|
|ALU control commands||||
|NDB/ADD|√| |~DB => BI|
|DB/ADD|√| |DB => BI|
|0/ADD|√| |0 => AI|
|SB/ADD|√| |SB => AI|
|ADL/ADD|√| |ADL => BI|
|/ACIN|√|√|ALU input carry. The ALU also returns the result of carry (`ACR`) and overflow (`AVR`)|
|ANDS|√|√|AI & BI|
|EORS|√|√|AI ^ BI|
|ORS|√|√|AI | BI|
|SRS|√|√|>>= 1|
|SUMS|√|√|AI + BI|
|/DAA|√|√|0: Perform BCD correction after addition|
|/DSA|√|√|0: Perform BCD correction after subtraction|
|ADD/SB7|√|√|ADD\[7\] => SB\[7\]|
|ADD/SB06|√|√|ADD\[0-6\] => SB\[0-6\]|
|ADD/ADL|√|√|ADD => ADL|
|SB/AC|√| |SB => AC|
|AC/SB|√| |AC => SB|
|AC/DB|√| |AC => DB|
|Program counter (PC) control commands||||
|#1/PC|√|√|0: Increment the program counter|
|ADH/PCH|√| |ADH => PCH|
|PCH/PCH|√| |If ADH/PCH is not performed, this command is performed (refresh PCH)|
|PCH/ADH|√|√|PCH => ADH|
|PCH/DB|√|√|PCH => DB|
|ADL/PCL|√| |ADL => PCL|
|PCL/PCL|√| |If ADL/PCL is not performed, this command is performed (refresh PCL)|
|PCL/ADL|√|√|PCL => ADL|
|PCL/DB|√|√|PCL => DB|
|Bus control commands||||
|ADH/ABH|√|√|ADH => ABH|
|ADL/ABL|√|√|ADL => ABL|
|0/ADL0, 0/ADL1, 0/ADL2|√|√|Reset some of the ADL bus bits. Used to set the interrupt vector.|
|0/ADH0, 0/ADH17|√|√|Reset some of the ADH bus bits|
|SB/DB|√|√|SB <=> DB, connect the two buses|
|SB/ADH|√|√|SB <=> ADH|
|DL latch control commands||||
|DL/ADL|√|√|DL => ADL|
|DL/ADH|√|√|DL => ADH|
|DL/DB|√|√|DL <=> DB|

## ADD/SB7

Be careful, all output values are inverse latch values, except for `ADD/SB7`.

## PHI2 Pullup

On the left side is a small circuit to pull up PHI2 (which is used by a lot of cutoff transistors, so it must be quite powerful):

![phi2_pullup_tran](/BreakingNESWiki/imgstore/phi2_pullup_tran.jpg)

It doesn't carry any logical meaning, but it looks cool.

## Command Priority

Although in a real processor all commands are "executed" at the same time, it is still possible to outline some priority that the developers have laid down.

The commands on the bottom of the 6502, in order of execution:

PHI1 "Set Address and R/W Mode":

- Loading on the bus from DL: DL_DB, DL_ADL, DL_ADH
- Registers to the SB bus: Y_SB, X_SB, S_SB
- Saving flags on the DB bus: P_DB
- ADD saving on SB/ADL: ADD_SB7, ADD_SB06, ADD_ADL
- Saving AC: AC_SB, AC_DB
- Saving of old stack pointer value to ADL bus: S_ADL
- Increment PC: n_1PC
- Saving PC to bus: PCL_ADL, PCH_ADH, PCL_DB, PCH_DB
- Bus multiplexing: SB_DB, SB_ADH
- Constant generator: Z_ADL0, Z_ADL1, Z_ADL2, Z_ADH0, Z_ADH17
- Loading ALU operands: NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD
- BCD correction via SB bus: SB_AC
- Loading flags: DB_P, DBZ_Z, DB_N, IR5_C, DB_C, IR5_D, IR5_I, DB_V, Z_V, ACR_C, AVR_V
- Loading registers: SB_X, SB_Y, SB_S / S_S
- Load PC from bus or keep old value: ADH_PCH/PCH_PCH, ADL_PCL/PCL_PCL
- Saving DB to DOR
- Set external bus address: ADH_ABH, ADL_ABL

PHI2 "Read/Write Data":

- Loading the DL with a value from the external data bus
- Registers on SB bus: S_SB
- Saving flags to the DB bus: P_DB
- ALU operation: ANDS, EORS, ORS, SRS, SUMS, n_ACIN, n_DAA, n_DSA
- ADD saving on SB/ADL: ADD_SB7, ADD_SB06, ADD_ADL
- Saving old stack pointer value to ADL bus: S_ADL
- Increment PC: n_1PC (PC is incremented in this half-cycle)
- Saving PC to bus: PCL_ADL, PCH_ADH, PCL_DB, PCH_DB
- Bus multiplexing: SB_DB, SB_ADH
- Constant generator: Z_ADL0, Z_ADL1, Z_ADL2, Z_ADH0, Z_ADH17
- Loading flags: DB_P, DBZ_Z, DB_N, IR5_C, DB_C, IR5_D, IR5_I, DB_V, Z_V, ACR_C, AVR_V
- Setting external data bus from DOR: If WR = 1
