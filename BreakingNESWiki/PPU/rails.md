# Управляющие сигналы

Данный раздел содержит сводную таблицу всех сигналов.

Если сигнал где-то повторяется, то он обычно не указывается повторно, за исключением случаев, где он имеет важное значение.

Сигналы для PAL-версии PPU отмечены на картинках только там, где есть отличия от NTSC.

Специальным значком (:zap:) отмечены важные управляющие сигналы PPU [FSM](fsm.md).

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
|/EXT0-3 OUT|EXT Pads|MUX|Выходной цвет для Slave PPU|
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
|V0-7|VCounter|Sprite Compare, Sprite Eval|Разряды счётчика V. Разряд V7 дополнительно уходит в логику Sprite Eval.|
|:zap:RESCL (VCLR)|FSM|All|"Reset FF Clear" / "VBlank Clear". Событие окончания периода VBlank. Вначале была установлена связь с контактом /RES, но потом выяснилось более глобальное назначение сигнала. Поэтому у сигнала два названия.|
|OMFG|Sprite Eval|OAM Counters Ctrl|TBD: Контрольный сигнал|
|:zap:BLNK|FSM|HDecoder, All|Активен когда рендеринг PPU отключен (сигналом `BLACK`) или во время VBlank|
|:zap:PAR/O|FSM|All|"PAR for Object". Выборка тайла для объекта (спрайта)|
|ASAP|OAM Counters Ctrl|OAM Counters Ctrl|TBD: Контрольный сигнал|
|:zap:/VIS|FSM|Sprite Logic|"Not Visible". Невидимая часть сигнала (использует спрайтовая логика)|
|:zap:I/OAM2|FSM|Sprite Logic|"Init OAM2". Инициализировать дополнительную OAM|
|/H2'|HCounter|All|Сигнал H2 задержанный одним DLatch (в инверсной логике)|
|SPR_OV|OAM Counters Ctrl|Sprite Eval|Cпрайтов на текущей строке больше 8 или главный счётчик OAM переполнен, копирование прекращено|
|:zap:/EVAL|FSM|Sprite Logic|0: "Sprite Evaluation in Progress"|
|H0'|HCounter|All|Сигнал H0 задержанный одним DLatch|
|EvenOddOut|Even/Odd Circuit|OAM Counters Ctrl|:warning: Только для PAL PPU.|

