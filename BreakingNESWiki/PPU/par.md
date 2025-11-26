## Picture Address Register (PAR)

![ppu_locator_par](/BreakingNESWiki/imgstore/ppu/ppu_locator_par.jpg)

Схема занимает всю верхнюю часть и занимается формированием адреса тайла (Pattern), который задаётся `/PAD0-12` (13 бит).

![par_high](/BreakingNESWiki/imgstore/ppu/par_high.jpg)

![par_vinv](/BreakingNESWiki/imgstore/ppu/par_vinv.jpg)

![PAR](/BreakingNESWiki/imgstore/ppu/PAR.png)

Небольшие схемы для контроля загрузки значений в выходные защёлки. Основной акцент делается на выбор режима работы для спрайтов/бэкграунда (сигнал `PAR/O` - "PAR for Objects").

|![ParControl](/BreakingNESWiki/imgstore/ppu/ParControl.png)|![ParV_Inversion](/BreakingNESWiki/imgstore/ppu/ParV_Inversion.png)|
|---|---|

Схемы разрядов для формирования выходного значения `/PAD0-12` в незначительных вариациях:

![ParBit](/BreakingNESWiki/imgstore/ppu/ParBit.png)

![ParBit4](/BreakingNESWiki/imgstore/ppu/ParBit4.png)

![ParBitInv](/BreakingNESWiki/imgstore/ppu/ParBitInv.png)

Таблица использования разрядов в адресации:

|Номер разряда|Источник для BG|Источник для OB (спрайты 8x8)|Источник для OB (спрайты 8x16)|Роль в адресации|
|---|---|---|---|---|
|0-2|Счётчик FV0-2|Схема сравнения спрайтов OV0-2|Схема сравнения спрайтов OV0-2|Номер строки паттерна|
|3|Сигнал /H1'|Сигнал /H1'|Сигнал /H1'|A/B байт строки паттерна|
|4|Name Table, бит 0|OAM2, Tile Index Byte, бит 0|Схема сравнения спрайтов OV3|Индекс в Pattern Table|
|5-11|Name Table, биты 1-7|OAM2, Tile Index Byte, биты 1-7|OAM2, Tile Index Byte, биты 1-7|Индекс в Pattern Table|
|12|BGSEL ($2000)|OBSEL ($2000)|OAM2, Tile Index Byte, бит 0|Выбор Pattern Table|