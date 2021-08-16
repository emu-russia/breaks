==== Управление PC (активна только во время PHI2) ====

Схема управления program counter-ом активна только во время PHI2, все выходные сигналы никому не нужны во время PHI1.

{{6502:random:pc_control_trans.jpg}}

Схема принимает на вход :
  * Выходы с декодера, я немного подвинул их к схеме, чтобы было понятней и подписал номера выходов.
  * T0, T1: текущий такт инструкции
  * /ready

Выходные контрольные линии :
  * 8 [[6502:control|команд управления]] PC, которые идут на соответствующие выходные защелки : ADH/PCH, PCH/PCH, PCH/ADH, PCH/DB, ADL/PCL, PCL/PCL, PCL/ADL, PCL/DB
  * DL/PCH, идёт на схему DL/ADH. Сигнал также не нужен во время PHI1.
  * PC/DB, идёт на схему R/W control. Сигнал также не нужен во время PHI1.

В состав схемы входит вездесущая защелка NotReady1, а также небольшая линия задержки, для организации последовательной выдачи PCH и PCL на шину данных DB.

==== Симуляция ====

Из симуляции пока толком не понятно как работает схема. Я сделал тестовый прогон по всем опкодам, вот наиболее интересные результаты:

```
BRK
    PHI1 T0: PCH/PCH PCL/PCL 
    PHI2 T0: 
    PHI1 T1: ADH/PCH ADL/PCL 
    PHI2 T1: PCH/ADH PCL/ADL 
    PHI1 T2: ADH/PCH PCH/ADH PCL/ADL ADL/PCL 
    PHI2 T2: PCH/DB 
    PHI1 T3: PCH/PCH PCH/DB PCL/PCL 
    PHI2 T3: PCL/DB 
    PHI1 T4: PCH/PCH PCL/DB PCL/PCL 
    PHI2 T4: 
    PHI1 T5: PCH/PCH PCL/PCL 
    PHI2 T5: 
    PHI1 T6: PCH/PCH PCL/PCL 
    PHI2 T6: 
    
BEQ rel
    PHI1 T0: PCH/PCH PCL/PCL 
    PHI2 T0: PCL/ADL 
    PHI1 T1: ADH/PCH PCL/ADL ADL/PCL 
    PHI2 T1: PCH/ADH PCL/ADL 
    PHI1 T2: ADH/PCH PCH/ADH PCL/ADL ADL/PCL 
    PHI2 T2: PCH/ADH PCL/ADL 
    PHI1 T3: ADH/PCH PCH/ADH PCL/ADL ADL/PCL 
    PHI2 T3: PCH/ADH 
    PHI1 T4: ADH/PCH PCH/ADH ADL/PCL 
    PHI2 T4: 
    PHI1 T5: PCH/PCH PCL/PCL 
    PHI2 T5: 
    PHI1 T6: PCH/PCH PCL/PCL 
    PHI2 T6: 
    
JSR abs
    PHI1 T0: PCH/PCH PCL/PCL 
    PHI2 T0: 
    PHI1 T1: ADH/PCH ADL/PCL 
    PHI2 T1: PCH/ADH PCL/ADL 
    PHI1 T2: ADH/PCH PCH/ADH PCL/ADL ADL/PCL 
    PHI2 T2: 
    PHI1 T3: PCH/PCH PCL/PCL 
    PHI2 T3: PCH/DB 
    PHI1 T4: PCH/PCH PCH/DB PCL/PCL 
    PHI2 T4: PCL/DB 
    PHI1 T5: PCH/PCH PCL/DB PCL/PCL 
    PHI2 T5: PCH/ADH PCL/ADL 
    PHI1 T6: PCH/PCH PCH/ADH PCL/ADL ADL/PCL 
    PHI2 T6: 
    
RTS
    PHI1 T0: PCH/PCH PCL/PCL 
    PHI2 T0: PCH/ADH PCL/ADL 
    PHI1 T1: ADH/PCH PCH/ADH PCL/ADL ADL/PCL 
    PHI2 T1: PCH/ADH PCL/ADL 
    PHI1 T2: ADH/PCH PCH/ADH PCL/ADL ADL/PCL 
    PHI2 T2: 
    PHI1 T3: PCH/PCH PCL/PCL 
    PHI2 T3: 
    PHI1 T4: PCH/PCH PCL/PCL 
    PHI2 T4: 
    PHI1 T5: PCH/PCH PCL/PCL 
    PHI2 T5: 
    PHI1 T6: ADH/PCH ADL/PCL 
    PHI2 T6:         
    
JMP abs
    PHI1 T0: PCH/PCH PCL/PCL 
    PHI2 T0: 
    PHI1 T1: ADH/PCH ADL/PCL 
    PHI2 T1: PCH/ADH PCL/ADL 
    PHI1 T2: ADH/PCH PCH/ADH PCL/ADL ADL/PCL 
    PHI2 T2: PCH/ADH PCL/ADL 
    PHI1 T3: ADH/PCH PCH/ADH PCL/ADL ADL/PCL 
    PHI2 T3: 
    PHI1 T4: PCH/PCH PCL/PCL 
    PHI2 T4: 
    PHI1 T5: PCH/PCH PCL/PCL 
    PHI2 T5: 
    PHI1 T6: PCH/PCH PCL/PCL 
    PHI2 T6: 
    
RTI
    PHI1 T0: PCH/PCH PCL/PCL 
    PHI2 T0: 
    PHI1 T1: ADH/PCH ADL/PCL 
    PHI2 T1: PCH/ADH PCL/ADL 
    PHI1 T2: ADH/PCH PCH/ADH PCL/ADL ADL/PCL 
    PHI2 T2: 
    PHI1 T3: PCH/PCH PCL/PCL 
    PHI2 T3: 
    PHI1 T4: PCH/PCH PCL/PCL 
    PHI2 T4: 
    PHI1 T5: PCH/PCH PCL/PCL 
    PHI2 T5: 
    PHI1 T6: PCH/PCH PCL/PCL 
    PHI2 T6: 
```

И сам код:

```c
PHI1:
PCLDBDelay1 = NOR ( _ready, PCLDBDelay2 );

PHI2:
// PC control
CtrlOut2[PCH_DB] = PCLDBDelay2 = NOR (DECODER[77], DECODER[78]);
CtrlOut2[PCL_DB] = NOT (PCLDBDelay1);
PC_DB = NOR ( CtrlOut2[PCH_DB], CtrlOut2[PCL_DB] );
CtrlOut2[ADH_PCH] = NOT ( DECODER[83] | DECODER[84] | DECODER[93] | DECODER[80] | T0 | T1 );
CtrlOut2[PCH_PCH] = NOT ( CtrlOut2[ADH_PCH] );
int JB = NOT ( DECODER[94] | DECODER[95] | DECODER[96] );
DL_PCH = NOR (JB, NOT(T0));
CtrlOut2[PCL_ADL] = NOT ( NOR(NOT(T0), NOR(NotReady1, JB)) | DECODER[56] | DECODER[80] | T1 | DECODER[83] );
CtrlOut2[PCH_ADH] = NOR ( NOT(CtrlOut2[PCL_ADL] | DECODER[73] | DL_PCH), DECODER[93] );
CtrlOut2[ADL_PCL] = NAND (NOT(NotReady1), DECODER[93]) & NOT (DECODER[84] | NOT(CtrlOut2[PCL_ADL]) | T0 );
CtrlOut2[PCL_PCL] = NOT (CtrlOut2[ADL_PCL]);
```
