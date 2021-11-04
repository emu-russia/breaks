# Схема выборки данных

Схема занимает почти четверть площади PPU и находится в правом нижнем углу микросхемы:

![DATAREAD_preview](/BreakingNESWiki/imgstore/DATAREAD_preview.jpg)

Эта схема занимается выборкой строки тайла из 8 точек, на основе scroll-регистров, которые задают положение тайла в name table и точного (fine) смещения начальной точки внутри тайла.
Результаты (текущая точка тайла) передаются в мультиплексор, для смешивания с текущей точкой спрайта.

Также схема занимается получением паттернов спрайтов и их V инверсией (схема H инверсии находится в [OAM FIFO](fifo.md)).

Ввиду большого размера показать всю схему будет затруднительно, поэтому естественным образом распилим её на составные части.

Ниже показано из каких схем состоит Data Reader, чтобы понимать где искать напиленные куски схем:

![ppu_dataread_sections](/BreakingNESWiki/imgstore/ppu_dataread_sections.jpg)

[Генератор адреса PAR](pargen.md) и [схема получения цвета бэкраунда (BG COL)](bgcol.md) переехали в собственные разделы.

## Pattern Readout

![ppu_dataread_pattern_readout](/BreakingNESWiki/imgstore/ppu_dataread_pattern_readout.jpg)

## V. Inversion

![ppu_dataread_vinv](/BreakingNESWiki/imgstore/ppu_dataread_vinv.jpg)
