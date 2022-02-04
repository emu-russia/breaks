# DCP abs, x (0xDF 0x00 0x00)

## UB (0xDF), T2 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 0, FETCH: 1, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 0, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 0, /T3: 1, /T4: 1, /T5: 1|
|Decoder|6: OP zpg, X/Y & OP abs, X/Y (T2), 28: T2, 83: ABS/2, 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADD_SB7, ADD_SB06, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, ADH_ABH, ADL_ABL, SB_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xDF|
|PD|0xDF|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0xFE|
|BI|0xFE|
|ADD|0xFE|
|AC|0x0A|
|PCL|0x02|
|PCH|0x02|
|ABL|0x02|
|ABH|0x02|
|DL|0xDF|
|DOR|0xFE|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFE|
|DB|0xFE|
|ADL|0x02|
|ADH|0x02|

![DF_UB_T2_PHI1](/BreakingNESWiki/imgstore/ops/DF_UB_T2_PHI1.jpg)

## UB (0xDF), T2 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 1, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 0, /T3: 1, /T4: 1, /T5: 1|
|Decoder|6: OP zpg, X/Y & OP abs, X/Y (T2), 28: T2, 83: ABS/2, 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|SUMS, PCH_ADH, PCL_ADL, ADH_ABH, ADL_ABL, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xDF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0xFE|
|BI|0xFE|
|ADD|0xFC|
|AC|0x0A|
|PCL|0x03|
|PCH|0x02|
|ABL|0x02|
|ABH|0x02|
|DL|0x00|
|DOR|0xFE|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0x03|
|ADH|0x02|

![DF_UB_T2_PHI2](/BreakingNESWiki/imgstore/ops/DF_UB_T2_PHI2.jpg)

## UB (0xDF), T3 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 1, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 0, /T4: 1, /T5: 1|
|Decoder|42: RIGHT ODD (T3), 86: T3 ANY, 90: RIGHT_ALL (T3), 92: RIGHT ODD (T3), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|X_SB, S_S, DB_ADD, SB_ADD, SUMS, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, ADH_ABH, ADL_ABL, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xDF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x00|
|BI|0x00|
|ADD|0xFC|
|AC|0x0A|
|PCL|0x03|
|PCH|0x02|
|ABL|0x03|
|ABH|0x02|
|DL|0x00|
|DOR|0x00|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0x00|
|DB|0x00|
|ADL|0x03|
|ADH|0x02|

![DF_UB_T3_PHI1](/BreakingNESWiki/imgstore/ops/DF_UB_T3_PHI1.jpg)

## UB (0xDF), T3 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 1, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 0, /T4: 1, /T5: 1|
|Decoder|42: RIGHT ODD (T3), 86: T3 ANY, 90: RIGHT_ALL (T3), 92: RIGHT ODD (T3), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|SUMS, ADD_ADL, ADH_ABH, ADL_ABL, DL_ADH, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xDF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x00|
|BI|0x00|
|ADD|0x00|
|AC|0x0A|
|PCL|0x04|
|PCH|0x02|
|ABL|0x03|
|ABH|0x02|
|DL|0x00|
|DOR|0x00|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0xFC|
|ADH|0xFF|

![DF_UB_T3_PHI2](/BreakingNESWiki/imgstore/ops/DF_UB_T3_PHI2.jpg)

## UB (0xDF), T4 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 1, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 1, /T4: 0, /T5: 1|
|Decoder|71: OP abs,XY (T4), 85: T4 ANY, 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 125: Memory absolute X/Y (T4)|
|Commands|S_S, DB_ADD, Z_ADD, SUMS, ADD_ADL, PCH_PCH, PCL_PCL, ADH_ABH, ADL_ABL, DL_ADH, DL_DB|
|ALU Carry In|1|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xDF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x00|
|BI|0x00|
|ADD|0x00|
|AC|0x0A|
|PCL|0x04|
|PCH|0x02|
|ABL|0x00|
|ABH|0x00|
|DL|0x00|
|DOR|0x00|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0x00|
|ADL|0x00|
|ADH|0x00|

![DF_UB_T4_PHI1](/BreakingNESWiki/imgstore/ops/DF_UB_T4_PHI1.jpg)

## UB (0xDF), T4 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 0, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 1, /T4: 0, /T5: 1|
|Decoder|71: OP abs,XY (T4), 85: T4 ANY, 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 125: Memory absolute X/Y (T4)|
|Commands|SUMS, ADD_SB7, ADD_SB06, SB_ADH|
|ALU Carry In|1|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xDF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x00|
|BI|0x00|
|ADD|0x01|
|AC|0x0A|
|PCL|0x04|
|PCH|0x02|
|ABL|0x00|
|ABH|0x00|
|DL|0x00|
|DOR|0x00|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0x00|
|DB|0xFF|
|ADL|0xFF|
|ADH|0x00|

![DF_UB_T4_PHI2](/BreakingNESWiki/imgstore/ops/DF_UB_T4_PHI2.jpg)

## UB (0xDF), T5 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 0, T5: 1, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 1, /T4: 1, /T5: 0|
|Decoder|106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADD_SB7, ADD_SB06, PCH_PCH, PCL_PCL, SB_ADH|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xDF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x01|
|BI|0xFF|
|ADD|0x01|
|AC|0x0A|
|PCL|0x04|
|PCH|0x02|
|ABL|0x00|
|ABH|0x00|
|DL|0x00|
|DOR|0xFF|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0x01|
|DB|0xFF|
|ADL|0xFF|
|ADH|0x01|

