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

## Pattern Address Generator

Схема занимает всю верхнюю часть и занимается формированием адреса тайла (Pattern), который задаётся `/PAD0-12` (13 бит).

![ppu_dataread_pattern_readout](/BreakingNESWiki/imgstore/ppu/ppu_dataread_pattern_readout.jpg)

![ppu_dataread_vinv](/BreakingNESWiki/imgstore/ppu/ppu_dataread_vinv.jpg)

![PatGen](/BreakingNESWiki/imgstore/ppu/PatGen.png)

Небольшие схемы для контроля загрузки значений в выходные защёлки. Основной акцент делается на выбор режима работы для спрайтов/бэкграунда (сигнал `PAR/O` - "PAR for Objects").

|![PatControl](/BreakingNESWiki/imgstore/ppu/PatControl.png)|![PatV_Inversion](/BreakingNESWiki/imgstore/ppu/PatV_Inversion.png)|
|---|---|

Схемы разрядов для формирования выходного значения `/PAD0-12` в незначительных вариациях:

|![PatBit](/BreakingNESWiki/imgstore/ppu/PatBit.png)|![PatBit4](/BreakingNESWiki/imgstore/ppu/PatBit4.png)|![PatBitInv](/BreakingNESWiki/imgstore/ppu/PatBitInv.png)|
|---|---|---|

## Остальное

Остальные части схемы находятся в соответствующих разделах:

- [Регистры скроллинга](scroll_regs.md)
- [Генератор адреса PAR](pargen.md)
- [Схема получения цвета бэкграунда](bgcol.md)
