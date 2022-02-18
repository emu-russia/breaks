# INC abs

```
    NOP
    INC   $4014
    NOP
```

|T|PHI1|PHI2|R/W Mode|Notes|
|---|---|---|---|---|
|T2|![EE_INC_T2_PHI1](/BreakingNESWiki/imgstore/ops/EE_INC_T2_PHI1.jpg)|![EE_INC_T2_PHI2](/BreakingNESWiki/imgstore/ops/EE_INC_T2_PHI2.jpg)|Read|Read operand (AddrLow)|
|T3|![EE_INC_T3_PHI1](/BreakingNESWiki/imgstore/ops/EE_INC_T3_PHI1.jpg)|![EE_INC_T3_PHI2](/BreakingNESWiki/imgstore/ops/EE_INC_T3_PHI2.jpg)|Read|Read operand (AddrHigh)|
|T4|![EE_INC_T4_PHI1](/BreakingNESWiki/imgstore/ops/EE_INC_T4_PHI1.jpg)|![EE_INC_T4_PHI2](/BreakingNESWiki/imgstore/ops/EE_INC_T4_PHI2.jpg)|Read|Read mem abs|
|T5|![EE_INC_T5_PHI1](/BreakingNESWiki/imgstore/ops/EE_INC_T5_PHI1.jpg)|![EE_INC_T5_PHI2](/BreakingNESWiki/imgstore/ops/EE_INC_T5_PHI2.jpg)|Write| |
|T0|![EE_INC_T0_PHI1](/BreakingNESWiki/imgstore/ops/EE_INC_T0_PHI1.jpg)|![EE_INC_T0_PHI2](/BreakingNESWiki/imgstore/ops/EE_INC_T0_PHI2.jpg)|Write| |
|T1|![EE_INC_T1_PHI1](/BreakingNESWiki/imgstore/ops/EE_INC_T1_PHI1.jpg)|![EE_INC_T1_PHI2](/BreakingNESWiki/imgstore/ops/EE_INC_T1_PHI2.jpg)|Read|Fetch next opcode|

## INC (0xEE), T2 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 0, FETCH: 1, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 1, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 0, /T3: 1, /T4: 1, /T5: 1|
|Decoder|28: T2, 31: ALU absolute (T2), 44: INC NOP (TX), 83: ABS/2, 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADD_SB7, ADD_SB06, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, ADH_ABH, ADL_ABL, SB_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xEE|
|PD|0xEE|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0xFE|
|BI|0xFE|
|ADD|0xFE|
|AC|0x0A|
|PCL|0x02|
|PCH|0xC0|
|ABL|0x02|
|ABH|0xC0|
|DL|0xEE|
|DOR|0xFE|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFE|
|DB|0xFE|
|ADL|0x02|
|ADH|0xC0|

![EE_INC_T2_PHI1](/BreakingNESWiki/imgstore/ops/EE_INC_T2_PHI1.jpg)

## INC (0xEE), T2 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 1, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 0, /T3: 1, /T4: 1, /T5: 1|
|Decoder|28: T2, 31: ALU absolute (T2), 44: INC NOP (TX), 83: ABS/2, 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|SUMS, PCH_ADH, PCL_ADL, ADH_ABH, ADL_ABL, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xEE|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0xFE|
|BI|0xFE|
|ADD|0xFC|
|AC|0x0A|
|PCL|0x03|
|PCH|0xC0|
|ABL|0x02|
|ABH|0xC0|
|DL|0x14|
|DOR|0xFE|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0x03|
|ADH|0xC0|

![EE_INC_T2_PHI2](/BreakingNESWiki/imgstore/ops/EE_INC_T2_PHI2.jpg)

## INC (0xEE), T3 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 1, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 0, /T4: 1, /T5: 1|
|Decoder|44: INC NOP (TX), 86: T3 ANY, 90: RIGHT_ALL (T3), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 122: Memory absolute (T3)|
|Commands|S_S, DB_ADD, Z_ADD, SUMS, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, ADH_ABH, ADL_ABL, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xEE|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x00|
|BI|0x14|
|ADD|0xFC|
|AC|0x0A|
|PCL|0x03|
|PCH|0xC0|
|ABL|0x03|
|ABH|0xC0|
|DL|0x14|
|DOR|0x14|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0x14|
|ADL|0x03|
|ADH|0xC0|

