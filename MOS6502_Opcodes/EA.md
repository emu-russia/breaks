# NOP (0xEA)

```
	nop
	nop
	nop
```

|T|PHI1|PHI2|R/W Mode|Notes|
|---|---|---|---|---|
|T0+T2|![EA_NOP_T02_PHI1](/BreakingNESWiki/imgstore/ops/EA_NOP_T02_PHI1.jpg)|![EA_NOP_T02_PHI2](/BreakingNESWiki/imgstore/ops/EA_NOP_T02_PHI2.jpg)|Read | |
|T1|![EA_NOP_T1_PHI1](/BreakingNESWiki/imgstore/ops/EA_NOP_T1_PHI1.jpg)|![EA_NOP_T1_PHI2](/BreakingNESWiki/imgstore/ops/EA_NOP_T1_PHI2.jpg)|Read | |

## NOP (0xEA), T02 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 0, FETCH: 1, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 0, T6: 0, T7: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 0, /T3: 1, /T4: 1, /T5: 1|
|Decoder|28: T2, 34: T0 ANY, 44: INC NOP (TX), 83: ABS/2, 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 128: IMPL|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADD_SB7, ADD_SB06, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, ADH_ABH, ADL_ABL, SB_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs|IR=0xEA, PD=0xEA, Y=0x00, X=0x00, S=0xFD, AI=0xFE, BI=0xFE, ADD=0xFE, AC=0x00|
|PCL|0x05|
|PCH|0xC0|
|ABL|0x05|
|ABH|0xC0|
|DL|0xEA|
|DOR|0xFE|
|Flags|C: 0, Z: 1, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses|SB=0xFE, DB=0xFE, ADL=0x05, ADH=0xC0|

![EA_NOP_T02_PHI1](/BreakingNESWiki/imgstore/ops/EA_NOP_T02_PHI1.jpg)

## NOP (0xEA), T02 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 1, T6: 0, T7: 0, ENDS: 1, ENDX: 1, TRES1: 1, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 0, /T3: 1, /T4: 1, /T5: 1|
|Decoder|28: T2, 34: T0 ANY, 44: INC NOP (TX), 83: ABS/2, 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 128: IMPL|
|Commands|SUMS, PCH_ADH, PCL_ADL, ADH_ABH, ADL_ABL|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs|IR=0xEA, PD=0x00, Y=0x00, X=0x00, S=0xFD, AI=0xFE, BI=0xFE, ADD=0xFC, AC=0x00|
|PCL|0x05|
|PCH|0xC0|
|ABL|0x05|
|ABH|0xC0|
|DL|0xEA|
|DOR|0xFE|
|Flags|C: 0, Z: 1, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses|SB=0xFF, DB=0xFF, ADL=0x05, ADH=0xC0|

![EA_NOP_T02_PHI2](/BreakingNESWiki/imgstore/ops/EA_NOP_T02_PHI2.jpg)

## NOP (0xEA), T1 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 0, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 1, T6: 0, T7: 0, ENDS: 1, ENDX: 1, TRES1: 1, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 1, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|44: INC NOP (TX), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 128: IMPL|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, ADH_ABH, ADL_ABL|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs|IR=0xEA, PD=0x00, Y=0x00, X=0x00, S=0xFD, AI=0xFF, BI=0xFF, ADD=0xFC, AC=0x00|
|PCL|0x05|
|PCH|0xC0|
|ABL|0x05|
|ABH|0xC0|
|DL|0xEA|
|DOR|0xFF|
|Flags|C: 0, Z: 1, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses|SB=0xFF, DB=0xFF, ADL=0x05, ADH=0xC0|

![EA_NOP_T1_PHI1](/BreakingNESWiki/imgstore/ops/EA_NOP_T1_PHI1.jpg)

## NOP (0xEA), T1 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 0, 0/IR: 0, FETCH: 1, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 1, T6: 0, T7: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 1, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|44: INC NOP (TX), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 128: IMPL|
|Commands|SUMS, ADD_SB7, ADD_SB06, PCH_ADH, PCL_ADL, ADH_ABH, ADL_ABL, SB_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs|IR=0xEA, PD=0xEA, Y=0x00, X=0x00, S=0xFD, AI=0xFF, BI=0xFF, ADD=0xFE, AC=0x00|
|PCL|0x06|
|PCH|0xC0|
|ABL|0x05|
|ABH|0xC0|
|DL|0xEA|
|DOR|0xFF|
|Flags|C: 0, Z: 1, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses|SB=0xFC, DB=0xFC, ADL=0x06, ADH=0xC0|

![EA_NOP_T1_PHI2](/BreakingNESWiki/imgstore/ops/EA_NOP_T1_PHI2.jpg)

## Next NOP T0+2 PHI1

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 0, FETCH: 1, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 1, T6: 0, T7: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 0, /T3: 1, /T4: 1, /T5: 1|
|Decoder|28: T2, 34: T0 ANY, 44: INC NOP (TX), 83: ABS/2, 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 128: IMPL|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADD_SB7, ADD_SB06, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, ADH_ABH, ADL_ABL, SB_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs|IR=0xEA, PD=0xEA, Y=0x00, X=0x00, S=0xFD, AI=0xFE, BI=0xFE, ADD=0xFE, AC=0x00|
|PCL|0x06|
|PCH|0xC0|
|ABL|0x06|
|ABH|0xC0|
|DL|0xEA|
|DOR|0xFE|
|Flags|C: 0, Z: 1, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses|SB=0xFE, DB=0xFE, ADL=0x06, ADH=0xC0|
