# ATX (0xAB 0xAB)

- Illegal opcode (behavior is undefined)
- Size: 2
- Sequence (2 total): T0+T2, T1

## Quick Outline

|T|PHI1 (Set Address)|PHI2 (Read/Write Data)|Notes|
|---|---|---|---|
|T0+T2|![AB_UB_T02_PHI1](/BreakingNESWiki/imgstore/ops/AB_UB_T02_PHI1.jpg)|![AB_UB_T02_PHI2](/BreakingNESWiki/imgstore/ops/AB_UB_T02_PHI2.jpg)|Addr = PC++; MemRead(). Loading an operand in the DL.|
|T1|![AB_UB_T1_PHI1](/BreakingNESWiki/imgstore/ops/AB_UB_T1_PHI1.jpg)|![AB_UB_T1_PHI2](/BreakingNESWiki/imgstore/ops/AB_UB_T1_PHI2.jpg)|Addr = PC++; SB = DL & AC; X = SB; SetFlags(N,Z). MemRead(). See below for details.|

## UB (0xAB), T02 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 0, FETCH: 1, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 0, T6: 0, T7: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 0, /T3: 1, /T4: 1, /T5: 1|
|Decoder|7: LDX STX A<->X S<->X (TX), 14: LDX TAX TSX (T0), 28: T2, 34: T0 ANY, 64: LDA (T0), 65: ALL ODD (T0), 68: TAX (T0), 83: ABS/2, 121: /IR6, 128: IMPL|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADD_SB7, ADD_SB06, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, ADH_ABH, ADL_ABL, SB_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xAB|
|PD|0xAB|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x24|
|BI|0x24|
|ADD|0x24|
|AC|0x12|
|PCL|0x6F|
|PCH|0x02|
|ABL|0x6F|
|ABH|0x02|
|DL|0xAB|
|DOR|0x24|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses||
|SB|0x24|
|DB|0x24|
|ADL|0x6F|
|ADH|0x02|

![AB_UB_T02_PHI1](/BreakingNESWiki/imgstore/ops/AB_UB_T02_PHI1.jpg)

## UB (0xAB), T02 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 0, T6: 0, T7: 0, ENDS: 1, ENDX: 1, TRES1: 1, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 0, /T3: 1, /T4: 1, /T5: 1|
|Decoder|7: LDX STX A<->X S<->X (TX), 14: LDX TAX TSX (T0), 28: T2, 34: T0 ANY, 64: LDA (T0), 65: ALL ODD (T0), 68: TAX (T0), 83: ABS/2, 121: /IR6, 128: IMPL|
|Commands|SUMS, PCH_ADH, PCL_ADL, ADH_ABH, ADL_ABL, SB_DB, DL_DB, DBZ_Z, DB_N|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xAB|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x24|
|BI|0x24|
|ADD|0x48|
|AC|0x12|
|PCL|0x70|
|PCH|0x02|
|ABL|0x6F|
|ABH|0x02|
|DL|0xAB|
|DOR|0x24|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0x70|
|ADH|0x02|

![AB_UB_T02_PHI2](/BreakingNESWiki/imgstore/ops/AB_UB_T02_PHI2.jpg)

## UB (0xAB), T1 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 0, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 0, T6: 0, T7: 0, ENDS: 1, ENDX: 1, TRES1: 1, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 1, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|7: LDX STX A<->X S<->X (TX), 121: /IR6, 128: IMPL|
|Commands|SB_X, S_S, DB_ADD, SB_ADD, SUMS, SB_AC, AC_SB, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, ADH_ABH, ADL_ABL, SB_DB, DL_DB, DBZ_Z, DB_N|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xAB|
|PD|0x00|
|Y|0x00|
|X|0x02|
|S|0xFD|
|AI|0x02|
|BI|0x02|
|ADD|0x48|
|AC|0x02|
|PCL|0x70|
|PCH|0x02|
|ABL|0x70|
|ABH|0x02|
|DL|0xAB|
|DOR|0x02|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses||
|SB|0x02|
|DB|0x02|
|ADL|0x70|
|ADH|0x02|

![AB_UB_T1_PHI1](/BreakingNESWiki/imgstore/ops/AB_UB_T1_PHI1.jpg)

This is where the special magic happens:
- The operand value that is stored on the DL is placed on the DB bus
- The current accumulator value (AC) is put on the SB bus
- The SB and DB buses are multiplexed (SB_DB command) with a conflict. Both buses take the value `DL & AC` according to the "ground wins" rule.
- The resulting value from the now common SB-DB bus is loaded into the X register and back to AC
- The flags Z and N are set according to the value of the common SB-DB bus (DBZ_Z, DB_N commands)

## UB (0xAB), T1 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 0, 0/IR: 0, FETCH: 1, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 0, T6: 0, T7: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 1, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|7: LDX STX A<->X S<->X (TX), 121: /IR6, 128: IMPL|
|Commands|SUMS, ADD_SB7, ADD_SB06, PCH_ADH, PCL_ADL, ADH_ABH, ADL_ABL, SB_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xAB|
|PD|0xEA|
|Y|0x00|
|X|0x02|
|S|0xFD|
|AI|0x02|
|BI|0x02|
|ADD|0x04|
|AC|0x02|
|PCL|0x71|
|PCH|0x02|
|ABL|0x70|
|ABH|0x02|
|DL|0xEA|
|DOR|0x02|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses||
|SB|0x00|
|DB|0x00|
|ADL|0x71|
|ADH|0x02|

![AB_UB_T1_PHI2](/BreakingNESWiki/imgstore/ops/AB_UB_T1_PHI2.jpg)

## NOP (0xEA), T02 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 0, FETCH: 1, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 0, T6: 0, T7: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 0, /T3: 1, /T4: 1, /T5: 1|
|Decoder|28: T2, 34: T0 ANY, 44: INC NOP (TX), 83: ABS/2, 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 128: IMPL|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADD_SB7, ADD_SB06, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, ADH_ABH, ADL_ABL, SB_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xEA|
|PD|0xEA|
|Y|0x00|
|X|0x02|
|S|0xFD|
|AI|0x04|
|BI|0x04|
|ADD|0x04|
|AC|0x02|
|PCL|0x71|
|PCH|0x02|
|ABL|0x71|
|ABH|0x02|
|DL|0xEA|
|DOR|0x04|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses||
|SB|0x04|
|DB|0x04|
|ADL|0x71|
|ADH|0x02|
