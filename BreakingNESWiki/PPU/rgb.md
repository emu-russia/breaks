# RGB PPU

В данном разделе рассматриваются отличия RGB PPU RP2C04-0003, от референсного PPU 2C02G.

На данный момент это единственные изображения RGB PPU, которыми мы располагаем. При этом есть фотографии только верхнего слоя, поэтому не всегда хорошо видно что находится под ним. Что-то частично удалось разглядеть, частично угадать, поэтому тут больше похоже на японский сканворд.

Список основных отличий:
- Контакты EXT0-3 и VOUT заменены на контакты RED, GREEN, BLUE, /SYNC, для вывода компонентного видеосигнала.
- Вместо генератора композитного видео используется схема RGB-кодирования. ЦАП с суммированием весовых токов.
- Эмфазис включает соответствующий выход канала на все единицы
- Отсутствует возможность чтения OAM (нет регистровой операции `/R4`), по этой причине OAM Buffer устроен проще
- Отсутствует возможность чтения CRAM, по этой причине Color Buffer устроен проще

Есть предположение, что остальные RGB PPU не сильно отличаются от рассматриваемой 2C04-0003, поэтому этот раздел будет дополняться по мере получения фотографий других ревизий RGB PPU.

|Номер|Контакт 2C02G|Контакт RGB PPU|
|---|---|---|
|14|EXT0|RED|
|15|EXT1|GREEN|
|16|EXT2|BLUE|
|17|EXT3|AGND|
|21|VOUT|/SYNC|

Далее будут просто восстановленные схемы. Оригинальные изображения RGB PPU можно найти тут: https://siliconpr0n.org/map/nintendo/rp2c04-0003/

![2C04-0003_RGB_PPU](/BreakingNESWiki/imgstore/ppu/rgb/2C04-0003_RGB_PPU.png)

## FSM

За основу взят FSM 2С02.

![HV_FSM](/BreakingNESWiki/imgstore/ppu/rgb/HV_FSM.png)

Схема получения сигнала `BURST` присутствует, но не сам сигнал не используется.

![FSM_BURST](/BreakingNESWiki/imgstore/ppu/rgb/FSM_BURST.jpg)

## EVEN/ODD

Схема Even/Odd присутствует но отключена, вход NOR, куда приходил сигнал `EvenOddOut` заземлен на корпус.

![evenodd_rgb](/BreakingNESWiki/imgstore/ppu/rgb/evenodd_rgb.png)

![evdd](/BreakingNESWiki/imgstore/ppu/rgb/evdd.png)

## COLOR_CONTROL

![COLOR_CONTROL](/BreakingNESWiki/imgstore/ppu/rgb/COLOR_CONTROL.png)

## CRAM

![COLOR_RAM](/BreakingNESWiki/imgstore/ppu/rgb/COLOR_RAM.png)

## REG_SELECT

![REG_SELECT](/BreakingNESWiki/imgstore/ppu/rgb/REG_SELECT.png)

## CONTROL_REGS

Сигнал `/SLAVE` не используется.

![Control_REGs](/BreakingNESWiki/imgstore/ppu/rgb/Control_REGs.png)

## MUX

Входные сигналы `EXT_IN` равны `0`, а выходные сигналы `/EXT_OUT` не используются.

![MUX](/BreakingNESWiki/imgstore/ppu/rgb/MUX.png)

## OAM_BUF_CONTROL

Уменьшена задержка при записи. Количество защёлок на 2 меньше, по сравнению с композитными ревизиями PPU.

![OAM_BUF_CONTROL](/BreakingNESWiki/imgstore/ppu/rgb/OAM_BUF_CONTROL.png)

## OAM_BIT

![2C04_OAM_buf](/BreakingNESWiki/imgstore/ppu/rgb/2C04_OAM_buf.jpg)

## Video Out

![RGB_VIDEO_OUT](/BreakingNESWiki/imgstore/ppu/rgb/RGB_VIDEO_OUT.png)

## SEL_12x3

![SEL12x3](/BreakingNESWiki/imgstore/ppu/rgb/SEL12x3.png)

FF:

![SEL12x3_FF](/BreakingNESWiki/imgstore/ppu/rgb/SEL12x3_FF.png)

## COLOR_DECODER_BLUE

![SEL16x12_BLUE](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_BLUE.png)

|Выход|Битовая маска|
|---|---|
|0|0b1001101101101000|
|1|0b1101101000010001|
|2|0b0110000100100010|
|3|0b1011100010011001|
|4|0b0001111001101111|
|5|0b1101001000100001|
|6|0b1101100110101010|
|7|0b1000101010011001|
|8|0b1001110101101010|
|9|0b1100000010100000|
|10|0b1101100110100010|
|11|0b1000101011001011|

## COLOR_DECODER_GREEN

![SEL16x12_GREEN](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_GREEN.png)

|Выход|Битовая маска|
|---|---|
|0|0b1001010111001010|
|1|0b0101100001010101|
|2|0b1111000101101111|
|3|0b0100110000101000|
|4|0b0111100011000111|
|5|0b1101011010000101|
|6|0b1110010000001101|
|7|0b0000001010111110|
|8|0b1000010111011010|
|9|0b1100010101000101|
|10|0b1001010000101010|
|11|0b0010001011011010|

## COLOR_DECODER_RED

![SEL16x12_RED](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_RED.png)

|Выход|Битовая маска|
|---|---|
|0|0b1001000111101010|
|1|0b1101010101110000|
|2|0b1111110101001111|
|3|0b1001100110000101|
|4|0b0010000111111110|
|5|0b1101001001001001|
|6|0b0011010101100111|
|7|0b0001001110100000|
|8|0b1110000111111010|
|9|0b1100001101000000|
|10|0b0110100101101001|
|11|0b1001011101100000|

## RGB_DAC

![RGB_DACs](/BreakingNESWiki/imgstore/ppu/rgb/RGB_DACs.png)

## /SYNC

![RGB_SYNC](/BreakingNESWiki/imgstore/ppu/rgb/RGB_SYNC.png)

![nSYNC_PAD](/BreakingNESWiki/imgstore/ppu/rgb/nSYNC_PAD.png)
