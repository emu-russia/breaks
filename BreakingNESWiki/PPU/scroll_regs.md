# Регистры скроллинга

![ppu_locator_scroll_regs](/BreakingNESWiki/imgstore/ppu/ppu_locator_scroll_regs.jpg)

Регистры скроллинга - это сущность, которая в сообществе nesdev обычно обозначается как `t`.

Регистры скроллинга устроены хитро:
- Две последовательные записи в $2005 или $2006 заносят значения в один и тот же FF
- Когда и куда пишется лучше всего посмотреть в таблицах ниже
- Для Name Table также используется аналогичная дуальность при записи в регистр $2000

Кто давно программирует NES, тот хорошо знаком с этими особенностями. Обычно про них говорят в контексте `loopy`, по нику человека, который рассмотрел особенности их работы для целей эмуляции.

Кто же только начинает знакомиться с NES, то это ... арргх..

![SCC_Regs](/BreakingNESWiki/imgstore/ppu/SCC_Regs.png)

Схема FF, применяемого для хранения значений:

![SCC_FF](/BreakingNESWiki/imgstore/ppu/SCC_FF.png)

## Fine HScroll

![dualregs_fh](/BreakingNESWiki/imgstore/ppu/dualregs_fh.jpg)

![SCC_FineH](/BreakingNESWiki/imgstore/ppu/SCC_FineH.png)

|W5/1|FH|
|---|---|
|DB0|0|
|DB1|1|
|DB2|2|

## Fine VScroll

![dualregs_fv](/BreakingNESWiki/imgstore/ppu/dualregs_fv.jpg)

![SCC_FineV](/BreakingNESWiki/imgstore/ppu/SCC_FineV.png)

|W5/2|W6/1|FV|
|---|---|---|
|DB0|DB4|0|
|DB1|DB5|1|
|DB2|`0`|2|

Запись `0` в FV2 вместо $2006\[6\] объясняется тем, что значение для счётчика FV принудительно ограничивается диапазоном 0-3, т.к. иначе его значение бы выходило за предел адресного пространства PPU.

## Выбор Name Table

![dualregs_nt](/BreakingNESWiki/imgstore/ppu/dualregs_nt.jpg)

![SCC_NTSelect](/BreakingNESWiki/imgstore/ppu/SCC_NTSelect.png)

|W0|W6/1|NT|
|---|---|---|
|DB0|DB2|NTH|
|DB1|DB3|NTV|

## Tile V

![dualregs_tv](/BreakingNESWiki/imgstore/ppu/dualregs_tv.jpg)

![SCC_TileV](/BreakingNESWiki/imgstore/ppu/SCC_TileV.png)

|W5/2|W6/1|W6/2|TV|
|---|---|---|---|
|DB3| |DB5|0|
|DB4| |DB6|1|
|DB5| |DB7|2|
|DB6|DB0| |3|
|DB7|DB1| |4|

## Tile H

![dualregs_th](/BreakingNESWiki/imgstore/ppu/dualregs_th.jpg)

![SCC_TileH](/BreakingNESWiki/imgstore/ppu/SCC_TileH.png)

|W5/1|W6/2|TH|
|---|---|---|
|DB3|DB0|0|
|DB4|DB1|1|
|DB5|DB2|2|
|DB6|DB3|3|
|DB7|DB4|4|