# Color RAM

![ppu_locator_cram](/BreakingNESWiki/imgstore/ppu/ppu_locator_cram.jpg)

Логика для работы с палитрой включает в состав следующие схемы:
- Color Buffer (CB)
- Схема управления Color Buffer
- Палитровая память (Color RAM)
- Декодер индекса палитры, поступающего с выхода мультиплексора

Сигналы:

|Сигнал|Откуда|Назначение|
|---|---|---|
|/R7|Reg Select|Чтение регистра $2007|
|/DBE|/DBE Pad|"Data Bus Enable", включение CPU интерфейса|
|TH/MUX|VRAM Ctrl|Направить значение TH Counter на вход MUX, в результате чего это значение уйдет в палитру в качестве Direct Color.|
|PICTURE|FSM|Генерируется видимая часть видеосигнала с картинкой|
|B/W|Regs $2001\[0\]|Отключить Color Burst, для генерации монохромного изображения|
|DB/PAR|VRAM Ctrl|Контрольный сигнал|

Сигналы управления Color Buffer:
- #DB/CB = 0: DB -> CB
- #CB/DB = 0: CB -> DB

## Color Buffer (CB)

Color Buffer (CB) используется для хранения текущего "пикселя" для фазогенератора, а также для чтения/записи памяти палитры (используя CPU интерфейс).

### Схема управления Color Buffer

![cb_control](/BreakingNESWiki/imgstore/ppu/cb_control.jpg)

![CB_Control_Logic](/BreakingNESWiki/imgstore/ppu/CB_Control_Logic.jpg)

### Схема хранения одного разряда CB

|![color_buffer_bit](/BreakingNESWiki/imgstore/ppu/color_buffer_bit.jpg)|![cb_bit_logisim](/BreakingNESWiki/imgstore/ppu/cb_bit_logisim.jpg)|
|---|---|

Схема Logisim весьма приближенно передает исходную схему, т.к. в Logisim отсутствует поддержка inOut сущностей.

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

Значение записывается или читается двумя комплементарными inOut: /val и val. Принцип работы ячейки:
- В режиме чтения ячейки: /val = val = `z`. Поэтому текущее значение выдается наружу.
- В режиме записи в ячейку: /val и val принимают комплементарное значение бита, который нужно записать

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