![EE_INC_T3_PHI1](/BreakingNESWiki/imgstore/ops/EE_INC_T3_PHI1.jpg)

## INC (0xEE), T3 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 1, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 0, /T4: 1, /T5: 1|
|Decoder|44: INC NOP (TX), 86: T3 ANY, 90: RIGHT_ALL (T3), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 122: Memory absolute (T3)|
|Commands|SUMS, ADD_ADL, ADH_ABH, ADL_ABL, DL_ADH|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xEE|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x00|
|BI|0x14|
|ADD|0x14|
|AC|0x0A|
|PCL|0x04|
|PCH|0xC0|
|ABL|0x03|
|ABH|0xC0|
|DL|0x40|
|DOR|0x14|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0x14|
|ADH|0xFF|

![EE_INC_T3_PHI2](/BreakingNESWiki/imgstore/ops/EE_INC_T3_PHI2.jpg)

## INC (0xEE), T4 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 1, T5: 1, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 1, /T4: 0, /T5: 1|
|Decoder|44: INC NOP (TX), 85: T4 ANY, 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADD_ADL, PCH_PCH, PCL_PCL, ADH_ABH, ADL_ABL, DL_ADH|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xEE|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0xFF|
|BI|0xFF|
|ADD|0x14|
|AC|0x0A|
|PCL|0x04|
|PCH|0xC0|
|ABL|0x14|
|ABH|0x40|
|DL|0x40|
|DOR|0xFF|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0x14|
|ADH|0x40|

![EE_INC_T4_PHI1](/BreakingNESWiki/imgstore/ops/EE_INC_T4_PHI1.jpg)

## INC (0xEE), T4 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 1, ACRL1: 1, ACRL2: 0, T5: 1, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 1, /T4: 0, /T5: 1|
|Decoder|44: INC NOP (TX), 85: T4 ANY, 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|SUMS, ADD_ADL, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xEE|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0xFF|
|BI|0xFF|
|ADD|0xFE|
|AC|0x0A|
|PCL|0x04|
|PCH|0xC0|
|ABL|0x14|
|ABH|0x40|
|DL|0x40|
|DOR|0xFF|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0x14|
|ADH|0xFF|

![EE_INC_T4_PHI2](/BreakingNESWiki/imgstore/ops/EE_INC_T4_PHI2.jpg)

## INC (0xEE), T5 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 1, ACRL1: 1, ACRL2: 0, T5: 0, T6: 1, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 1, /T4: 1, /T5: 0|
|Decoder|44: INC NOP (TX), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|S_S, DB_ADD, Z_ADD, SUMS, ADD_ADL, PCH_PCH, PCL_PCL, DL_DB|
|ALU Carry In|1|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xEE|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x00|
|BI|0x40|
|ADD|0xFE|
|AC|0x0A|
|PCL|0x04|
|PCH|0xC0|
|ABL|0x14|
|ABH|0x40|
|DL|0x40|
|DOR|0x40|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0xFF|
|DB|0x40|
|ADL|0xFE|
|ADH|0xFF|

![EE_INC_T5_PHI1](/BreakingNESWiki/imgstore/ops/EE_INC_T5_PHI1.jpg)

## INC (0xEE), T5 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 1, ACRL1: 0, ACRL2: 1, T5: 0, T6: 1, ENDS: 0, ENDX: 0, TRES1: 0, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 0, /T2: 1, /T3: 1, /T4: 1, /T5: 0|
|Decoder|44: INC NOP (TX), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|SUMS, ADD_SB7, ADD_SB06, SB_DB, DBZ_Z, DB_N|
|ALU Carry In|1|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xEE|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x00|
|BI|0x40|
|ADD|0x41|
|AC|0x0A|
|PCL|0x04|
|PCH|0xC0|
|ABL|0x14|
|ABH|0x40|
|DL|0x40|
|DOR|0x40|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 1|
|Buses||
|SB|0x40|
|DB|0x40|
|ADL|0xFF|
|ADH|0xFF|

