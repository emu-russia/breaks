# Core6502 HDL

MOS 6502 implementation on Verilog.

Status: Verify

![mos6502](/HDL/Design/mos6502/mos6502.png)

## Verification status (issue #1337)

Work in progress. Current state:

- All Core6502 modules elaborate and simulate under Icarus 14 (devel) (`-D ICARUS`).
- Module testbenches in `HDL/Framework/Icarus/mos6502/*_test.v` compile and run.
- Full-core harnesses: `klaus_test.v` (Klaus Dormann functional suite) and
  `instr_test.v` + `Scripts/make_instr_test.py` (small instruction-level checks).
  Run them with e.g. `iverilog -D ICARUS -o klaus_test.run ../../../Common/*.v
  ../../../Core6502/*.v klaus_test.v && vvp klaus_test.run`.

Known defect (blocks full-core verification):

- The core never loads the low byte of a memory-sourced program counter into
  PCL. Consequence: after reset the PC becomes `04FF` instead of the reset
  vector (`00 04` at $FFFC/$FFFD are read correctly, but PCL is loaded with the
  precharged bus value FF), and `JMP abs`/BRK/IRQ/RTS vector loads misbehave the
  same way (the core loops on a `JMP $0400` trampoline). Root cause is being
  chased in the DL->ADL->PCL transfer timing (`bus_control.v` DL_ADL decode,
  `pc_control.v` ADL_PCL/DL_PCH terms and the decoder X81/X82 outputs) against
  the Logisim schematic.

## Bops

All control signals for the bottom are combined on a common bus and are called `bops` (Bottom Ops). List:

|Original signal name|Bop Index|Operation|
|---|---|---|
|Y_SB|0|Y => SB|
|SB_Y|1|SB => Y|
|X_SB|2|X => SB|
|SB_X|3|SB => X|
|S_ADL|4|S => ADL|
|S_SB|5|S => SB|
|SB_S|6|SB => S|
|S_S|7|The S/S command is active if the SB/S command is inactive (refresh S)|
|NDB_ADD|8|~DB => BI|
|DB_ADD|9|DB => BI|
|Z_ADD|10|0 => AI|
|SB_ADD|11|SB => AI|
|ADL_ADD|12|ADL => BI|
|ANDS|13|AI & BI|
|EORS|14|AI ^ BI|
|ORS|15|AI \| BI|
|SRS|16|>>= 1|
|SUMS|17|AI + BI|
|ADD_SB7|18|ADD\[7\] => SB\[7\]|
|ADD_SB06|19|ADD\[0-6\] => SB\[0-6\]|
|ADD_ADL|20|ADD => ADL|
|SB_AC|21|SB => AC|
|AC_SB|22|AC => SB|
|AC_DB|23|AC => DB|
|ADH_PCH|24|ADH => PCH|
|PCH_PCH|25|If ADH/PCH is not performed, this command is performed (refresh PCH)|
|PCH_ADH|26|PCH => ADH|
|PCH_DB|27|PCH => DB|
|ADL_PCL|28|ADL => PCL|
|PCL_PCL|29|If ADL/PCL is not performed, this command is performed (refresh PCL)|
|PCL_ADL|30|PCL => ADL|
|PCL_DB|31|PCL => DB|
|ADH_ABH|32|ADH => ABH|
|ADL_ABL|33|ADL => ABL|
|Z_ADL0|34|Reset some of the ADL bus bits (0). Used to set the interrupt vector.|
|Z_ADL1|35|Reset some of the ADL bus bits (1). Used to set the interrupt vector.|
|Z_ADL2|36|Reset some of the ADL bus bits (2). Used to set the interrupt vector.|
|Z_ADH0|37|Reset some of the ADH bus bits (0)|
|Z_ADH17|38|Reset some of the ADH bus bits (1-7)|
|SB_DB|39|SB <=> DB, connect the buses|
|SB_ADH|40|SB <=> ADH, connect the buses|
|DL_ADL|41|DL => ADL|
|DL_ADH|42|DL => ADH|
|DL_DB|43|DL <=> DB|
