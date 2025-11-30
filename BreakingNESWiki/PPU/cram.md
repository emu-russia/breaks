# Генератор Цвета (Color Generator RAM)

![ppu_locator_cram](/BreakingNESWiki/imgstore/ppu/ppu_locator_cram.jpg)

Логика для работы с генератором цвета (или по простому - "палитрой") включает в состав следующие схемы:
- Color Buffer (CB)
- Схема управления Color Buffer
- Массив ячеек памяти (Color RAM)
- Декодер адреса CRAM, поступающего с выхода мультиплексора

![CRAM_All](/BreakingNESWiki/imgstore/ppu/CRAM_All.png)

Сигналы:

|Сигнал|Откуда|Назначение|
|---|---|---|
|/R7|Reg Select|Чтение регистра $2007|
|/DBE|/DBE Pad|"Data Bus Enable", включение CPU интерфейса|
|TH/MUX|VRAM Ctrl|Направить значение TH Counter на вход MUX, в результате чего это значение уйдет в палитру в качестве Direct Color.|
|/PICTURE|FSM|Генерируется видимая часть видеосигнала с картинкой|
|B/W|Regs $2001\[0\]|Отключить Color Burst, для генерации монохромного изображения|
|DB/PAR|VRAM Ctrl|Контрольный сигнал|
|#DB/CB|Color Buffer Control|0: DB -> CB|
|#CB/DB|Color Buffer Control|0: CB -> DB|

## Color Buffer (CB)

Color Buffer (CB) используется для хранения текущего "пикселя" для фазогенератора, а также для чтения/записи памяти палитры (используя CPU интерфейс).

### Схема управления Color Buffer

![cb_control](/BreakingNESWiki/imgstore/ppu/cb_control.jpg)

![CB_Control_Logic](/BreakingNESWiki/imgstore/ppu/CB_Control_Logic.jpg)

### Схема хранения одного разряда CB

|![color_buffer_bit](/BreakingNESWiki/imgstore/ppu/color_buffer_bit.jpg)|![CB_Bit](/BreakingNESWiki/imgstore/ppu/CB_Bit.png)|
|---|---|

Схема Logisim весьма приближенно передает исходную схему, т.к. в Logisim отсутствует поддержка inOut сущностей.

### Схема задержки выходов CB

Выходы с разрядов CB идут не напрямую в фазогенератор, а проходят через цепочку D-Latch. Цепочки D-Latch неравномерно размазаны для каждого разряда CB.

Задержки необходимы по причине того, что логически нет возможности проводить обработку текущего пикселя и одновременно выводить его на экран в виде сигнала. Поэтому видеогенератор по сути выводит пиксели "из прошлого".

Для разрядов CB 4-5 (яркость, сигналы LL0# и LL1#):

![cbout_ll](/BreakingNESWiki/imgstore/ppu/cbout_ll.jpg)

Для разрядов CB 0-3 (цветность, сигналы CC0-3#) рядом с CB находится только часть цепочки. Остальные защелки как хлебные крошки разбросаны по пути к [фазогенератору](video_out.md).

![cbout_cc](/BreakingNESWiki/imgstore/ppu/cbout_cc.jpg)

P.S. Если вы разработчик микросхем, пожалуйста не размазывайте свою топологию подобным образом. Такие схемы очень неудобно распиливать на части для изучения и размещать на вики.

### Black/White режим

Выводы 4-х разрядов CB, отвечающих за цветность управляются контрольным сигналом `/BW`.

Аналогичный транзистор для 2-х разрядов яркости просто всегда открыт:

![ppu_luma_tran](/BreakingNESWiki/imgstore/ppu/ppu_luma_tran.jpg)

## Организация Color RAM

По соглашению группы ячеек, которые адресуются младшими разрядами адреса будем считать "рядами", а группы ячеек, адресуемые старшими разрядами будем считать "колонками".

Касательно Color RAM:
- CGA3, CGA2: Определяет колонку (CGA3 - msb)
- CGA4, CGA1, CGA0: Определяет ряд (CGA4 - msb)
- Ряды 0 и 4 совмещены

Выходы COL:

![cram_col_outputs](/BreakingNESWiki/imgstore/ppu/cram_col_outputs.jpg)

Precharge PCLK:

![cram_precharge](/BreakingNESWiki/imgstore/ppu/cram_precharge.jpg)

Дополнительно можно посмотреть карту распределения ячеек CRAM тут: https://github.com/ogamespec/CRAMMap

### Ячейка памяти

Ячейка памяти представляет собой типовую 4T SRAM Cell:

|![cram_cell_topo](/BreakingNESWiki/imgstore/ppu/cram_cell_topo.jpg)|![cram_cell](/BreakingNESWiki/imgstore/ppu/cram_cell.jpg)|
|---|---|

Значение записывается или читается двумя комплементарными inOut: /val и val. Принцип работы ячейки:
- В режиме чтения ячейки: /val = val = `z`. Поэтому текущее значение выдается наружу.
- В режиме записи в ячейку: /val и val принимают комплементарное значение бита, который нужно записать

### Декодер индекса палитры

:warning: Обратите внимание, что сигнал CGA4 следует не в обычном порядке. Данный бит выбирает тип палитры: палитра для бэкграунда или для спрайтов.

|![cram_decoder](/BreakingNESWiki/imgstore/ppu/cram_decoder.jpg)|![CRAM_Decoder](/BreakingNESWiki/imgstore/ppu/CRAM_Decoder.png)|
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