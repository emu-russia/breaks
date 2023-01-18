# BRK Последовательность

BRK-последовательность - это унифицированный механизм реакции процессора на внешние сигналы прерываний (`/NMI`, `/IRQ`, `/RES`), а также на выполнение инструкции `BRK` (0x00).

В основной части уже были упоминания о том, как разработчики подошли к унификации этого механизма (инжектирование кода операции 0x00 в регистр инструкций и проч.), в данном разделе производится более подробный анализ.

Дальнейшее рассмотрение состояния производится при учете, что вход `RDY` = 1 (процессор готов).

## Программная модель BRK

Информация общего плана для программистов, достаточная для общего понимания процесса BRK-последовательности.

|Цикл|Операция|
|---|---|
|T0|Загрузить опкод BRK (инструкция) / инжектировать BRK (прерывание). Инкремент PC, если выполняется непосредственно инструкция BRK|
|T1|Загрузить и задискардить данные. Инкремент PC, если выполняется непосредственно инструкция BRK|
|T2|Поместить PCH на стек|
|T3|Поместить PCL на стек|
|T4|Поместить P на стек|
|T5|Прочитать адрес вектора прерывания (младший байт)|
|T6|Прочитать адрес вектора прерывания (старший байт)|

## Включение питания

При включении питания процессор выполняет особенную последовательность (Pre-BRK).

## UB (0xFF), T1 (PHI1)

Верхняя часть:

|Состояние|Примечание|
|---|---|
|Обработчик прерываний||
|RESP=1|Это не эффект /RES=0, так как входной FF контакта /RES обновяется только во время PHI2. Это эффект выходной защёлки resp_latch.|
|DORES=0|Входная защёлка DORES_FF обновляется сигналом RESP только во время PHI2.|
|BRK6E=0|Значение выходной защёлки не определено, поэтому через инвертор значение BRK6E принимает значение 0.|
|B_OUT=0|Хотя DORES = 0, но значение выходной защёлки флага B не определено и BRK6E = 0, поэтому B_OUT = 0.|
|Диспатчер||
|/ready = 0|Значение выходной защёлки /ready обновляется во время PHI2. На момент сброса значение защёлки не определено, в результате чего /ready принимает значение 0.|
|WR=1|WR формируется операцией 3-NOR, входы которой (/ready, DORES, wr_latch) принимают значение 0. В результате чего WR = 1|
|FETCH=0|Значение выходной защёлки схемы FETCH ещё не определено (обновляется во время PHI2).|
|0/IR=1|Т.к. FETCH = 0 и B_OUT = 0.|
|ENDS = 1|Значения выходных защелок схемы ENDS не определены.|
|TRES1 = 1|Т.к. ENDS = 1|
|TRESX=0|В состав схемы TRESX входит защёлка, значение которой ещё не определено (PHI2). И через инвертор и NOR - TRESX в результате принимает значение 0.|
|/TWOCYCLE=1|PD=0x00|
|TRES2=1|Т.к. TRESX = 0|
|/T0 = 1|Соотв. схеме|
|/T1X = 0|Соотв. схеме|
|Расширенный счётчик циклов||
|/T2-/T5 = 1|TRES2 = 1|
|Декодер||
|44: INC NOP (TX), 60: ADC SBC (T1), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 112: ADC SBC (T1)|Выполняет 0xFF/T1. Операция не имеет смысла, т.к. все выходные защёлки рандомной логики обновляются только во время PHI2.|
|Регистры||
|PD=0x00|В результате 0/IR=1 значение PD = 0x00|
|IR=0xFF|Значение регистра IR не обновляется (FETCH = 0), при этом он устроен так, что на декодер попадает значение 0xFF|

Нижняя часть:

В результате того, что выходные командые защёлки загружаются только во время PHI2 - их выходные значения сразу после сброса не определены.

Это приводит к тому, что практически все команды нижней части активны (отсутствие заряда на затворах выходных защелок приводит к тому, что на выходе у них 1). В этом случае нижняя часть "сходит с ума".

