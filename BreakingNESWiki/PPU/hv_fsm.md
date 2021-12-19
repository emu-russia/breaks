# Управляющая логика H/V

Логика H/V представляет собой конечный автомат (FSM), который управляет всеми остальными узлами PPU. Схематически это просто набор защелок, по типу "эта защелка активна от 64го до 128го пикселя", значит соответствующая контрольная линия идущая от этой защелки тоже активна.

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
