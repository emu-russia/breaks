# Управляющая логика H/V

Логика H/V представляет собой конечный автомат (FSM), который управляет всеми остальными узлами PPU. Схематически это просто набор защелок, по типу "эта защелка активна от 64го до 128го пикселя", значит соответствующая контрольная линия идущая от этой защелки тоже активна.

В состав H/V FSM входят следующие компоненты:
- Схемы выдачи значений счетчика H с задержкой
- Горизонтальная логика, ассоциированная с H декодером
- Вертикальная логика, ассоциированная с V декодером
- Обработка прерывания PPU (VBlank)
- Схема EVEN/ODD
- Схема управления H/V счетчиками

![hv_fsm_all](/BreakingNESWiki/imgstore/ppu/hv_fsm_all.jpg)

Управляющая логика насыщена разного рода сигналами, которые приходят и уходят практически во все возможные узлы PPU.

Входные сигналы:

|Сигнал|Откуда|Описание|
|---|---|---|
|H0-5|HCounter|Разряды 0-5 HCounter, для выдачи наружу с задержкой.|
|V8|VCounter|Разряд 8 VCounter. Используется в логике EVEN/ODD.|
|/V8|VDecoder|Разряд 8 VCounter (инвертированное значение). Используется в логике EVEN/ODD.|
|HPLA_0-23|HDecoder|Выходы с декодера H|
|VPLA_0-8|VDecoder|Выходы с декодера V|
|/OBCLIP|Control Regs ($2001\[2\])|Для формирования контрольного сигнала `CLIP_O`|
|/BGCLIP|Control Regs ($2001\[1\])|Для формирования контрольного сигнала `CLIP_B`|
|BLACK|Control Regs|Активен когда рендеринг PPU отключен (см. $2001\[3\] и $2001\[4\])|
|DB7|Внутренняя шина данных DB|Для чтения $2002\[7\]. Используется в схеме обработки прерывания VBlank.|
|VBL|Control Regs ($2000\[7\])|Используется в схеме обработки прерывания VBlank.|
|/R2|Reg Select|Регистровая операция чтения $2002. Используется в схеме обработки прерывания VBlank.|
|/DBE|Контакт /DBE|Включение CPU интерфейса. Используется в схеме обработки прерывания VBlank.|
|RES|Контакт /RES|Глобальный сигнал сброса. Используется в логике EVEN/ODD.|

Выходные сигналы:

|Сигнал|Куда|Описание|
|---|---|---|
|**Выходы HCounter с задержкой**|||
|H0'|All|Сигнал H0 задержанный одним DLatch|
|/H1'|All|Сигнал H1 задержанный одним DLatch (в инверсной логике)|
|/H2'|All|Сигнал H2 задержанный одним DLatch (в инверсной логике)|
|H0''-H5''|All|Сигналы H0-H5 задержанные двумя DLatch|
|**Горизонтальные управляющие сигналы**|||
|S/EV|Sprite Logic|"Start Sprite Evaluation"|
|CLIP_O|Control Regs|"Clip Objects". Не показывать левые 8 точек экрана для спрайтов. Используется для получения сигнала `CLPO`, который уходит в OAM FIFO.|
|CLIP_B|Control Regs|"Clip Background". Не показывать левые 8 точек экрана для бэкграунда. Используется для получения сигнала `CLPB`, который уходит в Data Reader.|
|0/HPOS|OAM FIFO|"Clear HPos". Очистить счетчики H в [спрайтовой FIFO](fifo.md) и начать работу FIFO|
|EVAL|Sprite Logic|"Sprite Evaluation in Progress"|
|E/EV|Sprite Logic|"End Sprite Evaluation"|
|I/OAM2|Sprite Logic|"Init OAM2". Инициализировать дополнительную [OAM](oam.md)|
|PAR/O|All|"PAR for Object". Выборка тайла для объекта (спрайта).|
|/VIS|Sprite Logic|"Not Visible". Невидимая часть сигнала (использует [спрайтовая логика](sprite_eval.md))|
|F/NT|Data Reader|"Fetch Name Table"|
|F/TB|Data Reader|"Fetch Tile B"|
|F/TA|Data Reader|"Fetch Tile A"|
|/FO|Data Reader|"Fetch Output Enable"|
|F/AT|Data Reader|"Fetch Attribute Table"|
|SC/CNT|Data Reader|"Scroll Counters Control". Обновить регистры скроллинга.|
|BURST|Video Out|Цветовая вспышка|
|SYNC|Video Out|Импульс горизонтальной синхронизации|
|**Вертикальные управляющие сигналы**|||
|VSYNC|Video Out|Импульс вертикальной синхронизации|
|PICTURE|Video Out|Видимая часть строк|
|VB|HDecoder|Активен когда выводится невидимая часть видеосигнала (используется только H Decoder)|
|BLNK|HDecoder, All|Активен когда рендеринг PPU отключен (сигналом `BLACK`) или во время VBlank|
|RESCL (VCLR)|All|"Reset FF Clear" / "VBlank Clear". Событие окончания периода VBlank. Вначале была установлена связь с контактом /RES, но потом выяснилось более глобальное назначение сигнала. Поэтому у сигнала два названия.|
|**Прочее**|||
|HC|HCounter|"HCounter Clear". Очистить HCounter.|
|VC|VCounter|"VCounter Clear". Очистить VCounter.|
|V_IN|VCounter|"VCounter In". Выполнить инкремент VCounter.|
|INT|Контакт /INT|"Interrupt". Прерывание PPU|

