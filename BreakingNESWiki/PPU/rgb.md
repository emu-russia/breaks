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

## COLOR_BUFFER_BIT

![CB_BIT](/BreakingNESWiki/imgstore/ppu/rgb/CB_BIT.png)

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

## COLOR_DECODER_RED

![SEL16x12_RED](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_RED.png)

|Выход|Битовая маска|
|---|---|
|0|1010100001110110|
|1|1111000101010100|
|2|0000110101000000|
|3|0101111001100110|
|4|1000000001111011|
|5|0110110110110100|
|6|0001100101010011|
|7|1111101000110111|
|8|1010000001111000|
|9|1111110100111100|
|10|0110100101101001|
|11|1111100100010110|

(lsb первым, 1 означает что есть транзистор, 0 означает что транзистора нет)

## COLOR_DECODER_GREEN

![SEL16x12_GREEN](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_GREEN.png)

|Выход|Битовая маска|
|---|---|
|0|1010110001010110|
|1|0101010111100101|
|2|0000100101110000|
|3|1110101111001101|
|4|0001110011100001|
|5|0101111010010100|
|6|0100111111011000|
|7|1000001010111111|
|8|1010010001011110|
|9|0101110101011100|
|10|1010101111010110|
|11|1010010010111011|

(lsb первым, 1 означает что есть транзистор, 0 означает что транзистора нет)

## COLOR_DECODER_BLUE

![SEL16x12_BLUE](/BreakingNESWiki/imgstore/ppu/rgb/SEL16x12_BLUE.png)

|Выход|Битовая маска|
|---|---|
|0|1110100100100110|
|1|0111011110100100|
|2|1011101101111001|
|3|0110011011100010|
|4|0000100110000111|
|5|0111101110110100|
|6|1010101001100100|
|7|0110011010101110|
|8|1010100101000110|
|9|1111101111111100|
|10|1011101001100100|
|11|0010110010101110|

(lsb первым, 1 означает что есть транзистор, 0 означает что транзистора нет)

## RGB_DAC

![RGB_DACs](/BreakingNESWiki/imgstore/ppu/rgb/RGB_DACs.png)

## /SYNC

![RGB_SYNC](/BreakingNESWiki/imgstore/ppu/rgb/RGB_SYNC.png)

![nSYNC_PAD](/BreakingNESWiki/imgstore/ppu/rgb/nSYNC_PAD.png)
