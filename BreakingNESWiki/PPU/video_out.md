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
|#CC0-3|Color Buffer|4 разряда цветности текущего "пикселя"|
|#LL0-1|Color Buffer|2 разряда яркости текущего "пикселя"|
|BURST|FSM|Цветовая вспышка|
|HSYNC|FSM|Импульс горизонтальной синхронизации|
|PICTURE|FSM|Видимая часть строк|
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

## Декодер яркости

|![vout_level_select](/BreakingNESWiki/imgstore/ppu/vout_level_select.jpg)|![vidout_luma_decoder_logic](/BreakingNESWiki/imgstore/ppu/vidout_luma_decoder_logic.jpg)|
|---|---|

## Подстройка фазы

|![vout_emphasis](/BreakingNESWiki/imgstore/ppu/vout_emphasis.jpg)|![vidout_emphasis_logic](/BreakingNESWiki/imgstore/ppu/vidout_emphasis_logic.jpg)|
|---|---|

## ЦАП

![vout_dac](/BreakingNESWiki/imgstore/ppu/vout_dac.jpg)

![vidout_dac_logic](/BreakingNESWiki/imgstore/ppu/vidout_dac_logic.jpg)
