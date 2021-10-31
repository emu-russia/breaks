# Схема выборки данных

Схема занимает почти четверь площади PPU и находится в правом нижнем углу микросхемы:

![DATAREAD_preview](/BreakingNESWiki/imgstore/DATAREAD_preview.jpg)

Эта схема занимается выборкой строки тайла из 8 точек, на основе scroll-регистров, которые задают положение тайла в name table и точного (fine) смещения начальной точки внутри тайла.
Результаты (текущая точка тайла) передаются в мультиплексор, для смешивания с текущей точкой спрайта.

Также схема занимается получением паттернов спрайтов и их H/V инверсией.

Кроме этого в состав схемы также входит READ BUFFER (RB) - промежуточное хранилище данных для обмена с VRAM.

Ввиду большого размера показать всю схему будет затруднительно, поэтому естественным образом распилим её на составные части.

Ниже показано из каких схем состоит Data Reader, чтобы понимать где искать напиленные куски схем:

![ppu_dataread_sections](/BreakingNESWiki/imgstore/ppu_dataread_sections.jpg)

## Pattern Readout

![ppu_dataread_pattern_readout](/BreakingNESWiki/imgstore/ppu_dataread_pattern_readout.jpg)

## V. Inversion

![ppu_dataread_vinv](/BreakingNESWiki/imgstore/ppu_dataread_vinv.jpg)

## Спаренные регистры $2005/$2006

### Fine HScroll

![ppu_dataread_dualregs_fh](/BreakingNESWiki/imgstore/ppu_dataread_dualregs_fh.jpg)

### Fine VScroll

![ppu_dataread_dualregs_fv](/BreakingNESWiki/imgstore/ppu_dataread_dualregs_fv.jpg)

### Выбор Name Table

![ppu_dataread_dualregs_nt](/BreakingNESWiki/imgstore/ppu_dataread_dualregs_nt.jpg)

### Tile V

![ppu_dataread_dualregs_tv](/BreakingNESWiki/imgstore/ppu_dataread_dualregs_tv.jpg)

### Tile H

![ppu_dataread_dualregs_th](/BreakingNESWiki/imgstore/ppu_dataread_dualregs_th.jpg)

## Счетчики PAR

### Схема управления счетчиками PAR

![ppu_dataread_par_counters_control_top](/BreakingNESWiki/imgstore/ppu_dataread_par_counters_control_top.jpg)

![ppu_dataread_par_counters_control_bot](/BreakingNESWiki/imgstore/ppu_dataread_par_counters_control_bot.jpg)

### Счетчик FV

![ppu_dataread_par_counters_fv](/BreakingNESWiki/imgstore/ppu_dataread_par_counters_fv.jpg)

### Счетчики NT

![ppu_dataread_par_counters_nt](/BreakingNESWiki/imgstore/ppu_dataread_par_counters_nt.jpg)

### Счетчик TV

![ppu_dataread_par_counters_tv](/BreakingNESWiki/imgstore/ppu_dataread_par_counters_tv.jpg)

### Счетчик TH

![ppu_dataread_par_counters_th](/BreakingNESWiki/imgstore/ppu_dataread_par_counters_th.jpg)

## PAR

### Схема контроля PAR

![ppu_dataread_par_control](/BreakingNESWiki/imgstore/ppu_dataread_par_control.jpg)

### Разряды PAR

![ppu_dataread_par_low](/BreakingNESWiki/imgstore/ppu_dataread_par_low.jpg)

![ppu_dataread_par_high](/BreakingNESWiki/imgstore/ppu_dataread_par_high.jpg)

## Схема получения цвета бэкграунда (BG COL)

### Управление схемой BG COL

![ppu_dataread_bgcol_control_left](/BreakingNESWiki/imgstore/ppu_dataread_bgcol_control_left.jpg)

![ppu_dataread_bgcol_control_right](/BreakingNESWiki/imgstore/ppu_dataread_bgcol_control_right.jpg)

### Получение BGC0

![ppu_dataread_bgc0](/BreakingNESWiki/imgstore/ppu_dataread_bgc0.jpg)

### Получение BGC1

![ppu_dataread_bgc1](/BreakingNESWiki/imgstore/ppu_dataread_bgc1.jpg)

### Получение BGC2

![ppu_dataread_bgc2](/BreakingNESWiki/imgstore/ppu_dataread_bgc2.jpg)

### Получение BGC3

![ppu_dataread_bgc3](/BreakingNESWiki/imgstore/ppu_dataread_bgc3.jpg)

### Выходы BG COL

![ppu_dataread_bgcol_out](/BreakingNESWiki/imgstore/ppu_dataread_bgcol_out.jpg)

## Read Buffer (RB)

![ppu_readbuffer](/BreakingNESWiki/imgstore/ppu_readbuffer.jpg)

## H. Inversion

![ppu_hinv](/BreakingNESWiki/imgstore/ppu_hinv.jpg)
