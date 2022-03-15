# Сравнение спрайтов

![ppu_locator_sprite_eval](/BreakingNESWiki/imgstore/ppu/ppu_locator_sprite_eval.jpg)

Схема сравнения спрайтов занимается сравнением всех 64 спрайтов и выборкой первых 8 спрайтов, которые встречаются раньше всех на текущей строке (H). То что PPU умеет рисовать только первые 8 спрайтов строки - широко известный факт, который приходится учитывать при программировании NES. Обычно программисты применяют перемешивание спрайтов, но даже при этом возникает эффект "мерцания" спрайтов.

Выбранные спрайты помещаются в дополнительную память OAM2, откуда потом попадают для дальнейшей обработки в [OAM FIFO](fifo.md).

Схема включает в себя:
- Счетчик индекса OAM, для выборки следующего спрайта для сравнения
- Счетчик индекса OAM2, для сохранения результатов сравнения
- Схемы контроля счетчиками
- Компаратор, который по сути является маленьким АЛУ и выполняет операцию знакового вычитания (A - B)
- Схему управления сравнением, которая и реализует всю логику работы сравнения спрайтов

Схемы для управления счетчиками разделены предварительно, возможно есть смысл их объединить в одну схему.

## Счетчик индекса OAM

![oam_index_counter](/BreakingNESWiki/imgstore/ppu/oam_index_counter.jpg)

## Управление счетчиком индекса OAM

![oam_index_counter_control](/BreakingNESWiki/imgstore/ppu/oam_index_counter_control.jpg)

## Счетчик индекса Temp OAM (OAM2)

![oam2_index_counter](/BreakingNESWiki/imgstore/ppu/oam2_index_counter.jpg)

![ppu_logisim_oam2_counter](/BreakingNESWiki/imgstore/ppu/ppu_logisim_oam2_counter.jpg)

## Общее управление счетчиками

![oam_counters_control](/BreakingNESWiki/imgstore/ppu/oam_counters_control.jpg)

## Дополнительная схема H0''

Сигнал `H0''`, который используется в схемах управления счетчиками приходит не с выходов H-Output, которые находятся в схеме [H/V FSM](hv_fsm.md), а получается схемой, которая находится в промежутке между соединениями левее спрайтовой логики.

Этот особенный сигнал `H0''` (но по сути - вариация обычного сигнала H0'') отмечен стрелочкой на транзисторных схемах.

![h0_dash_dash_tran](/BreakingNESWiki/imgstore/ppu/h0_dash_dash_tran.jpg)

## Компаратор

![oam_cmpr](/BreakingNESWiki/imgstore/ppu/oam_cmpr.jpg)

## Схема управления сравнением

![oam_eval_control](/BreakingNESWiki/imgstore/ppu/oam_eval_control.jpg)

## Схема Logisim

![ppu_logisim_oam_eval](/BreakingNESWiki/imgstore/ppu/ppu_logisim_oam_eval.jpg)
