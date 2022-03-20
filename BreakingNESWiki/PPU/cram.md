# Color RAM

![ppu_locator_cram](/BreakingNESWiki/imgstore/ppu/ppu_locator_cram.jpg)

Логика для работы с палитрой включает в состав следующие схемы:
- Color Buffer (CB)
- Схема управления Color Buffer
- Палитровая память (Color RAM)
- Декодер индекса палитры, поступающего с выхода мультиплексора

## Color Buffer (CB)

Color Buffer (CB) используется для хранения текущего "пикселя" для фазогенератора, а также для чтения/записи памяти палитры (используя CPU интерфейс).

### Схема управления Color Buffer

![cb_control](/BreakingNESWiki/imgstore/ppu/cb_control.jpg)

![CB_Control_Logic](/BreakingNESWiki/imgstore/ppu/CB_Control_Logic.jpg)

### Схема хранения одного разряда CB

|![color_buffer_bit](/BreakingNESWiki/imgstore/ppu/color_buffer_bit.jpg)|![cb_bit_logisim](/BreakingNESWiki/imgstore/ppu/cb_bit_logisim.jpg)|
|---|---|

### Схема задержки выходов CB

Выходы с разрядов CB идут не напрямую в фазогенератор, а проходят через цепочку D-Latch. Цепочки D-Latch неравномерно размазаны для каждого разряда CB.

TBD.

### Black/White режим

Выводы 4-х разрядов CB, отвечающих за цветность управляются контрольным сигналом `/BW`.

Аналогичный транзистор для 2-х разрядов яркости просто всегда открыт:

![ppu_luma_tran](/BreakingNESWiki/imgstore/ppu/ppu_luma_tran.jpg)

## Организация Color RAM

По соглашению группы ячеек, которые адресуются младшими разрядами адреса будем считать "рядами", а группы ячеек, адресуемые старшими разрядами будем считать "колонками".

Касательно Color RAM:
- PAL2, PAL3: Определяет колонку (PAL2 - msb)
- PAL4, PAL1, PAL0: Определяет ряд (PAL4 - msb)
- Ряды 0 и 4 совмещены

Выглядит немного хаотично, но что есть - то есть. Реверсинг памяти по какой-то причине всегда проходит с подобными мучениями в понимании, но не забывайте такой факт, что порядок соединения адресных линий для индексации памяти в общем случае не имеет значения.

Выходы COL:

![palette_col_outputs](/BreakingNESWiki/imgstore/ppu/palette_col_outputs.jpg)

Precharge PCLK:

![cram_precharge](/BreakingNESWiki/imgstore/ppu/cram_precharge.jpg)

### Ячейка памяти

Ячейка памяти представляет собой типовую 4T SRAM Cell:

|![cram_cell_topo](/BreakingNESWiki/imgstore/ppu/cram_cell_topo.jpg)|![cram_cell](/BreakingNESWiki/imgstore/ppu/cram_cell.jpg)|
|---|---|

### Декодер индекса палитры

|![cram_decoder](/BreakingNESWiki/imgstore/ppu/cram_decoder.jpg)|![cram_decoder_logic](/BreakingNESWiki/imgstore/ppu/cram_decoder_logic.jpg)|
|---|---|

|COL0 \| COL1 \| COL2 \| COL3|
|---|
|ROW0+4|
|ROW6|
|ROW2|
|ROW5|
|ROW1|
|ROW7|
|ROW3|

Подобный паттерн организации памяти повторяется 6 раз для каждого разряда Color Buffer.
