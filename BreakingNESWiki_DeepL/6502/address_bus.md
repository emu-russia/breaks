# Address Bus

![6502_locator_addr](/BreakingNESWiki/imgstore/6502/6502_locator_addr.jpg)

Although the 6502 communicates with the outside world on a 16-bit address bus, but because the processor is 8-bit in nature, the address bus is internally divided into two 8-bit halves: an upper (ADH) and a lower (ADL).

The internal ADH/ADL address bus connects to the external 16-bit bus (pins A0-A15) through registers ABH/ABL, which contain the last written value (address that has been set).

The address bus is unidirectional. It can only be controlled by the 6502.

Transistor circuit of the lower bits of the ABL (0-2):

![abl02_tran](/BreakingNESWiki/imgstore/6502/abl02_tran.jpg)

(The schematic is the same for ABL1 and ABL2 bits)

The remaining ABL bits (3-7):

![abl37_tran](/BreakingNESWiki/imgstore/6502/abl37_tran.jpg)

ABH bits:

![abh_tran](/BreakingNESWiki/imgstore/6502/abh_tran.jpg)

Control commands:

- 0/ADL0, 0/ADL1, 0/ADL2: The lower 3 bits of the ADL bus can be forced to zero by commands when setting [interrupts vector](interrupts.md)
- ADL/ABL: Place the value of the internal ADL bus on the ABL register
- ADH/ABH: Place the ADH internal bus value on the ABH register

## Circuit Flow

Consider the behavior of the circuit when ADL = 0:

![abl_flow_tran](/BreakingNESWiki/imgstore/6502/abl_flow_tran.jpg)

- The flip/flop of the ABL bit is organized on two inverters (not2 and not3) with not2 acting simultaneously as a DLatch (whose input Enable is connected to PHI2)
- PHI2: FF is "refreshed" in this half-step.
- PHI1: In this half-step the old FF value is "cut off" by the PHI2 tristate (located to the left of not2) and the new FF value is loaded from the ADL bus (inverted, see not1) but only if an ADL/ABL command is active
- The output from not2 organizes the final generation of the output value for the external address bus. This part of the circuit contains an inverter not3 to form the FF and also an inverter not4 which controls the amplifier "comb" of the Ax contacts

## Logic

On the logic circuits PHI2 is not used, and FF organized on two inverters is replaced by a regular trigger.

![abl02_logisim](/BreakingNESWiki/imgstore/logisim/abl02_logisim.jpg)

![abl_logisim](/BreakingNESWiki/imgstore/logisim/abl_logisim.jpg)

![abh_logisim](/BreakingNESWiki/imgstore/logisim/abh_logisim.jpg)

## Optimized Schematics

![0_abl02_tran](/BreakingNESWiki/imgstore/6502/ttlworks/0_abl02_tran.png)
