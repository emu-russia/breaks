# Registers

![6502_locator_regs](/BreakingNESWiki/imgstore/6502_locator_regs.jpg)

The X and Y registers are used for index addressing. Register S is a stack pointer and the stack is located at addresses 0x100 ... 0x1FF (on the first page).

Schematically the X, Y and S registers consist of 8 identical chunks (bits):

![regs_tran](/BreakingNESWiki/imgstore/regs_tran.jpg)

(In the schematic above, replace SB0 and ADL0 with SBx and ADLx for the remaining register bits)

Each register bit is based on a trigger, loading and unloading of values on the buses is done by [control signals](context_control.md):
- Y/SB: Place the value of the register Y on the SB bus
- SB/Y: Load the Y register value from the SB bus
- X/SB: Place the value of the register X on the SB bus
- SB/X: Load the X register value from the SB bus
- S/ADL: Place the value of register S on the ADL bus
- S/SB: Place the S register value onto the SB bus
- SB/S: Load the S register value from the SB bus
- S/S: Refresh S register, active when SB/S = 0

## Logic

![regs_logic](/BreakingNESWiki/imgstore/regs_logic.jpg)

- During PHI1 the X and Y registers output their value to the SB bus / are overloaded with new values from the SB bus.
- The S register has an input latch and an output latch. During PHI1 the value from the output latch is placed on the SB or ADL buses and the input latch is either loaded with a new value from the SB bus or refreshed from the output latch (S/S).
- During PHI2 the X and Y registers "store" their old value as the control signals disconnect them from the bus.
- The S register simply outputs its value to the S or ADL bus during PHI2. The input latch is overridden because the exchange commands are disabled during PHI2.

The SB and ADL buses are precharged during PHI2. This is done because it takes longer to "charge" the bus than to "discharge" it. Therefore, when the bus is not needed - it is precharged, so that it does not have "floating" values.
If the value placed on the bus is 1, then the bus is already prepared ("charged") in advance. If the value placed on the bus is 0, then the bus is "discharged" to ground.

In modern processors the task of precharging the bus is done by dedicated standard cells called Bus Keeper.

In the transistor schematic above you can only see the transistors to charge the SB bus (located in the circuit for the S register bits). The transistors to precharge the ADL bus are scattered next to the program counter (PC).
