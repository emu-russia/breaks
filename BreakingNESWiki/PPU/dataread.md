# Схема выборки данных

В патенте PPU эта схема упоминается как `Still Picture Generator`.

Схема занимает почти четверть площади PPU и находится в правом нижнем углу микросхемы:

![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/ppu_locator_dataread.jpg)

Эта схема занимается выборкой строки тайла из 8 точек, на основе scroll-регистров, которые задают положение тайла в name table и точного (fine) смещения начальной точки внутри тайла.
Результаты (текущая точка тайла) передаются в мультиплексор, для смешивания с текущей точкой спрайта.

Также схема занимается получением паттернов спрайтов и их V инверсией (схема H инверсии находится в [OAM FIFO](fifo.md)).

Ввиду большого размера показать всю схему будет затруднительно, поэтому естественным образом распилим её на составные части.

Ниже показано из каких схем состоит Data Reader, чтобы понимать где искать напиленные куски схем:

![ppu_dataread_sections](/BreakingNESWiki/imgstore/ppu/ppu_dataread_sections.jpg)

В данном разделе исторически что-то было, но потом разъехалось по разделам. Осталась только схема для формирования адреса тайла.

![DataReader_All](/BreakingNESWiki/imgstore/ppu/DataReader_All.png)

## Pattern Address Generator

Схема занимает всю верхнюю часть и занимается формированием адреса тайла (Pattern), который задаётся `/PAD0-12` (13 бит).

![patgen_high](/BreakingNESWiki/imgstore/ppu/patgen_high.jpg)

![patgen_vinv](/BreakingNESWiki/imgstore/ppu/patgen_vinv.jpg)

![PatGen](/BreakingNESWiki/imgstore/ppu/PatGen.png)

Небольшие схемы для контроля загрузки значений в выходные защёлки. Основной акцент делается на выбор режима работы для спрайтов/бэкграунда (сигнал `PAR/O` - "PAR for Objects").

|![PatControl](/BreakingNESWiki/imgstore/ppu/PatControl.png)|![PatV_Inversion](/BreakingNESWiki/imgstore/ppu/PatV_Inversion.png)|
|---|---|

Схемы разрядов для формирования выходного значения `/PAD0-12` в незначительных вариациях:

![PatBit](/BreakingNESWiki/imgstore/ppu/PatBit.png)

![PatBit4](/BreakingNESWiki/imgstore/ppu/PatBit4.png)

![PatBitInv](/BreakingNESWiki/imgstore/ppu/PatBitInv.png)

Таблица использования разрядов в адресации:

|Номер разряда|Источник для BG|Источник для OB (спрайты 8x8)|Источник для OB (спрайты 8x16)|Роль в адресации|
|---|---|---|---|---|
|0-2|Счётчик FV0-2|Схема сравнения спрайтов OV0-2|Схема сравнения спрайтов OV0-2|Номер строки паттерна|
|3|Сигнал /H1'|Сигнал /H1'|Сигнал /H1'|A/B байт строки паттерна|
|4|Name Table, бит 0|OAM2, Tile Index Byte, бит 0|Схема сравнения спрайтов OV3|Индекс в Pattern Table|
|5-11|Name Table, биты 1-7|OAM2, Tile Index Byte, биты 1-7|OAM2, Tile Index Byte, биты 1-7|Индекс в Pattern Table|
|12|BGSEL ($2000)|OBSEL ($2000)|OAM2, Tile Index Byte, бит 0|Выбор Pattern Table|

## Остальное

Остальные части схемы находятся в соответствующих разделах:

- [Регистры скроллинга](scroll_regs.md)
- [Регистр адреса PAR](par.md)
- [Схема получения цвета бэкграунда](bgcol.md)
