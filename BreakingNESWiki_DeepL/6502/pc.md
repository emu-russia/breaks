# Program Counter (PC)

![6502_locator_pc](/BreakingNESWiki/imgstore/6502_locator_pc.jpg)

Because of the 8-bit nature of the processor its instruction counter is divided into two 8-bit halves: PCL (Program Counter Low) and PCH (Program Counter High).

The PCH is also divided into two halves: the low part of the bits (0-3) and the high part (4-7).

## PCL

Represents the low 8 least significant bits of PC.

|PCL 0-3|PCL 4-7|
|---|---|
|![pcl03_tran](/BreakingNESWiki/imgstore/pcl03_tran.jpg)|![pcl47_tran](/BreakingNESWiki/imgstore/pcl47_tran.jpg)|

- The circuits alternate for even and odd bits because an optimization known as an inverted carry chain is used
- The control signal `#1/PC` (0: perform PC increment) comes to the PCL0 bit
- PCLC (PCL Carry): Carry from the lowest 8 bits (PC\[0-7\]) to the highest (PC\[8-15\])
- PCL connects to two buses: ADL and DB
- PCL/PCL is used when PCL is not connected to any bus (to maintain the current state)
- Each bit contains two latches (input latch `PCLSx` and output latch `PCLx`) which implement the counter logic

## PCH

Represents the top 8 most significant bits of PC.

:warning: 
The circuits for the even bits (0, 2, ...) of the PCH repeat the circuits for the odd bits (1, 3, ...) of the PCL.
Similarly, circuits for odd bits (1, 3, ...) of PCH repeat circuits for even bits (0, 2, ...) of PCL.

|PCH 0-3|PCH 4-7|
|---|---|
|![pch03_tran](/BreakingNESWiki/imgstore/pch03_tran.jpg)|![pch47_tran](/BreakingNESWiki/imgstore/pch47_tran.jpg)|

The circuit marked as "patch" to form the `PCHC` is actually between the `ADL/PCL` and `#1/PC` control outputs.

- The basic principles of PCH are the same as PCL, but PCH is divided into two halves: the lower half (PCH0-3) and the higher half (PCH4-7)
- PCHC (PCH Carry): Carry from the lowermost to the highestermost PCH half
- The PCH connects to two buses: ADH and DB
- PCH/PCH is used when the PCH is not connected to any bus (to maintain the current state)

## ADL/ADH Precharge

In between the PC bits you can find transistors for precharge of the ADL and ADH buses:

![adl_adh_precharge_tran](/BreakingNESWiki/imgstore/adl_adh_precharge_tran.jpg)

(The image shows the precharge transistors for ADH4 and ADL5. The others are similar)

## Logic

It makes sense to show only the bit schematics (the circuitry alternates between even and odd PCL/PCH bits).

This circuit is used, for example, in PCL0 or PCH1:

![pc_even_bit_logisim](/BreakingNESWiki/imgstore/pc_even_bit_logisim.jpg)

This circuit is used, for example, in PCL1 or PCH0:

![pc_odd_bit_logisim](/BreakingNESWiki/imgstore/pc_odd_bit_logisim.jpg)

For these circuits to work correctly in the simulator, FF uses a posedge trigger for the PCL/PCH register.
