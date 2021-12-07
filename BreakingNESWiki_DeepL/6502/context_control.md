# Control Commands

![6502_locator_controls](/BreakingNESWiki/imgstore/6502_locator_controls.jpg)

"Control Commands" is the conventional name for the large number of control signals that go from the top of the processor to the bottom and control the context (registers, buses, and ALU).

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
|Y/SB|✓| |Y => SB|
|SB/Y|✓| |SB => Y|
|X/SB|✓| |X => SB|
|SB/X|✓| |SB => X|
|S/ADL|✓|✓|S => ADL|
|S/SB|✓|✓|S => SB|
|SB/S|✓| |SB => S|
|S/S|✓| |The S/S command is active if the SB/S command is inactive. This command simply "refreshes" the current state of the S register.|
|ALU control commands||||
|NDB/ADD|✓| |~DB => BI|
|DB/ADD|✓| |DB => BI|
|0/ADD|✓| |0 => AI|
|SB/ADD|✓| |SB => AI|
|ADL/ADD|✓| |ADL => BI|
|/ACIN|✓|✓|ALU input carry. The ALU also returns the result of carry (`ACR`) and overflow (`AVR`)|
|ANDS|✓|✓|AI & BI|
|EORS|✓|✓|AI ^ BI|
|ORS|✓|✓|AI | BI|
|SRS|✓|✓|>>= 1|
|SUMS|✓|✓|AI + BI|
|/DAA|✓|✓|0: Perform BCD correction after addition|
|/DSA|✓|✓|0: Perform BCD correction after subtraction|
|ADD/SB7|✓|✓|ADD\[7\] => SB\[7\]|
|ADD/SB06|✓|✓|ADD\[0-6\] => SB\[0-6\]|
|ADD/ADL|✓|✓|ADD => ADL|
|SB/AC|✓| |SB => AC|
|AC/SB|✓| |AC => SB|
|AC/DB|✓| |AC => DB|
|Program counter (PC) control commands||||
|#1/PC|✓|✓|0: Increment the program counter|
|ADH/PCH|✓| |ADH => PCH|
|PCH/PCH|✓| |If ADH/PCH is not performed, this command is performed (refresh PCH)|
|PCH/ADH|✓|✓|PCH => ADH|
|PCH/DB|✓|✓|PCH => DB|
|ADL/PCL|✓| |ADL => PCL|
|PCL/PCL|✓| |If ADL/PCL is not performed, this command is performed (refresh PCL)|
|PCL/ADL|✓|✓|PCL => ADL|
|PCL/DB|✓|✓|PCL => DB|
|Bus control commands||||
|ADH/ABH|✓|✓|ADH => ABH|
|ADL/ABL|✓|✓|ADL => ABL|
|0/ADL0, 0/ADL1, 0/ADL2|✓|✓|Reset some of the ADL bus bits. Used to set the interrupt vector.|
|0/ADH0, 0/ADH17|✓|✓|Reset some of the ADH bus bits|
|SB/DB|✓|✓|SB <=> DB, connect the two buses|
|SB/ADH|✓|✓|SB <=> ADH|
|DL latch control commands||||
|DL/ADL|✓|✓|DL => ADL|
|DL/ADH|✓|✓|DL => ADH|
|DL/DB|✓|✓|DL <=> DB|

## PHI2 Pullup

On the left side is a small circuit to pull up PHI2 (which is used by a lot of cutoff transistors, so it must be quite powerful):

![phi2_pullup_tran](/BreakingNESWiki/imgstore/phi2_pullup_tran.jpg)

It doesn't carry any logical meaning, but it looks cool.
