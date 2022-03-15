# Палитра

![ppu_locator_cram](/BreakingNESWiki/imgstore/ppu/ppu_locator_cram.jpg)

Логика для работы с палитрой включает в состав следующие схемы:
- Color Buffer (CB)
- Схема управления Color Buffer
- Палитровая память (Color RAM)
- Декодер индекса палитры, поступающего с выхода мультиплексора

## Color Buffer (CB)

Color Buffer (CB) используется для хранения текущего "пикселя" для фазогенератора, а также для чтения/записи памяти палитры (используя CPU интерфейс).

### Схема управления Color Buffer

![ppu_cb_control](/BreakingNESWiki/imgstore/ppu/ppu_cb_control.jpg)

![ppu_logisim_color_control](/BreakingNESWiki/imgstore/ppu/ppu_logisim_color_control.jpg)

### Схема хранения одного разряда CB

![ppu_color_buffer_bit](/BreakingNESWiki/imgstore/ppu/ppu_color_buffer_bit.jpg)

### Схема задержки выходов CB

Выходы с разрядов CB идут не напрямую в фазогенератор, а проходят через цепочку D-Latch. Цепочки D-Latch неравномерно размазаны для каждого разряда CB.

TBD.

### Black/White режим

Выводы 4-х разрядов CB, отвечающих за цветность управляются контрольным сигналом /BW.

Аналогичный транзистор для 2-х разрядов яркости просто всегда открыт:

![ppu_luma_tran](/BreakingNESWiki/imgstore/ppu/ppu_luma_tran.jpg)

## Организация памяти палитры

Выходы COL:

![ppu_palette_col_outputs](/BreakingNESWiki/imgstore/ppu/ppu_palette_col_outputs.jpg)

Precharge PCLK:

![ppu_palette_precharge](/BreakingNESWiki/imgstore/ppu/ppu_palette_precharge.jpg)

### Ячейка памяти

![ppu_palette_cell](/BreakingNESWiki/imgstore/ppu/ppu_palette_cell.jpg)

### Декодер индекса палитры

![ppu_palette_decoder](/BreakingNESWiki/imgstore/ppu/ppu_palette_decoder.jpg)
