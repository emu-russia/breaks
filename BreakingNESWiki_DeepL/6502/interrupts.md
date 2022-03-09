# Interrupt Processing

![6502_locator_intr](/BreakingNESWiki/imgstore/6502/6502_locator_intr.jpg)

Interrupt processing includes the following circuits:
- NMI edge detection
- Cycle counter 6-7 for interrupt handling
- Setting the low-order bits of the interrupt vector address (ADL0-3)
- Circuit for issuing internal signal `DORES`.
- B Flag

The common designation for the 6502 interrupt handling process is called "BRK-sequence".

Three signals `/NMIP`, `/IRQP` and `RESP` come to the input of the circuits from the corresponding input pads.

## NMI Processing

Transistor circuit (includes cycle counter 6-7 and NMI edge detector):

![intr_cycles_nmip_tran](/BreakingNESWiki/imgstore/intr_cycles_nmip_tran.jpg)

## Interrupt vector address and Reset FF

Transistor circuit:

![intr_resp_address_tran](/BreakingNESWiki/imgstore/intr_resp_address_tran.jpg)

The circuit for getting the control signal `DORES` ("Do Reset") (which is binned to all other internals) is combined here with the interrupt vector setting circuit to save space.

## B Flag

Transistor circuit:

![intr_b_flag_tran](/BreakingNESWiki/imgstore/intr_b_flag_tran.jpg)

## Logic

Interrupt handling schematic:

![int_control_logisim](/BreakingNESWiki/imgstore/logisim/int_control_logisim.jpg)

To handle interrupts an additional circuit is required to generate cycles 6 and 7 (because they do not come from the decoder) (control signals `BRK6E` and `BRK7`). And the control signal BRK6E ("Break Cycle 6 End") starts during PHI2 of cycle 6 and ends during PHI1 of cycle 7. This is done to determine the edge of the /NMI signal.

The detection of the /NMI edge is done by a classic edge detection circuit based on two RS triggers.

The /RES signal is additionally stored on RESET FLIP/FLOP, because it is required for other random logic circuits (particularly for special control of the R/W pin).

The arrival of any interrupt is reflected on flag B, the output of which (`B_OUT`) forces the processor to execute a BRK instruction (operation code 0x00). This way the developers have unified the handling of all interrupts.

The last small circuit forms the address (or vector) of the interrupts (control signals 0/ADL0, 0/ADL1 and 0/ADL2), which control the lowest 3 bits of the address bus.

Schematic for setting the address of the interrupt handler:

![int_address_logisim](/BreakingNESWiki/imgstore/logisim/int_address_logisim.jpg)

## Optimized Schematics

![17_interrupt_logic](/BreakingNESWiki/imgstore/6502/ttlworks/17_interrupt_logic.png)
