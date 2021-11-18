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
- The control signal `#1/PC` (perform PC increment) comes to the PCL0 bit
- PCLC (PCL Carry): Carry from the lowest 8 bits (PC\[0-7\]) to the highest (PC\[8-15\])
- PCL connects to two buses: ADL and DB
- PCL/PCL is used when PCL is not connected to any bus (to maintain the current state)
- Each digit contains two latches (input latch `PCLSx` and output latch `PCLx`) which implement the counter logic

## PCH

Represents the top 8 most significant bits of PC.

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
