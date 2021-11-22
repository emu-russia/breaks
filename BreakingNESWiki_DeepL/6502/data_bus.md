# Data Bus

![6502_locator_data](/BreakingNESWiki/imgstore/6502_locator_data.jpg)

The circuits for working with the external data bus consist of 8 identical pieces:

![6502_data_bit_tran](/BreakingNESWiki/imgstore/6502_data_bit_tran.jpg)

(The circuit is shown for bit 0, the rest are the same)

- DOR: The DOR latch stores the output value to be placed on the D0-D7 bus pins. If RD=1 the complementary output lines with DOR are cut off, so the whole output part becomes floating.
- DL: The DL latch stores the input value
- Next to the control signal `DL/DB` you can see the precharge transistor for the internal bus DB

Control signals:
- DL/ADL: Place the DL latch value on the internal ADL bus
- DL/ADH: Place the DL latch value on the internal ADH bus
- DL/DB: In read mode (RD=1), the value from the DL latch is placed on the internal DB bus. In write mode (RD=0) the value from the DB bus is placed on the DOR latch

The external data bus (pins D0-D7) is also directly connected to the input of the [predecode circuit](predecode.md).

## WR Latch

From the R/W control circuit, the latch circuit receives a control signal `WR`. The circuit outputs a control signal `RD` which controls the direction of the external data bus.

![6502_wr_latch_tran](/BreakingNESWiki/imgstore/6502_wr_latch_tran.jpg)