Вспомогательные сигналы:

|Сигнал|Откуда|Куда|Описание|
|---|---|---|---|
|/FPORCH|Горизонтальная логика (FPORCH FF)|Получение контрольного сигнала `SYNC`|"Front Porch"|
|BPORCH|Горизонтальная логика (BPORCH FF)|Получение контрольного сигнала `PICTURE`|"Back Porch"|
|/HB|Горизонтальная логика (HBLANK FF)|Получение контрольного сигнала `VSYNC`|"HBlank"|
|/VSET|Вертикальная логика|Схема обработки прерывания VBlank|"VBlank Set". Событие начала периода VBlank.|
|EvenOddOut|Схема EVEN/ODD|Управление счетчиками H/V|Промежуточный сигнала для схемы управления HCounter.|

## Выдача наружу значений разрядов H

Разряды счетчика H0-H5 используются в других компонентах PPU.

Название сигнала с одним dash (например `/H2'`) означает что значение задержано одним DLatch. Название сигнала с двумя dash (например `H0''`) означает что значение задержано двумя DLatch.

Задержка вывода значений используется в PPU во многих местах (например выходы Color Buffer). Данный феномен пока не находит объяснений. Возможно это связано с учетом задержки работы остальных узлов PPU.

|Транзисторная схема|Логическая схема|
|---|---|
|![h_counter_output](/BreakingNESWiki/imgstore/ppu/h_counter_output.jpg)|![h_counter_output_logic](/BreakingNESWiki/imgstore/ppu/h_counter_output_logic.jpg)|

## Горизонтальная логика

"Горизонтальная" логика, отвечает за генерацию контрольных сигналов в зависимости от горизонтального положения луча (H):

Транзисторная схема:

![hv_fporch](/BreakingNESWiki/imgstore/ppu/hv_fporch.jpg)

![hv_fsm_horz](/BreakingNESWiki/imgstore/ppu/hv_fsm_horz.jpg)

Логическая схема:

![hv_fsm_horz_logic](/BreakingNESWiki/imgstore/ppu/hv_fsm_horz_logic.jpg)

В результате работы схема формирует следующую диаграмму сигналов:

![ppu_ntsc_line](/BreakingNESWiki/imgstore/ppu/ppu_ntsc_line.png)

(Некоторые сигналы, например `/FO` "подсвечены" на диаграмме инверсным образом, чтобы картинка была нагляднее)

## Вертикальная логика

Транзисторная схема:

![hv_fsm_vert](/BreakingNESWiki/imgstore/ppu/hv_fsm_vert.jpg)

Логическая схема:

![hv_fsm_vert_logic](/BreakingNESWiki/imgstore/ppu/hv_fsm_vert_logic.jpg)

## Обработка прерывания VBlank

|Транзисторная схема|Логическая схема|
|---|---|
|![hv_fsm_int](/BreakingNESWiki/imgstore/ppu/hv_fsm_int.jpg)|![hv_fsm_int_logic](/BreakingNESWiki/imgstore/ppu/hv_fsm_int_logic.jpg)|

Принцип работы:
- На входе находится edge детектор, который ловит событие начала VBlank (сигнал `/VSET`)
- Событие начала VBlank запоминается на INT_FF
- Сигнал `RESCL(VCLR)` очищает INT_FF
- Выходной сигнал `INT` уходит на внешний контакт `/INT` для сигнализрования внешних устройств о прерывании (CPU)
- Программист может узнать состояние флага прерывания (INT_FF) прочитав $2002\[7\]. При этом FF, где хранится флаг устроен так, что чтение флага также очищает его (см. 3-NOR на одном из плеч FF).

## Логика EVEN/ODD

![even_odd_tran](/BreakingNESWiki/imgstore/ppu/even_odd_tran.jpg)

(Для удобства схема положена "на бок")

Логика EVEN/ODD состоит из двух замкнутых друг на друга FF, управляемых двумя мультиплексорами. Получается миниатюрный счетчик Джонсона.

Данная схема реализует логику т.н. NTSC Crawl (ползание/дрожание). Это необходимо для исключения вывода 1 пикселя каждый кадр, чтобы снять кратность PCLK и поднесущей цветности, во избежание артефактов на Ч/Б телевизоре.

![even_odd_logic](/BreakingNESWiki/imgstore/ppu/even_odd_logic.jpg)

## Управление H/V счетчиками

Транзисторная схема:

![hv_counters_control](/BreakingNESWiki/imgstore/ppu/hv_counters_control.jpg)

Логическая схема:

![hv_counters_control_logic](/BreakingNESWiki/imgstore/ppu/hv_counters_control_logic.jpg)