|Состояние|Примечание|
|---|---|
|ADH/ABH, ADL/ABL|Шина адреса принимает значение 0x0000|
|0/ADL0|1|
|0/ADL1|1|
|0/ADL2|0|
|0/ADH0, 0/ADH17|Обе активных команды приводят к тому, что на шине ADH значение 0x00.|
|Y/SB, SB/Y, X/SB, SB/X, S/ADL, S/SB, SB/S, S/S|Y/SB, X/SB, SB/S, S/S не приводят к эффекту, т.к. регистр обновляется только во время PHI2. В результате текущее значение регистров X, Y, S одновременно помещается на шину SB (для регистра S - также на шину ADL командой S/ADL). Особенность регистра S такая, что значение с выходной защёлки выдается в инвертированном виде. То есть на шину SB и ADL помещается значение 0xFF (S = 0). Но так как до этого регистры X/Y уже поместили на шину значение 0x00 - побеждает земля и шина SB принимает значение 0x00|
|NDB/ADD, DB/ADD, 0/ADD, SB/ADD, ADL/ADD, ADD/SB06, ADD/ADL, SB/AC, AC/SB, AC/DB, SB/DB, SB/ADH|AI: Команды 0/ADD, SB/ADD приводят к эффекту загрузки 0 на защёлку AI и одноврменному "заземлению" шины SB (SB/ADD открывает шину SB, а 0/ADD зануляет её). Но в этом нет смысла, т.к. SB уже заземлена регистровыми операциям. BI: Рассматривать нет смысла (?). Выход ALU: Рассматривать нет смысла (?). ADD/SB7 = 0 из-за особенностей её выходной защёлки (но в ней тоже сейчас нет смысла)|
|Операции АЛУ|Все отключены|
|/ACIN|TBD|
|/DAA|TBD|
|/DSA|TBD|
|#1/PC|TBD|
|ADH/PCH, PCH/PCH, PCH/ADH, PCH/DB, ADL/PCL, PCL/PCL, PCL/ADL, PCL/DB|TBD|
|RD = 0|В соответствии с WR = 1|
|DL/ADL, DL/ADH, DL/DB|Одновременная установка команд DL/ADL и DL/ADH приводит к замыканию шин ADL/ADH, в результате чего они обе становятся равными 0x00 (ADH уже заземлена командами 0/ADH0, 0/ADH17). DL/DB приводит также к занулению шины DB. Защёлка DOR = 0x00.|
|Внутренние шины||
|SB|0x00|
|DB|0x00|
|ADL|0x00|
|ADH|0x00|

Феномен: Все части процессора "сходят с ума", но чудесным образом в результате всех операции процессор делает запись 0x00 по адресу 0x0000.

![FF_UB_T1_PHI1](/BreakingNESWiki/imgstore/ops/FF_UB_T1_PHI1.jpg)

## UB (0xFF), T1+T7 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 0, /T0: 1, /T1X: 0, 0/IR: 1, FETCH: 1, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 1, T6: 0, T7: 1, ENDS: 0, ENDX: 0, TRES1: 0, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 1, BRK6E: 0, BRK7: 1, DORES: 1, /DONMI: 0|
|Extra Cycle Counter|T1: 1, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|44: INC NOP (TX), 60: ADC SBC (T1), 106: LSR ROR DEC INC DEX NOP (4x4 bottom right) (TX), 112: ADC SBC (T1)|
|Commands|ADD_SB7, ADD_SB06, PCH_ADH, PCL_ADL, PCL_DB, ADH_ABH, SB_DB, DBZ_Z, DB_N, ACR_C, AVR_V|
|ALU Carry In|0|
|DAA|1|
|DSA|1|
|Increment PC|0|
|Regs||
|IR|0xFF|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0x00|
|AI|0x00|
|BI|0xFC|
|ADD|0xFF|
|AC|0x0A|
|PCL|0x00|
|PCH|0x00|
|ABL|0x00|
|ABH|0x00|
|DL|0x00|
|DOR|0x00|
|Flags|C: 0, Z: 0, I: 0, D: 0, B: 0, V: 0, N: 0|
|Buses||
|SB|0xFF|
|DB|0x00|
|ADL|0x00|
|ADH|0x00|

![FF_UB_T1_PHI2](/BreakingNESWiki/imgstore/ops/FF_UB_T1_PHI2.jpg)

## PreBRK (0x00), T0 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 1, FETCH: 1, /ready: 0, WR: 0, ACRL1: 1, ACRL2: 1, T6: 0, T7: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 1, BRK6E: 0, BRK7: 1, DORES: 1, /DONMI: 0|
|Extra Cycle Counter|T1: 0, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|34: T0 ANY, 87: BRK RTI (T0), 94: BRK RTI (TX), 121: /IR6, 126: /IR7|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADD_SB7, ADD_SB06, SB_AC, ADH_PCH, PCH_ADH, ADL_PCL, PCL_ADL, PCL_DB, ADH_ABH, SB_DB, DBZ_Z, DB_N, ACR_C|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0x00|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0x00|
|AI|0xFF|
|BI|0x00|
|ADD|0xFF|
|AC|0xAA|
|PCL|0x00|
|PCH|0x00|
|ABL|0x00|
|ABH|0x00|
|DL|0x00|
|DOR|0x00|
|Flags|C: 1, Z: 1, I: 0, D: 0, B: 0, V: 0, N: 0|
|Buses||
|SB|0x00|
|DB|0x00|
|ADL|0x00|
|ADH|0x00|

