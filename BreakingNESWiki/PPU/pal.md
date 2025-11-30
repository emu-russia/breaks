# PAL PPU

Данный раздел содержит описание отличий в схемах версии PAL PPU (RP2C07) от референсной NTSC PPU (RP2C02).

## FSM

Найденные отличия от NTSC PPU.

Значительно отличается схема EVEN/ODD (расположена справа от V PLA). Сигнал `EvenOddOut` вместо управления счётчиками H/V уходит в спрайтовую логику:

![fsm_even_odd](/BreakingNESWiki/imgstore/ppu/pal/fsm_even_odd.png)

![EvenOdd_PAL](/BreakingNESWiki/imgstore/ppu/pal/EvenOdd_PAL.png)

Немного другая логика для очистки счетчиков H/V:

![fsm_clear_counters](/BreakingNESWiki/imgstore/ppu/pal/fsm_clear_counters.png)

Бит V0 выходит из VCounter для фазового генератора (см. схему VideoOut):

![fsm_v0](/BreakingNESWiki/imgstore/ppu/pal/fsm_v0.png)

Сигналы BLACK и /PICTURE обрабатываются специальным образом для PAL (с небольшими различиями):

![fsm_npicture](/BreakingNESWiki/imgstore/ppu/pal/fsm_npicture.png)

По поводу BLACK см. далее.

Декодеры H/V также отличаются.

Все остальные части (горизонтальная и вертикальная логика FSM, схема выбора регистров, счетчики H/V) такие же, как и у NTSC PPU.

## Декодер H

![pal_h](/BreakingNESWiki/imgstore/ppu/pal/pal_h.png)

|Выход HPLA|Номера пикселей строки|Битовая маска|VB Tran|BLNK Tran|Смысловое значение/с чем связан|
|---|---|---|---|---|---|
|0|277|01101010011001100100| | |FPorch FF|
|1|256|01101010101010101000| | |FPorch FF|
|2|65|10100110101010100101| |yes|S/EV|
|3|0-7, 256-263|00101010101000000000| | |CLIP_O / CLIP_B|
|4|0-255|10000000000000000010|yes| |CLIP_O / CLIP_B|
|5|339|01100110011010010101| |yes|0/HPOS|
|6|63|10101001010101010101| |yes|/EVAL|
|7|255|00010101010101010101| |yes|E/EV|
|8|0-63|10101000000000000001| |yes|I/OAM2|
|9|256-319|01101000000000000001| |yes|OBJ_READ|
|10|0-255|10000000000000000011|yes|yes|/VIS|
|11|Каждый 0..1|00000000000010100001| |yes|#F/NT|
|12|Каждый 6..7|00000000000001010000| | |F/TB|
|13|Каждый 4..5|00000000000001100000| | |F/TA|
|14|320-335|01000110100000000001| |yes|/FO|
|15|0-255|10000000000000000001| |yes|F/AT|
|16|Каждый 2..3|00000000000010010000| | |F/AT|
|17|256|01101010101010101000| | |BPorch FF|
|18|4|10101010101001101000| | |BPorch FF|
|19|277|01101010011001100100| | |HBlank FF|
|20|302|01101001100101011000| | |HBlank FF|
|21|321|01100110101010100100| | |BURST FF|
|22|306|01101001011010011000| | |BURST FF|
|23|340|01100110011001101000| | |HCounter clear / VCounter step|

## Декодер V

![pal_v](/BreakingNESWiki/imgstore/ppu/pal/pal_v.png)

|Выход VPLA|Номер строки|Битовая маска|Смысловое значение|
|---|---|---|---|
|0|272|011010100110101010|VSYNC FF|
|1|269|011010101001011001|VSYNC FF|
|2|1|101010101010101001|PICTURE FF|
|3|240|000101010110101010|PICTURE FF|
|4|241|000101010110101001|/VSET|
|5|0|101010101010101010|VB FF|
|6|240|000101010110101010|VB FF, BLNK FF|
|7|311|011010010110010101|BLNK FF|
|8|311|011010010110010101|VCLR|
|9|265|011010101001101001|Even/Odd|

## Video Out

CLK:

