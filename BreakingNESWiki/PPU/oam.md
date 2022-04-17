# OAM

![ppu_locator_oam](/BreakingNESWiki/imgstore/ppu/ppu_locator_oam.jpg)

Спрайтовая память (OAM, Object Attribute Memory) занимает почти четверть поверхности PPU, в те времена память была роскошью. Размер OAM составляет 2112 разрядов, из них 1856 используются для хранения 64 спрайтов (29 разрядов на спрайт), а остальные 32 байта используются специальным образом, для выборки 8 текущих спрайтов, которые будут показаны на текущей строке. Эта область OAM обычно называется "temporary OAM" или OAM2.

Комбинированное изображение топологии ячейки памяти:

![ppu_oam_closeup](/BreakingNESWiki/imgstore/ppu/ppu_oam_closeup.jpg)

Схемы OAM:
- Массив ячеек памяти (2112 ячеек)
- Декодер ряда
- Декодер колонки
- Схема контроля OAM Buffer
- OAM Buffer (OB)

## Организация OAM

По соглашению группы ячеек, которые адресуются младшими разрядами адреса будем считать "рядами", а группы ячеек, адресуемые старшими разрядами будем считать "колонками".

- /OAM0-2: Определяют ряд (с небольшой особенностью, см. далее)
- /OAM3-7: Определяют колонку

## Ячейка памяти

![oam_cell](/BreakingNESWiki/imgstore/ppu/oam_cell.jpg)

Ячейка представляет собой типовую 4T-ячейку, но с одним исключением - транзисторы ячейки, на которых хранится значение, не подключены к Vdd, 
поэтому значение на ячейке постоянно деградирует, т.к. без подтяжки хранится по сути на затворах транзисторов.

Эффект деградации памяти OAM называется "OAM Corruption" и он широко известен. Для борьбы с этим эффектом программы для NES
содержат кэш OAM в обычной памяти процессора и каждый VBlank копируют этот кэш в OAM с помощью спрайтовой DMA APU.

Во время PCLK производится "precharge".

TBD: Рассчитать или измерить тайминги деградации ячеек.

## Декодер ряда

![oam_row_decoder](/BreakingNESWiki/imgstore/ppu/oam_row_decoder.png)

Схема представляет собой одноединичный декодер (1-из-n).

Выходы ROW для разрядов OAM Buffer 0, 1, 5-7:

![oam_row_outputs1](/BreakingNESWiki/imgstore/ppu/oam_row_outputs1.png)

Выходы ROW для разрядов OAM Buffer 2-4:

![oam_row_outputs2](/BreakingNESWiki/imgstore/ppu/oam_row_outputs2.png)

Пропуск рядов у разрядов 2-4 сделан для экономии памяти. Если вывести соответствие адреса OAM и значений ROW, которое получается из младших разрядов, то получится такое:

```
OamAddr: 0, row: 0
OamAddr: 1, row: 1
OamAddr: 2, row: 2 ATTR  UNUSED for OB[2-4]
OamAddr: 3, row: 3
OamAddr: 4, row: 4
OamAddr: 5, row: 5
OamAddr: 6, row: 6 ATTR  UNUSED for OB[2-4]
OamAddr: 7, row: 7
OamAddr: 8, row: 0
OamAddr: 9, row: 1
OamAddr: 10, row: 2 ATTR  UNUSED for OB[2-4]
OamAddr: 11, row: 3
OamAddr: 12, row: 4
OamAddr: 13, row: 5
OamAddr: 14, row: 6 ATTR  UNUSED for OB[2-4]
OamAddr: 15, row: 7
...
```

Как видно ROW2 и ROW6 попадают как раз на байт атрибутов спрайта, в котором не используются биты 2-4.

## Декодер колонки

![oam_col_decoder](/BreakingNESWiki/imgstore/ppu/oam_col_decoder.png)

Схема представляет собой одноединичный декодер (1-из-n).

## Схема управления OAM Buffer

Схема используется для задания режимов работы OB и управлением передачи значений между ним и OAM.

![oam_buffer_control](/BreakingNESWiki/imgstore/ppu/oam_buffer_control.jpg)

## OAM Buffer (OB)

OAM Buffer используется как перевалочный пункт для хранения байта который нужно записать в OAM или байта, который был прочитан из OAM для потребителей.

Схема состоит из 8 идентичных схем для каждого разряда:

![oam_buffer_bit](/BreakingNESWiki/imgstore/ppu/oam_buffer_bit.jpg)

(На картинке представлена схема для хранения разряда OB0).
