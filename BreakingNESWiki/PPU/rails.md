# Управляющие сигналы

Данный раздел содержит сводную таблицу всех сигналов.

TBD: Инверсность некоторых сигналов может быть исправлена после уточнения. В настоящее время основная задача - понять их суть.

Если сигнал где-то повторяется, то он обычно не указывается повторно, за исключением случаев, где он имеет важное значение.

Сигналы для PAL-версии PPU отмечены на картинках только там, где есть отличия от NTSC.

## Левая часть

![ppu_locator_rails_left](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_left.jpg)

|NTSC|PAL|
|---|---|
|![ntsc_rails1](/BreakingNESWiki/imgstore/ppu/ntsc_rails1.jpg)|![pal_rails1](/BreakingNESWiki/imgstore/ppu/pal_rails1.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|PCLK|PCLK Gen|All|PPU находится в стейте PCLK=1|
|/PCLK|PCLK Gen|All|PPU находится в стейте PCLK=0|
|RC|/RES Pad|Regs|"Registers Clear", очистить регистры|
|EXT0-3 IN|EXT Pads|MUX|Входной подмешиваемый цвет от Master PPU|
|EXT0-3 OUT|EXT Pads|MUX|Выходной цвет для Slave PPU|
|/SLAVE|Regs $2000\[6\]|EXT Pads|Режим работы PPU (Master/Slave)|
|R/W|R/W Pad|RW Decoder, Reg Select|Режим работы CPU интерфейса (чтение/запись)|
|/DBE|/DBE Pad|Regs|"Data Bus Enable", включение CPU интерфейса|
|RS0-3|RS Pads|Reg Select|Выбор регистра для CPU интерфейса|
|/W6/1|Reg Select| |Первая запись в регистр $2006|
|/W6/2|Reg Select| |Вторая запись в регистр $2006|
|/W5/1|Reg Select| |Первая запись в регистр $2005|
|/W5/2|Reg Select| |Вторая запись в регистр $2005|
|/R7|Reg Select| |Чтение регистра $2007|
|/W7|Reg Select| |Запись в регистр $2007|
|/W4|Reg Select| |Запись в регистр $2004|
|/W3|Reg Select| |Запись в регистр $2003|
|/R2|Reg Select| |Чтение регистра $2002|
|/W1|Reg Select| |Запись в регистр $2001|
|/W0|Reg Select| |Запись в регистр $2000|
|/R4|Reg Select| |Чтение регистра $2004|
|V0-7|VCounter| |Разряды счетчика V|
|RESCL| | |"RES FF Clear". Очистить защелку контакта /RES|
|OMFG| | | |
|BLNK| | | |
|PAR/O| | | |
|ASAP| | | |
|/VIS| | | |
|I/OAM2| | | |
|/H2'| | | |
|SPR_OV| | | |
|EVAL| | | |
|H0'| | | |

|NTSC|PAL|
|---|---|
|![ntsc_rails2](/BreakingNESWiki/imgstore/ppu/ntsc_rails2.jpg)|![pal_rails2](/BreakingNESWiki/imgstore/ppu/pal_rails2.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|E/EV| | | |
|S/EV| | | |
|/H1'| | | |
|/H2'| | | |
|/FO| | | |
|F/AT| | | |
|F/NT| | | |
|F/TA| | | |
|F/TB| | | |
|CLIP_O| | | |
|CLIP_B| | | |
|VBL|Regs $2000\[7\]| | |
|/TB|Regs $2001\[7\]| |"Tint Blue". Модифицирующее значение для Emphasis|
|/TG|Regs $2001\[6\]| |"Tint Green". Модифицирующее значение для Emphasis|
|/TR|Regs $2001\[5\]| |"Tint Red". Модифицирующее значение для Emphasis|
|SC/CNT| | | |
|0/HPOS| | | |
|I2SEV| | | |
|/OBCLIP|Regs $2001\[2\]| | |
|/BGCLIP|Regs $2001\[1\]| | |
|H0'' - H5''| | | |
|BLACK| | | |
|DB0-7| | | |
|B/W|Regs $2001\[0\]| | |
|TH/MUX| | | |
|DB/PAR| | | |

|NTSC|PAL|
|---|---|
|![ntsc_rails3](/BreakingNESWiki/imgstore/ppu/ntsc_rails3.jpg)|![pal_rails3](/BreakingNESWiki/imgstore/ppu/pal_rails3.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|PAL0-4| | | |

## Правая часть

![ppu_locator_rails_right](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_right.jpg)

|Версия PPU|Изображение|
|---|---|
|NTSC|![ntsc_rails4](/BreakingNESWiki/imgstore/ppu/ntsc_rails4.jpg)
|PAL|![pal_rails4](/BreakingNESWiki/imgstore/ppu/pal_rails4.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|/OAM0-2| | | |
|OAM8| | | |

|NTSC|PAL|
|---|---|
|![ntsc_rails5](/BreakingNESWiki/imgstore/ppu/ntsc_rails5.jpg)|![rails5](/BreakingNESWiki/imgstore/ppu/pal_rails5.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|/OAM0-7| | | |
|OAM8| | | |
|OAMCTR2| | | |
|OB0-7'| | | |

|NTSC|PAL|
|---|---|
|![ntsc_rails6](/BreakingNESWiki/imgstore/ppu/ntsc_rails6.jpg)|![rails6](/BreakingNESWiki/imgstore/ppu/pal_rails6.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|OV0-3| | | |
|OB7| | | |
|0/FIFO| | | |
|I1/32|Regs $2000\[2\]| |Increment PPU address 1/32. Для PAL PPU используется инверсная версия сигнала (#I1/32)|
|OGSEL|Regs $2000\[3\]| | |
|BGSEL|Regs $2000\[4\]| | |
|O8/16|Regs $2000\[5\]| |Object lines 8/16 (размер спрайта). Для PAL PPU используется инверсная версия сигнала (#O8/16)|

|NTSC|PAL|
|---|---|
|![ntsc_rails7](/BreakingNESWiki/imgstore/ppu/ntsc_rails7.jpg)|![rails7](/BreakingNESWiki/imgstore/ppu/pal_rails7.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|SH2| | | |
|SH3| | | |
|SH5| | | |
|SH7| | | |
|SPR0HIT| | | |
|BGC0-3| | | |
|ZCOL0-3| | | |
|ZPRIO| | | |
|THO0-4'| | | |

## Нижная часть

![ppu_locator_rails_bottom](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_bottom.jpg)

|Версия PPU|Изображение|
|---|---|
|NTSC|![ntsc_rails8](/BreakingNESWiki/imgstore/ppu/ntsc_rails8.jpg)|
|PAL|![pal_rails8](/BreakingNESWiki/imgstore/ppu/pal_rails8.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|OB0-7| | | |
|CLPO| | | |
|CLPB| | | |
|0/FIFO| | | |
|BGSEL| | | |
|OV0-3| | | |

|NTSC|PAL|
|---|---|
|![ntsc_rails9](/BreakingNESWiki/imgstore/ppu/ntsc_rails9.jpg)|![pal_rails9](/BreakingNESWiki/imgstore/ppu/pal_rails9.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|/PA0-7| | | |
|/PA8-13| | | |
|THO0-4| | | |
|TSTEP| | | |
|TVO1| | | |
|FH0-2| | | |

`/PA0-7` не показаны на картинке, находятся в правой части [Генератора адреса PPU](pargen.md).

|NTSC|PAL|
|---|---|
|![ntsc_rails10](/BreakingNESWiki/imgstore/ppu/ntsc_rails10.jpg)|![pal_rails10](/BreakingNESWiki/imgstore/ppu/pal_rails10.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|PD0-7| | | |
|THO1| | | |
|TVO1| | | |
|BGC0-3| | | |
|FH0-2| | | |

|Версия PPU|Изображение|
|---|---|
|NTSC|![ntsc_rails11](/BreakingNESWiki/imgstore/ppu/ntsc_rails11.jpg)|
|PAL|![pal_rails11](/BreakingNESWiki/imgstore/ppu/pal_rails11.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|PD/RB| | | |
|XRB| | | |
|RD| | | |
|WR| | | |
|/ALE| | | |