![DF_UB_T5_PHI1](/BreakingNESWiki/imgstore/ops/DF_UB_T5_PHI1.jpg)

## UB (0xDF), T5 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 1, ACRL1: 1, ACRL2: 0, T5: 1, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 1, /T4: 1, /T5: 0|
|Decoder|106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|SUMS, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xDF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x01|
|BI|0xFF|
|ADD|0x00|
|AC|0x0A|
|PCL|0x04|
|PCH|0x02|
|ABL|0x00|
|ABH|0x00|
|DL|0x00|
|DOR|0xFF|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0xFF|
|ADH|0xFF|

![DF_UB_T5_PHI2](/BreakingNESWiki/imgstore/ops/DF_UB_T5_PHI2.jpg)

## UB (0xDF), T7_RMW (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 1, ACRL1: 1, ACRL2: 0, T5: 0, T6: 1, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, PCH_PCH, PCL_PCL, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xDF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0xFF|
|BI|0x00|
|ADD|0x00|
|AC|0x0A|
|PCL|0x04|
|PCH|0x02|
|ABL|0x00|
|ABH|0x00|
|DL|0x00|
|DOR|0x00|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0x00|
|ADL|0xFF|
|ADH|0xFF|

![DF_UB_T7_RMW_PHI1](/BreakingNESWiki/imgstore/ops/DF_UB_T7_RMW_PHI1.jpg)

## UB (0xDF), T7_RMW (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 1, ACRL1: 0, ACRL2: 1, T5: 0, T6: 1, ENDS: 0, ENDX: 0, TRES1: 0, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|SUMS, ADD_SB7, ADD_SB06, SB_DB, DBZ_Z, DB_N|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xDF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0xFF|
|BI|0x00|
|ADD|0xFF|
|AC|0x0A|
|PCL|0x04|
|PCH|0x02|
|ABL|0x00|
|ABH|0x00|
|DL|0x00|
|DOR|0x00|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0x00|
|DB|0x00|
|ADL|0xFF|
|ADH|0xFF|

![DF_UB_T7_RMW_PHI2](/BreakingNESWiki/imgstore/ops/DF_UB_T7_RMW_PHI2.jpg)

## UB (0xDF), T0 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 1, ACRL1: 0, ACRL2: 1, T5: 0, T6: 0, ENDS: 0, ENDX: 0, TRES1: 0, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|34: T0 ANY, 50: CMP (T0), 65: ALL ODD (T0), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADD_SB7, ADD_SB06, PCH_PCH, PCL_PCL, SB_DB, DBZ_Z, DB_N|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xDF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0xFF|
|BI|0xFF|
|ADD|0xFF|
|AC|0x0A|
|PCL|0x04|
|PCH|0x02|
|ABL|0x00|
|ABH|0x00|
|DL|0x00|
|DOR|0xFF|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0xFF|
|ADH|0xFF|

![DF_UB_T0_PHI1](/BreakingNESWiki/imgstore/ops/DF_UB_T0_PHI1.jpg)

## UB (0xDF), T0 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 0, T5: 0, T6: 0, ENDS: 1, ENDX: 1, TRES1: 1, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|34: T0 ANY, 50: CMP (T0), 65: ALL ODD (T0), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|SUMS, PCH_ADH, PCL_ADL, ADH_ABH, ADL_ABL, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xDF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0xFF|
|BI|0xFF|
|ADD|0xFE|
|AC|0x0A|
|PCL|0x04|
|PCH|0x02|
|ABL|0x00|
|ABH|0x00|
|DL|0x00|
|DOR|0xFF|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0x04|
|ADH|0x02|

![DF_UB_T0_PHI2](/BreakingNESWiki/imgstore/ops/DF_UB_T0_PHI2.jpg)

## UB (0xDF), T1 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 0, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 0, T5: 0, T6: 0, ENDS: 1, ENDX: 1, TRES1: 1, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 1, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 116: CMP (T1)|
|Commands|S_S, NDB_ADD, SB_ADD, SUMS, AC_SB, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, ADH_ABH, ADL_ABL, DL_DB|
|ALU Carry In|1|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xDF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x0A|
|BI|0xFF|
|ADD|0xFE|
|AC|0x0A|
|PCL|0x04|
|PCH|0x02|
|ABL|0x04|
|ABH|0x02|
|DL|0x00|
|DOR|0x00|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0x0A|
|DB|0x00|
|ADL|0x04|
|ADH|0x02|

![DF_UB_T1_PHI1](/BreakingNESWiki/imgstore/ops/DF_UB_T1_PHI1.jpg)

## UB (0xDF), T1 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 0, 0/IR: 0, FETCH: 1, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 1, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 1, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 116: CMP (T1)|
|Commands|SUMS, ADD_SB7, ADD_SB06, PCH_ADH, PCL_ADL, ADH_ABH, ADL_ABL, SB_DB, DBZ_Z, DB_N, ACR_C|
|ALU Carry In|1|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xDF|
|PD|0xEA|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x0A|
|BI|0xFF|
|ADD|0x0A|
|AC|0x0A|
|PCL|0x05|
|PCH|0x02|
|ABL|0x04|
|ABH|0x02|
|DL|0xEA|
|DOR|0x00|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFE|
|DB|0xFE|
|ADL|0x05|
|ADH|0x02|

![DF_UB_T1_PHI2](/BreakingNESWiki/imgstore/ops/DF_UB_T1_PHI2.jpg)
