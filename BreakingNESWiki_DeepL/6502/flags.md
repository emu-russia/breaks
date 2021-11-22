# Flags

![6502_locator_flags](/BreakingNESWiki/imgstore/6502_locator_flags.jpg)

The flags (bits of the P register) are in "scattered" form, as several circuits of the upper part of the processor.

The flags are controlled by the [flags control](flags_control.md) circuit.

Flag B is treated separately in the section on [interrupt handling](interrupts.md). Topologically it is also located in another part of the processor.

## C Flag

![flag_c_tran](/BreakingNESWiki/imgstore/flag_c_tran.jpg)

- IR5/C: Change the flag value according to the IR5 bit (applies during execution of the `SEC` and `CLC` instructions)
- ACR/C: Change the flag value according to the ACR value
- DB/C: Change the value of the flag according to the bit DB0
- /IR5: Inverted IR5 value
- /DB0: Input value from DB bus, in inverted form
- ACR: Result of a carry from the ALU
- /C_OUT: Output value of flag C, in inverted form

## D Flag

![flag_d_tran](/BreakingNESWiki/imgstore/flag_d_tran.jpg)

- IR5/D: Change the flag value according to the IR5 bit (applied during execution of `SED` and `CLD` instructions)
- DB/P: Common control signal, place the DB bus value on the flag register P
- /IR5: IR5 bit value, in inverted form
- /DB3: Input value from the DB bus, in inverted form
- /D_OUT: Output value of flag D, in inverted form

## I Flag

![flag_i_tran](/BreakingNESWiki/imgstore/flag_i_tran.jpg)

- IR5/I: Change the flag value according to the IR5 bit (applied during execution of `SEI` and `CLI` instructions)
- DB/P: Common control signal, place the DB bus value on the flag register P
- /IR5: IR5 bit value, in inverted form
- /DB2: Input value from the DB bus, in inverted form
- /I_OUT: Output value of flag I, in inverted form. This signal goes to two places: to the interrupt processing circuit and to the circuit for exchanging flag register values with the DB bus (below).

## N Flag

![flag_n_tran](/BreakingNESWiki/imgstore/flag_n_tran.jpg)

- DB/N: Change the flag value according to DB7
- /DB7: Input value from DB bus, in inverted form
- /N_OUT: Output value of flag N, in inverted form

## V Flag

![flag_v_tran](/BreakingNESWiki/imgstore/flag_v_tran.jpg)

- 0/V: Clear flag V (applies during execution of `CLV` instructions)
- 1/V: Set flag V. Forced flag setting is done by the `SO` pin.
- AVR/V: Change the value of the flag according to the AVR value
- DB/V: Change the flag value according to DB6
- AVR: Overflow result from the ALU
- SO: Input value from pin `SO`
- /DB6: Input value from DB bus, in inverted form
- /V_OUT: Output value of flag V, in inverted form

## Z Flag

![flag_z_tran](/BreakingNESWiki/imgstore/flag_z_tran.jpg)

- DBZ/Z: Change the flag value according to the /DBZ value
- DB/P: Common control signal, place the DB bus value on the flag P register
- /DBZ: Control signal from the flag exchange circuit with the DB bus (check that all bits of the DB bus are 0)
- /DB1: Input value from the DB bus, in inverted form
- /Z_OUT: Output value of flag Z, in inverted form

## Flags I/O

![flags_io_tran](/BreakingNESWiki/imgstore/flags_io_tran.jpg)

- C_OUT: Flag C value in direct form, used in [ALU control circuit](alu_control.md) (in the circuit to form the `ADD/SB7` signal)
- D_OUT: Flag D value in direct form, used in the ALU control circuit (to form BCD correction signals DAA/DSA)
- P/DB: Place the P flag register value on the DB bus
- /DB0-7: The value of the DB bus bits, in inverted form. It is fed to the input of the corresponding bits of the P register.
- /DBZ: Check that all DB bus bits are 0 (i.e. checking the value to 0). It is used by the Z flag.

Correspondence of the bits of the DB bus and the flag register P:

|DB Bit|Flag|
|---|---|
|0|C|
|1|Z|
|2|I|
|3|D|
|4|B|
|5|-|
|6|V|
|7|N|

Flag 5 is not used. The DB5 bit is not changed (not connected) when saving the register P to the DB bus. However, the value of the DB5 bit is checked by the `/DBZ` control signal (to compare the value on the DB bus with zero).
