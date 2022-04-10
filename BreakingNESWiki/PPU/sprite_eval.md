# Сравнение спрайтов

![ppu_locator_sprite_eval](/BreakingNESWiki/imgstore/ppu/ppu_locator_sprite_eval.jpg)

Схема сравнения спрайтов занимается сравнением всех 64 спрайтов и выборкой первых 8 спрайтов, которые встречаются раньше всех на текущей строке (V). То что PPU умеет рисовать только первые 8 спрайтов строки - широко известный факт, который приходится учитывать при программировании NES. Обычно программисты применяют перемешивание спрайтов, но даже при этом возникает эффект "мерцания" спрайтов.

Выбранные спрайты помещаются в дополнительную память OAM2, откуда потом попадают для дальнейшей обработки в [OAM FIFO](fifo.md).

Схема включает в себя:
- Счётчик индекса OAM, для выборки следующего спрайта для сравнения
- Счётчик индекса OAM2, для сохранения результатов сравнения
- Схемы контроля счётчиками
- Компаратор, который по сути является маленьким АЛУ и выполняет операцию знакового вычитания (A - B)
- Схему управления сравнением, которая и реализует всю логику работы сравнения спрайтов

![OAM_Eval](/BreakingNESWiki/imgstore/ppu/OAM_Eval.png)

## Разряд счётчиков

![OAM_CounterBit](/BreakingNESWiki/imgstore/ppu/OAM_CounterBit.png)

## Счётчик индекса OAM

![oam_index_counter](/BreakingNESWiki/imgstore/ppu/oam_index_counter.jpg)

![OAM_MainCounter](/BreakingNESWiki/imgstore/ppu/OAM_MainCounter.png)

## Счётчик индекса Temp OAM (OAM2)

![oam2_index_counter](/BreakingNESWiki/imgstore/ppu/oam2_index_counter.jpg)

![OAM_TempCounter](/BreakingNESWiki/imgstore/ppu/OAM_TempCounter.png)

## Управление счётчиками

![oam_index_counter_control](/BreakingNESWiki/imgstore/ppu/oam_index_counter_control.jpg)

![oam_counters_control](/BreakingNESWiki/imgstore/ppu/oam_counters_control.jpg)

![OAM_CountersControl](/BreakingNESWiki/imgstore/ppu/OAM_CountersControl.png)

![OAM_SprOV_Flag](/BreakingNESWiki/imgstore/ppu/OAM_SprOV_Flag.png)

## Адрес OAM

![OAM_Address](/BreakingNESWiki/imgstore/ppu/OAM_Address.png)

## Дополнительная схема H0''

Сигнал `H0''`, который используется в схемах управления счётчиками приходит не с выходов H-Output, которые находятся в схеме [H/V FSM](hv_fsm.md), а получается схемой, которая находится в промежутке между соединениями левее спрайтовой логики.

Этот особенный сигнал `H0''` (но по сути - вариация обычного сигнала H0'') отмечен стрелочкой на транзисторных схемах.

![h0_dash_dash_tran](/BreakingNESWiki/imgstore/ppu/h0_dash_dash_tran.jpg)

## Компаратор

![oam_cmpr](/BreakingNESWiki/imgstore/ppu/oam_cmpr.jpg)

![OAM_CmpBitPair](/BreakingNESWiki/imgstore/ppu/OAM_CmpBitPair.png)

![OAM_Cmp](/BreakingNESWiki/imgstore/ppu/OAM_Cmp.png)

## Схема управления сравнением

![oam_eval_control](/BreakingNESWiki/imgstore/ppu/oam_eval_control.jpg)

![OAM_EvalFSM](/BreakingNESWiki/imgstore/ppu/OAM_EvalFSM.png)

![PosedgeDFFE](/BreakingNESWiki/imgstore/ppu/PosedgeDFFE.png)