![vidout_clk](/BreakingNESWiki/imgstore/ppu/pal/vidout_clk.png)

PCLK:

![vidout_pclk](/BreakingNESWiki/imgstore/ppu/pal/vidout_pclk.png)

![pclk_2C07](/BreakingNESWiki/imgstore/ppu/pclk_2C07.jpg)

Декодер цвета в два раза больше (из-за особенностей альтерации фаз PAL). Бит V0 из VCounter поступает на декодер для определения четности текущей линии (для чередования фаз). Фазовый сдвигатель согласован с удвоенным декодером:

![vidout_phase_chroma](/BreakingNESWiki/imgstore/ppu/pal/vidout_phase_chroma.png)

![vidout_chroma_decoder](/BreakingNESWiki/imgstore/ppu/pal/vidout_chroma_decoder.png)

|Выход|Битовая маска|
|---|---|
|0|1001100110|
|1|0110100101|
|2|1010100101|
|3|0101100110|
|4|1001010110|
|5|0110011001|
|6|1010011010|
|7|0101011010|
|8|1001101001|
|9|0110101001|
|10|0010101010|
|11|1010100110|
|12|0101101010|
|13|1001011001|
|14|0110010110|
|15|1010010110|
|16|0101011001|
|17|1001101010|
|18|0110100110|
|19|1010101001|
|20|0101101001|
|21|1001011010|
|22|0110011010|
|23|1010011001|
|24|0101010110|

(Нумерация выходов топологическая слева-направо. Порядок бит сверху-вниз. 1 означает есть транзистор. 0 означает нет транзистора)

Сигнал /PICTURE подвергается дополнительной обработке (задержка DLATCH):

![vidout_npicture](/BreakingNESWiki/imgstore/ppu/pal/vidout_npicture.png)

![nPICTURE_Pal](/BreakingNESWiki/imgstore/ppu/pal/nPICTURE_Pal.png)

При этом в схему Color Buffer Control сигнал /PICTURE приходит в не модифицированном виде (как в NTSC PPU).

Также перепутано соединение в схеме формирования сигналов /PR и /PG, в результате чего подстройка фазы для красного и зелёного канала работает наоборот:

![Mixed_RG_Emphasis](/BreakingNESWiki/imgstore/ppu/pal/Mixed_RG_Emphasis.png)

Схемы ЦАП, подстройки фазы (Emphasis) и декодера цветности не отличаются от NTSC PPU.

## Regs

Сигнал `/SLAVE` проходит через 2 дополнительных инвертора для усиления:

![regs_nslave](/BreakingNESWiki/imgstore/ppu/pal/regs_nslave.png)

Сигнал `B/W` проходит через мультиплексор окольными путями, для этого он усилен двумя инверторами (не меняющими полярность сигнала):

![regs_bw](/BreakingNESWiki/imgstore/ppu/pal/regs_bw.png)

Два сигнала O8/16 и I1/32 выводятся в инверсной логике (для них имеются дополнительные инверторы в Data Reader):

![regs_o816_i132](/BreakingNESWiki/imgstore/ppu/pal/regs_o816_i132.png)

Накручена дополнительная логика обработки сигнала `BLACK`:

![regs_black](/BreakingNESWiki/imgstore/ppu/pal/regs_black.png)

Сигнал /BLACK выходит с блока регистров. FET, выполняющий роль DLatch находится в блоке FSM. Из него получается оригинальный сигнал BLACK.

![BLACK_Pal](/BreakingNESWiki/imgstore/ppu/pal/BLACK_Pal.png)

Выход управляющего сигнала VBL немного отличается (используется дополнительный отсекающий транзистор, которого нет в NTSC PPU):

![regs_vbl](/BreakingNESWiki/imgstore/ppu/pal/regs_vbl.png)

## Sprite Logic

В целом отличия минимальные, но есть нюансы. Все различия отмечены восклицательным знаком.

В логике компаратора изменений не обнаружено.

В схеме управления сравнением (самая нижняя) только одно мелкое изменение, связанное с тем, что сигнал O8/16 в PAL PPU уже в инверсной логике, поэтому инвертор для него не требуется:

![eval_o816](/BreakingNESWiki/imgstore/ppu/pal/eval_o816.png)