|NTSC|PAL|
|---|---|
|![ntsc_rails2](/BreakingNESWiki/imgstore/ppu/ntsc_rails2.jpg)|![pal_rails2](/BreakingNESWiki/imgstore/ppu/pal_rails2.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|:zap:E/EV|FSM|Sprite Logic|"End Sprite Evaluation"|
|:zap:S/EV|FSM|Sprite Logic|"Start Sprite Evaluation"|
|/H1'|HCounter|All|Сигнал H1 задержанный одним DLatch (в инверсной логике)|
|/H2'|HCounter|All|Сигнал H2 задержанный одним DLatch (в инверсной логике)|
|:zap:/FO|FSM|Data Reader|"Fetch Output Enable"|
|:zap:F/AT|FSM|Data Reader|"Fetch Attribute Table"|
|:zap:#F/NT|FSM|Data Reader, OAM Eval|0: "Fetch Name Table"|
|:zap:F/TA|FSM|Data Reader|"Fetch Tile A"|
|:zap:F/TB|FSM|Data Reader|"Fetch Tile B"|
|:zap:CLIP_O|FSM|Control Regs|"Clip Objects". 1: Не показывать левые 8 точек экрана для спрайтов. Используется для получения сигнала `CLPO`, который уходит в OAM FIFO.|
|:zap:CLIP_B|FSM|Control Regs|"Clip Background". 1: Не показывать левые 8 точек экрана для бэкграунда. Используется для получения сигнала `/CLPB`, который уходит в Data Reader.|
|VBL|Regs $2000\[7\]|FSM|Используется в схеме обработки прерывания VBlank|
|/TB|Regs $2001\[7\]|VideoOut|"Tint Blue". Модифицирующее значение для Emphasis|
|/TG|Regs $2001\[6\]|VideoOut|"Tint Green". Модифицирующее значение для Emphasis|
|/TR|Regs $2001\[5\]|VideoOut|"Tint Red". Модифицирующее значение для Emphasis|
|:zap:SC/CNT|FSM|Data Reader|"Scroll Counters Control". Обновить регистры скроллинга.|
|:zap:0/HPOS|FSM|OAM FIFO|"Clear HPos". Очистить счётчики H в спрайтовой FIFO и начать работу FIFO|
|/SPR0_EV|Sprite Eval|Spr0 Strike|0: Cпрайт "0" найден на текущей строке. Для определения события `Sprite 0 Hit`|
|/OBCLIP|Regs $2001\[2\]|FSM|Для формирования контрольного сигнала `CLIP_O`|
|/BGCLIP|Regs $2001\[1\]|FSM|Для формирования контрольного сигнала `CLIP_B`|
|H0'' - H5''|HCounter|All|Сигналы H0-H5 задержанные двумя DLatch|
|BLACK|Control Regs|FSM|Активен когда рендеринг PPU отключен (см. $2001[3] и $2001[4]). :warning: Схема для генерации сигнала немного отличается в PAL PPU.|
|DB0-7|All|All|Внутренняя шина данных DB|
|B/W|Regs $2001\[0\]|Color Buffer|Отключить Color Burst, для генерации монохромного изображения|
|TH/MUX|VRAM Ctrl|MUX, Color Buffer|Направить значение TH Counter на вход MUX, в результате чего это значение уйдет в палитру в качестве Direct Color.|
|DB/PAR|VRAM Ctrl|Data Reader, Color Buffer|TBD: Контрольный сигнал|

|NTSC|PAL|
|---|---|
|![ntsc_rails3](/BreakingNESWiki/imgstore/ppu/ntsc_rails3.jpg)|![pal_rails3](/BreakingNESWiki/imgstore/ppu/pal_rails3.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|PAL0-4|MUX|Palette|Адрес Palette RAM|

## Правая часть

![ppu_locator_rails_right](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_right.jpg)

|Версия PPU|Изображение|
|---|---|
|NTSC|![ntsc_rails4](/BreakingNESWiki/imgstore/ppu/ntsc_rails4.jpg)
|PAL|![pal_rails4](/BreakingNESWiki/imgstore/ppu/pal_rails4.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|/OAM0-2|OAM Counters|OAM|Адрес OAM. :warning: NTSC-версия PPU использует значения в инверсной логике (/OAM0-7). PAL-версия PPU использует значения в прямой логике (OAM0-7)|
|OAM8|OAM2 Counter|OAM|Выбирает дополнительную OAM для адресации|

|NTSC|PAL|
|---|---|
|![ntsc_rails5](/BreakingNESWiki/imgstore/ppu/ntsc_rails5.jpg)|![rails5](/BreakingNESWiki/imgstore/ppu/pal_rails5.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|/OAM0-7|OAM Counters|OAM|Адрес OAM. :warning: NTSC-версия PPU использует значения в инверсной логике (/OAM0-7). PAL-версия PPU использует значения в прямой логике (OAM0-7)|
|OAM8|OAM2 Counter|OAM|Выбирает дополнительную OAM для адресации|
|OAMCTR2|OAM Counters Ctrl|OAM Buffer Ctrl|Управление OAM Buffer.|
|OB0-7'|OAM Buffer|Sprite Compare|Выходные значения OB, пройденные через PCLK-тристейты.|

Примечание: Разная инверсность значений адреса OAM у PAL и NTSC PPU приводит к тому, что значения на ячейках в PAL PPU хранятся в обратном порядке относительно NTSC PPU. Больше ни к чему особенному это не приводит.

|NTSC|PAL|
|---|---|
|![ntsc_rails6](/BreakingNESWiki/imgstore/ppu/ntsc_rails6.jpg)|![rails6](/BreakingNESWiki/imgstore/ppu/pal_rails6.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|OV0-3|Sprite Compare|V Inversion|Разряды 0-3 значения V спрайта|
|OB7|OAM Buffer|OAM Eval|Выходное значение OAM Buffer, разряд 7. Для схемы OAM Eval это значение эксклюзивно передается сразу с OB, не используя PCLK-тристейт.|
|PD/FIFO|OAM Eval|H Inversion|Для зануления выхода схемы H. Inv|
|I1/32|Regs $2000\[2\]|PAR Counters Ctrl|Increment PPU address 1/32. :warning: Для PAL PPU используется инверсная версия сигнала (#I1/32)|
|OBSEL|Regs $2000\[3\]|Pattern Readout|Выбор Pattern Table для спрайтов|
|BGSEL|Regs $2000\[4\]|Pattern Readout|Выбор Pattern Table для бэкграунда|
|O8/16|Regs $2000\[5\]|OAM Eval, Pattern Readout|Object lines 8/16 (размер спрайта). :warning: Для PAL PPU используется инверсная версия сигнала (#O8/16)|

|NTSC|PAL|
|---|---|
|![ntsc_rails7](/BreakingNESWiki/imgstore/ppu/ntsc_rails7.jpg)|![rails7](/BreakingNESWiki/imgstore/ppu/pal_rails7.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|/SH2|Near MUX|OAM FIFO, V. Inversion|Разряды значения Sprite H. /SH2 также уходит в схему V. Inversion.|
|/SH3|Near MUX|OAM FIFO|Разряды значения Sprite H|
|/SH5|Near MUX|OAM FIFO|Разряды значения Sprite H|
|/SH7|Near MUX|OAM FIFO|Разряды значения Sprite H|
|/SPR0HIT|OAM Priority|Spr0 Strike|Для определения события `Sprite 0 Hit`|
|BGC0-3|BG Color|MUX|Цвет бэкграунда|
|/ZCOL0, /ZCOL1, ZCOL2, ZCOL3|OAM FIFO|MUX|Цвет спрайта. :warning: Младшие 2 разряда в инверсной логике, старшие 2 разряда - в прямой логике.|
|/ZPRIO|OAM Priority|MUX|0: Приоритет спрайта над бэкграундом|
|THO0-4'|PAR TH Counter|MUX|Значение THO0-4, пройденные через PCLK-тристейт. Значение Direct Color с TH Counter.|

## Нижняя часть

![ppu_locator_rails_bottom](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_bottom.jpg)

|Версия PPU|Изображение|
|---|---|
|NTSC|![ntsc_rails8](/BreakingNESWiki/imgstore/ppu/ntsc_rails8.jpg)|
|PAL|![pal_rails8](/BreakingNESWiki/imgstore/ppu/pal_rails8.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|OB0-7|OAM Buffer|OAM FIFO, Pattern Readout|Выходное значение OAM Buffer|
|CLPO|Regs|OAM FIFO|Для включения обрезки спрайтов|
|/CLPB|Regs|BG Color|Для включения обрезки бэкграунда|
|PD/FIFO|OAM Eval|H Inversion|Для зануления выхода схемы H. Inv|
|BGSEL|Regs|Pattern Readout|Выбор Pattern Table для бэкграунда|
|OV0-3|Sprite Compare|V Inversion|Разряды 0-3 значения V спрайта|

|NTSC|PAL|
|---|---|
|![ntsc_rails9](/BreakingNESWiki/imgstore/ppu/ntsc_rails9.jpg)|![pal_rails9](/BreakingNESWiki/imgstore/ppu/pal_rails9.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|/PA0-7|PAR|PPU Address|Адресная шина VRAM|
|/PA8-13|PAR|PPU Address, VRAM Ctrl|Адресная шина VRAM|
|THO0-4|PAR TH Counter|BG Color, MUX|Разряд 1 TH Counter используется в схеме BG Color. THO0-4 используется в мультиплексоре как Direct Color.|
|TSTEP|VRAM Ctrl|PAR Counters Ctrl|Для логики управления PAR Counters|
|TVO1|PAR TV Counter|BG Color|Разряд 1 TV Counter|
|FH0-2|Scroll Regs|BG Color|Значение Fine H|

`/PA0-7` не показаны на картинке, находятся в правой части [Регистра адреса PPU](par.md).

|NTSC|PAL|
|---|---|
|![ntsc_rails10](/BreakingNESWiki/imgstore/ppu/ntsc_rails10.jpg)|![pal_rails10](/BreakingNESWiki/imgstore/ppu/pal_rails10.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|PD0-7|All Bottom|All Bottom|Шина данных VRAM, используется в нижней части для передачи данных. Ассоциирована с соответствующими контактами PPU (`AD0-7`).|
|THO1|PAR TH Counter|BG Color|Разряд 1 TH Counter|
|TVO1|PAR TV Counter|BG Color|Разряд 1 TV Counter|
|BGC0-3|BG Color|MUX|Цвет бэкграунда|
|FH0-2|Scroll Regs|BG Color|Значение Fine H|

|Версия PPU|Изображение|
|---|---|
|NTSC|![ntsc_rails11](/BreakingNESWiki/imgstore/ppu/ntsc_rails11.jpg)|
|PAL|![pal_rails11](/BreakingNESWiki/imgstore/ppu/pal_rails11.jpg)|

|Сигнал|Откуда|Куда|Назначение|
|---|---|---|---|
|PD/RB|VRAM Ctrl|Read Buffer (RB)|Открывает вход RB (соединить PD и RB).|
|XRB|VRAM Ctrl|Read Buffer (RB)|Открывает выход RB (соединить RB и DB).|
|RD|VRAM Ctrl|Pad|Выходное значение для контакта `/RD`|
|WR|VRAM Ctrl|Pad|Выходное значение для контакта `/WR`|
|/ALE|VRAM Ctrl|Pad|Выходное значение для контакта `ALE`|