![EE_INC_T5_PHI2](/BreakingNESWiki/imgstore/ops/EE_INC_T5_PHI2.jpg)

## INC (0xEE), T0 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 1, ACRL1: 0, ACRL2: 1, T5: 0, T6: 0, ENDS: 0, ENDX: 0, TRES1: 0, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|34: T0 ANY, 44: INC NOP (TX), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADD_SB7, ADD_SB06, PCH_PCH, PCL_PCL, SB_DB, DBZ_Z, DB_N|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xEE|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x41|
|BI|0x41|
|ADD|0x41|
|AC|0x0A|
|PCL|0x04|
|PCH|0xC0|
|ABL|0x14|
|ABH|0x40|
|DL|0x40|
|DOR|0x41|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses||
|SB|0x41|
|DB|0x41|
|ADL|0xFF|
|ADH|0xFF|

![EE_INC_T0_PHI1](/BreakingNESWiki/imgstore/ops/EE_INC_T0_PHI1.jpg)

## INC (0xEE), T0 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 0, T5: 0, T6: 0, ENDS: 1, ENDX: 1, TRES1: 1, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 0, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|34: T0 ANY, 44: INC NOP (TX), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|SUMS, PCH_ADH, PCL_ADL, ADH_ABH, ADL_ABL, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0xEE|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0x41|
|BI|0x41|
|ADD|0x82|
|AC|0x0A|
|PCL|0x04|
|PCH|0xC0|
|ABL|0x14|
|ABH|0x40|
|DL|0x41|
|DOR|0x41|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0x04|
|ADH|0xC0|

![EE_INC_T0_PHI2](/BreakingNESWiki/imgstore/ops/EE_INC_T0_PHI2.jpg)

## INC (0xEE), T1 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 0, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 0, T5: 0, T6: 0, ENDS: 1, ENDX: 1, TRES1: 1, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 1, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|44: INC NOP (TX), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, ADH_ABH, ADL_ABL, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xEE|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0xFF|
|BI|0x41|
|ADD|0x82|
|AC|0x0A|
|PCL|0x04|
|PCH|0xC0|
|ABL|0x04|
|ABH|0xC0|
|DL|0x41|
|DOR|0x41|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses||
|SB|0xFF|
|DB|0x41|
|ADL|0x04|
|ADH|0xC0|

![EE_INC_T1_PHI1](/BreakingNESWiki/imgstore/ops/EE_INC_T1_PHI1.jpg)

## INC (0xEE), T1 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 0, 0/IR: 0, FETCH: 1, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 0, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 0, BRK6E: 0, BRK7: 1, DORES: 0, /DONMI: 1|
|Extra Cycle Counter|T1: 1, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|44: INC NOP (TX), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX)|
|Commands|SUMS, ADD_SB7, ADD_SB06, PCH_ADH, PCL_ADL, ADH_ABH, ADL_ABL, SB_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|1|
|Regs||
|IR|0xEE|
|PD|0xEA|
|Y|0x00|
|X|0x00|
|S|0xFD|
|AI|0xFF|
|BI|0x41|
|ADD|0x40|
|AC|0x0A|
|PCL|0x05|
|PCH|0xC0|
|ABL|0x04|
|ABH|0xC0|
|DL|0xEA|
|DOR|0x41|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses||
|SB|0x00|
|DB|0x00|
|ADL|0x05|
|ADH|0xC0|

![EE_INC_T1_PHI2](/BreakingNESWiki/imgstore/ops/EE_INC_T1_PHI2.jpg)

## Next PHI1 (NOP)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 0, FETCH: 1, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 0, T5: 0, T6: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 1|
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
|X|0x00|
|S|0xFD|
|AI|0x40|
|BI|0x40|
|ADD|0x40|
|AC|0x0A|
|PCL|0x05|
|PCH|0xC0|
|ABL|0x05|
|ABH|0xC0|
|DL|0xEA|
|DOR|0x40|
|Flags|C: 0, Z: 0, I: 1, D: 0, B: 1, V: 0, N: 0|
|Buses||
|SB|0x40|
|DB|0x40|
|ADL|0x05|
|ADH|0xC0|