Схемы разрядов счетчиком (OAM Counter и OAM2 Counter) изменены таким образом, что на выходе отсутствует инвертор. Поэтому выходы (индекс для доступа к памяти OAM) в прямой логике (`OAM0-7`), а не в инверсной как в NTSC PPU (`/OAM0-7`):

![eval_counters](/BreakingNESWiki/imgstore/ppu/pal/eval_counters.png)

Отличается схема обработки сигнала BLNK (находится чуть выше OAM2 Counter):

|![eval_blnk](/BreakingNESWiki/imgstore/ppu/pal/eval_blnk.png)|![eval_blnk_analysis](/BreakingNESWiki/imgstore/ppu/pal/eval_blnk_analysis.png)
|---|---|

Скорее всего этот DLatch используется для борьбы с невыровненным взаимодействием CPU/PPU и регистром $2004.
Простыми словами: Отключение рендеринга PPU в 2C07 имеет эффект адресации OAM только к началу следующего пикселя, если он был сделан ко "второй половине" текущего пикселя.

Схема управления OAM Counter для получения контрольного сигнала `OMSTEP` дополнительно модифицирована сигналом `EvenOddOut`, который приходит со схемы EVEN/ODD (эта схема находится правее V PLA):

![eval_even_odd](/BreakingNESWiki/imgstore/ppu/pal/eval_even_odd.png)

Ну и основное отличие: вместо обычного W3 Enabler, который используется в NTSC PPU используется целая большая схема, которая находится в самом верху, левее RW Decoder. Она формирует сигнал `W3'` аналогичный NTSC PPU, но в PAL PPU он проходит через линию задержки из DLatch.

![eval_w3_enable](/BreakingNESWiki/imgstore/ppu/pal/eval_w3_enable.png)

## OAM

Поскольку адрес OAM0-7 выдаётся в прямой логике, для битов 2-4 OAM Buffer переставлены выходы COLx, 2 и 6.

![pal_oam_col_decoder_tran](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_col_decoder_tran.png)

![pal_oam_col_outputs1](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_col_outputs1.png)

(NTSC PPU слева, PAL PPU справа)

![pal_oam_col_outputs2](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_col_outputs2.png)

(NTSC PPU слева, PAL PPU справа)

## Data Reader

Для инверсных сигналов `#O8/16` и `#I1/32` добавлены 2 инвертора, в местах где эти сигналы заходят в схему.

|PAL|NTSC|
|---|---|
|![o816_inv](/BreakingNESWiki/imgstore/ppu/pal/o816_inv.jpg)|![o816_orig](/BreakingNESWiki/imgstore/ppu/pal/o816_orig.jpg)|
|![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/pal/i132_inv.jpg)|![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/pal/i132_orig.jpg)|

Таким образом инверсное распространение этих сигналов из блока регистров не вносит какого-то существенного импакта, по сравнению с NTSC PPU.

## Interconnects

Смотри [Межсоединения](rails.md)

## Импакт для эмуляции/симуляции

Этот раздел специально для авторов эмуляторов NES.

Сложно сказать как перенести эти изменения в исходники вашего эмулятора, но вот несколько соображений:

- Вам необходимо подстроить логику рендеринга PPU в плане таймингов H/V, в соответствии с H/V декодером PPU. Значения его выходов есть в таблице, нужно только соотнести их с теми, что у вас есть для NTSC PPU
- В PAL PPU отсутствует логика NTSC Crawl и схема Even/Odd занимается совсем другими делами. Её сигнал EvenOddOut уходит в логику управления OAM Counter ($2003) и влияет на его пересчёт (сигнал OMSTEP). Тут вам придётся разобраться самостоятельно, чем логика OMSTEP в NTSC PPU отличается от PAL PPU, с учётом сигнала EvenOddOut.
- Также нужно учесть задержу записи в регистр $2003, которая реализуется схемой W3 Enabler.

Всё остальное скорее всего нерелевантно для программной эмуляции.

Что касается видеовыхода, то на базе схемы Phase Shifter и значений Chroma декодера теперь есть возможность сделать фильтр/шейдер наподобии NTSC Filter by blargg. Опытный NES-хакер тут легко справится.