![00_PreBRK_T0_PHI1](/BreakingNESWiki/imgstore/ops/00_PreBRK_T0_PHI1.jpg)

## PreBRK (0x00), T0 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 1, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 1, T6: 0, T7: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 1, BRK6E: 0, BRK7: 1, DORES: 1, /DONMI: 0|
|Extra Cycle Counter|T1: 0, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|34: T0 ANY, 87: BRK RTI (T0), 94: BRK RTI (TX), 121: /IR6, 126: /IR7|
|Commands|SUMS, ADD_ADL, ADH_ABH, ADL_ABL, DL_ADH, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0x00|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0x00|
|AI|0xFF|
|BI|0x00|
|ADD|0xFF|
|AC|0xAA|
|PCL|0x00|
|PCH|0x00|
|ABL|0x00|
|ABH|0x00|
|DL|0x00|
|DOR|0x00|
|Flags|C: 1, Z: 1, I: 0, D: 0, B: 0, V: 0, N: 0|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0xFF|
|ADH|0xFF|

![00_PreBRK_T0_PHI2](/BreakingNESWiki/imgstore/ops/00_PreBRK_T0_PHI2.jpg)

## PreBRK (0x00), T01 (PHI1)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 0, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 0, T6: 0, T7: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 1, BRK6E: 0, BRK7: 1, DORES: 1, /DONMI: 0|
|Extra Cycle Counter|T1: 0, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|34: T0 ANY, 87: BRK RTI (T0), 94: BRK RTI (TX), 121: /IR6, 126: /IR7|
|Commands|S_S, DB_ADD, SB_ADD, SUMS, ADD_ADL, ADH_PCH, ADL_PCL, ADH_ABH, ADL_ABL, DL_ADH, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0x00|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0x00|
|AI|0xFF|
|BI|0x00|
|ADD|0xFF|
|AC|0xAA|
|PCL|0xFF|
|PCH|0x00|
|ABL|0xFF|
|ABH|0x00|
|DL|0x00|
|DOR|0x00|
|Flags|C: 1, Z: 1, I: 0, D: 0, B: 0, V: 0, N: 0|
|Buses||
|SB|0xFF|
|DB|0x00|
|ADL|0xFF|
|ADH|0x00|

![00_PreBRK_T01_PHI1](/BreakingNESWiki/imgstore/ops/00_PreBRK_T01_PHI1.jpg)

## PreBRK (0x00), T01 (PHI2)

|Component/Signal|State|
|---|---|
|Dispatcher|T0: 1, /T0: 0, /T1X: 0, 0/IR: 1, FETCH: 0, /ready: 0, WR: 0, ACRL1: 0, ACRL2: 0, T6: 0, T7: 0, ENDS: 0, ENDX: 1, TRES1: 0, TRESX: 0|
|Interrupts|/NMIP: 1, /IRQP: 1, RESP: 1, BRK6E: 0, BRK7: 1, DORES: 1, /DONMI: 0|
|Extra Cycle Counter|T1: 0, TRES2: 1, /T2: 1, /T3: 1, /T4: 1, /T5: 1|
|Decoder|34: T0 ANY, 87: BRK RTI (T0), 94: BRK RTI (TX), 121: /IR6, 126: /IR7|
|Commands|SUMS, ADD_ADL, ADH_ABH, ADL_ABL, DL_ADH, DL_DB|
|ALU Carry In|0|
|DAA|0|
|DSA|0|
|Increment PC|0|
|Regs||
|IR|0x00|
|PD|0x00|
|Y|0x00|
|X|0x00|
|S|0x00|
|AI|0xFF|
|BI|0x00|
|ADD|0xFF|
|AC|0xAA|
|PCL|0xFF|
|PCH|0x00|
|ABL|0xFF|
|ABH|0x00|
|DL|0x00|
|DOR|0x00|
|Flags|C: 1, Z: 1, I: 0, D: 0, B: 0, V: 0, N: 0|
|Buses||
|SB|0xFF|
|DB|0xFF|
|ADL|0xFF|
|ADH|0xFF|

![00_PreBRK_T01_PHI2](/BreakingNESWiki/imgstore/ops/00_PreBRK_T01_PHI2.jpg)

Дальше пока /RES не примет значение 1 - процессор будет исполнять в цикле PreBRK T0+T1.

## Сброс

TBD.

## NMI

TBD.

## IRQ

TBD.

## Смешанное прерывание

Ситуация когда сразу несколько входных контактов прерываний фиксируют событие.

TBD.

## Инструкция BRK

TBD.
