# Генератор видеосигнала

![ppu_locator_vid_out](/BreakingNESWiki/imgstore/ppu/ppu_locator_vid_out.jpg)

![vidout_logic](/BreakingNESWiki/imgstore/ppu/vidout_logic.jpg)

Входные сигналы:

|Сигнал|Откуда|Назначение|
|---|---|---|
|/CLK|CLK Pad|Первая половина цикла PPU|
|CLK|CLK Pad|Вторая половина цикла PPU|
|/PCLK|PCLK Distribution|Первая половина цикла Pixel Clock|
|PCLK|PCLK Distribution|Вторая половина цикла Pixel Clock|
|RES|/RES Pad|Глобальный сброс|
|#CC0-3|Color Buffer|4 разряда цветности текущего "пикселя" (инвертированное значение)|
|#LL0-1|Color Buffer|2 разряда яркости текущего "пикселя" (инвертированное значение)|
|BURST|FSM|Цветовая вспышка|
|SYNC|FSM|Импульс синхронизации|
|/PICTURE|FSM|Видимая часть строк|
|/TR|Regs $2001\[5\]|"Tint Red". Модифицирующее значение для Emphasis|
|/TG|Regs $2001\[6\]|"Tint Green". Модифицирующее значение для Emphasis|
|/TB|Regs $2001\[7\]|"Tint Blue". Модифицирующее значение для Emphasis|

## Фазовращатель

![vout_phase_shifter](/BreakingNESWiki/imgstore/ppu/vout_phase_shifter.jpg)

![vidout_phase_shifter_logic](/BreakingNESWiki/imgstore/ppu/vidout_phase_shifter_logic.jpg)

Схема одного разряда сдвигового регистра, применяемого в схеме фазовращателя:

![vidout_sr_bit_logic](/BreakingNESWiki/imgstore/ppu/vidout_sr_bit_logic.jpg)

## Декодер цветности

![vout_phase_decoder](/BreakingNESWiki/imgstore/ppu/vout_phase_decoder.jpg)

![vidout_chroma_decoder_logic](/BreakingNESWiki/imgstore/ppu/vidout_chroma_decoder_logic.jpg)

Декодер цветности выбирает одну из 12 фаз. 12 потому что:
- Серым полутонам фаза не требуется
- Для цветов 13-15 фазы не предусмотрено. При этом для цвета 13 есть возможность использовать яркость, а цвета 14-15 принудительно делаются "Black" с помощью сигнала `PBLACK`

Таблица соответствия выходов декодера и цветам PPU:

|Выход декодера цветности|Соответствующий цвет PPU|
|---|---|
|0|12|
|1|5|
|2|10|
|3|3|
|4|0. Не соединён с фазовращателем, так как серым полутонам фаза не требуется.|
|5|8. Также используется для фазы Color Burst|
|6|1|
|7|6|
|8|11|
|9|4|
|10|9|
|11|2|
|12|7|

(Нумерация выходов декодера топологическая, слева-направо, начиная с 0).

## Декодер яркости

|![vout_level_select](/BreakingNESWiki/imgstore/ppu/vout_level_select.jpg)|![vidout_luma_decoder_logic](/BreakingNESWiki/imgstore/ppu/vidout_luma_decoder_logic.jpg)|
|---|---|

Декодер яркости выбирает один из 4-х уровней яркости.

## Подстройка фазы

|![vout_emphasis](/BreakingNESWiki/imgstore/ppu/vout_emphasis.jpg)|![vidout_emphasis_logic](/BreakingNESWiki/imgstore/ppu/vidout_emphasis_logic.jpg)|
|---|---|

Если в фазовращателе выбран приглушаемый цвет и приглушение для этого цвета включено в контрольном регистре $2001, то активирует сигнал `TINT`, который немного понижает уровни напряжения, тем самым приглушая цвет.

## ЦАП

![vout_dac](/BreakingNESWiki/imgstore/ppu/vout_dac.jpg)

![vidout_dac_logic](/BreakingNESWiki/imgstore/ppu/vidout_dac_logic.jpg)
