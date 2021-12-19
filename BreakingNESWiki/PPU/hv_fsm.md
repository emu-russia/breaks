# Управляющая логика H/V

Логика H/V представляет собой конечный автомат (FSM), который управляет всеми остальными узлами PPU. Схематически это просто набор защелок, по типу "эта защелка активна от 64го до 128го пикселя", значит соответствующая контрольная линия идущая от этой защелки тоже активна.

Входные сигналы:

|Сигнал|Откуда|Описание|
|---|---|---|
|H0-5|HCounter|Разряды 0-5 HCounter|
|V8|VCounter|Разряд 8 VCounter|
|/V8|VDecoder|Разряд 8 VCounter (инвертированное значение)|
|HPLA_0-23|HDecoder|Выходы с декодера H|
|VPLA_0-8|VDecoder|Выходы с декодера V|
|/OBCLIP|Control Regs|Для формирования контрольного сигнала CLIP_O|
|/BGCLIP|Control Regs|Для формирования контрольного сигнала CLIP_B|
|BLACK|Control Regs| |
|DB7|Внутренняя шина данных DB|Для чтения $2002\[7\]|
|VBL|Control Regs| |
|/R2|Reg Select|Регистровая операция чтения $2002|
|/DBE|Контакт /DBE|Включение CPU интерфейса|
|RES|Контакт /RES|Глобальный сигнал сброса|

Выходные сигналы:

|Сигнал|Куда|Описание|
|---|---|---|
|Выходы HCounter с задержкой|||
|H0'| | |
|/H1'| | |
|/H2'| | |
|H0''-H5''| | |
|Горизонтальные управляющие сигналы|||
|S/EV| |"Start Sprite Evaluation"|
|CLIP_O| |"Clip Objects"|
|CLIP_B| |"Clip Background"|
|0/HPOS| | |
|EVAL| |"Sprite Evaluation in Progress"|
|E/EV| |"End Sprite Evaluation"|
|I/OAM2| |"Increment OAM2 Counter"|
|PAR/O| |"Connect PAR with Object"|
|/VIS| | |
|F/NT| |"Fetch Name Table"|
|F/TB| |"Fetch Tile B"|
|F/TA| |"Fetch Tile A"|
|/FO| |"Fetch Object"|
|F/AT| |"Fetch Attribute Table"|
|SC/CNT| |"SC Counter?"|
|BURST| | |
|SYNC| | |
|Вертикальные управляющие сигналы|||
|VSYNC| | |
|PICTURE| | |
|VB| | |
|BLNK| | |
|RESCL| | |
|Прочее|||
|HC| |"HCounter Clear"|
|VC| |"VCounter Clear"|
|V_IN| |"VCounter In"|
|INT| |"Interrupt"|

Вспомогательные сигналы:

|Сигнал|Откуда|Куда|Описание|
|---|---|---|---|
|/FPORCH| | |"Front Porch"|
|BPORCH| | |"Back Porch"|
|/HB| | |"HBlank"|
|/VSET| | |"VBlank Set"|
|EvenOddOut| | | |

## Выдача наружу значений разрядов H

Разряды счетчика H используются в других компонентах PPU.

![h_counter_output](/BreakingNESWiki/imgstore/ppu/h_counter_output.jpg)

## Горизонтальная логика

"Горизонтальная" логика, отвечает за генерацию контрольных линий в зависимости от горизонтального положения луча (H):

![hv_fporch](/BreakingNESWiki/imgstore/ppu/hv_fporch.jpg)

![hv_fsm_horz](/BreakingNESWiki/imgstore/ppu/hv_fsm_horz.jpg)

## Вертикальная логика

![hv_fsm_vert](/BreakingNESWiki/imgstore/ppu/hv_fsm_vert.jpg)

### Управление H/V счетчиками

![hv_counters_control](/BreakingNESWiki/imgstore/ppu/hv_counters_control.jpg)

### Логика EVEN/ODD

![even_odd_tran](/BreakingNESWiki/imgstore/ppu/even_odd_tran.jpg) ![even_odd_flow1](/BreakingNESWiki/imgstore/ppu/even_odd_flow1.jpg) ![even_odd_flow2](/BreakingNESWiki/imgstore/ppu/even_odd_flow2.jpg)

Логика EVEN/ODD состоит из двух замкнутых друг на друга псевдозащелок, управляемых двумя мультиплексорами. Получается такая очень хитрая "макро"-защелка.

TODO: Схему нужно проанализровать ещё раз, т.к. что это за фигня такая - "макро-защелка".. К тому же схема для PAL PPU отличается от NTSC версии.
