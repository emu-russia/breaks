# Интеграция ядра 6502

![apu_locator_core](/BreakingNESWiki/imgstore/apu/apu_locator_core.jpg)

В данном разделе описаны особенности ядра и окружающей его вспомогательной логики, предназначенной для интеграции с остальными компонентами.

В состав ядра 6502 и окружающей его логики входят следующие сущности:
- Главный тактовый сигнал и делитель частоты
- Привязка контактов ядра 6502 к остальной части APU
- Ядро 6502

## Сигналы

|Сигнал|Откуда|Куда|Описание|
|---|---|---|---|
|CLK| | | |
|/M2| | | |
|DBG| | | |
|NotDBG_RES| | | |
|RES| | | |
|R/W| | | |
|/NMI| | | |
|INT| | | |
|/IRQ| | | |
|/IRQ_INT| | | |
|PHI0| | | |
|PHI1| | | |
|PHI2| | | |
|RW| | | |
|WR| | | |
|RD| | | |
|RDY| | | |
|SPR/PPU| | | |
|/DBGRD| | | |
|CPU_A\[15:0\]| | | |
|A\[15:0\]| | | |
|D\[7:0\]| | | |
|/ACLK| | | |

## Делитель частоты

Делитель представляет собой счётчик Джонсона.

![div](/BreakingNESWiki/imgstore/apu/div.jpg)

(Для удобства схема положена "на бок").

Схема общего плана:

![div_logisim](/BreakingNESWiki/imgstore/apu/div_logisim.jpg)

Схема для 2A03:

![DIV_2A03](/BreakingNESWiki/imgstore/apu/DIV_2A03.jpg)

Разряд регистра сдвига делителя:

![DIV_SRBit](/BreakingNESWiki/imgstore/apu/DIV_SRBit.jpg)

## Соединение 6502 и APU

В данном разделе рассматриваются соединения контактов ядра 6502 с APU.

### /NMI и /IRQ

Вспомогательная логика для обработки NMI и IRQ:

|Схема|Описание|
|---|---|
|![apu_core_irqnmi_logic1](/BreakingNESWiki/imgstore/apu/apu_core_irqnmi_logic1.jpg)|Просто промежуточные инвертеры|
|![apu_core_irqnmi_logic2](/BreakingNESWiki/imgstore/apu/apu_core_irqnmi_logic2.jpg)|/IRQ_INT: Комбинация внешнего или внутреннего прерывания.|

Терминал /NMI:

![apu_core_nmi](/BreakingNESWiki/imgstore/apu/apu_core_nmi.jpg)

Терминал /IRQ:

![apu_core_irq](/BreakingNESWiki/imgstore/apu/apu_core_irq.jpg)

### RDY

![apu_core_rdy](/BreakingNESWiki/imgstore/apu/apu_core_rdy.jpg)

Рядом со входом RDY есть ещё один транзистор, который в NTSC APU всегда открыт. TBD: Добавить про PAL APU.

### /RES

![apu_core_res](/BreakingNESWiki/imgstore/apu/apu_core_res.jpg)

На входе терминала /RES находится инвертер, чтобы инвертировать внутренний сигнал `RES`.

### PHI0, PHI1, PHI2

Генерация внутренних сигналов PHI:

![apu_core_phi_internal](/BreakingNESWiki/imgstore/apu/apu_core_phi_internal.jpg)

Генерация внешних сигналов PHI:

|PHI1|PHI2|
|---|---|
|![apu_core_phi1_ext](/BreakingNESWiki/imgstore/apu/apu_core_phi1_ext.jpg)|![apu_core_phi2_ext](/BreakingNESWiki/imgstore/apu/apu_core_phi2_ext.jpg)|

Ничего необычного.

### SO

![apu_core_so](/BreakingNESWiki/imgstore/apu/apu_core_so.jpg)

Терминал SO всегда подсоединен к `1`. Технически это нормально, т.к. на входе SO находится falling edge detector.

### R/W

![apu_core_rw](/BreakingNESWiki/imgstore/apu/apu_core_rw.jpg)

Ничего необычного.

Сигнал `RW` приходит не напрямую с терминала `R/W` ядра 6502, а получается в схеме буфера для спрайтовой DMA (см. ниже).

### SYNC

Контакт SYNC ни с чем не соединен (floating):

![apu_core_sync](/BreakingNESWiki/imgstore/apu/apu_core_sync.jpg)

### D0-D7

Контакты ядра 6502 соединяются напрямую с внутренней шиной данных D0-D7.

Схема сигнала `RD`:

![rd_tran](/BreakingNESWiki/imgstore/apu/rd_tran.jpg)

Буфер для спрайтовой DMA:

![sprbuf_tran](/BreakingNESWiki/imgstore/apu/sprbuf_tran.jpg)

Не очень к месту, но сказать придется именно в этом месте, т.к. кроме хранения данных для спрайтовой DMA данная схема также занимается получением сигнала `WR` для контактов внешней шины данных, а также сигнала `RW`.

:warning: Так получилось, что сигнал ядра 6502 `R/W` по названию очень похож на сигнал `RW`, который уходит на внешний контакт R/W. Не перепутайте :smiley:

![RWDecode](/BreakingNESWiki/imgstore/apu/RWDecode.jpg)

### A0-A15

Выходы шины адреса ядра 6502 ассоциированы с внутренними сигналами CPU_A0-15.

Для CPU_A14 дополнительно имеется инвертер, который используется в схеме предекодирования адреса регистров APU.

## Встроенное ядро 6502

Внешне ядро 6502 выглядит как копи-паста исходного процессора MOS в уменьшенном варианте.

После детального изучения схемы 2A03 были получены следующие результаты:
- Отличий в декодере не обнаружено
- Флаг D работает как обычно, его можно установить или сбросить, он используется нормальным образом при обработке прерываний (сохраняется в стеке) и после выполнения инструкций PHP/PLP, RTI.
- Рандомная логика отвечающая за генерацию двух контрольных сигналов `/DAA` (decimal addition adjust) и `/DSA` (decimal subtraction adjust) работает обычным образом.

Отличие заключается в том, что контрольные сигналы `/DAA` и `/DSA`, отвечающие за включение схем коррекции, отсоединены от схемы, путём вырезания 5 кусочков полисиликона (см. картинку). Полисиликон обозначен фиолетовым цветом, вырезанные кусочки обозначены голубым, а места обведены красным.

|Оригинальное изображение схемы 6502|Места с отсутствующим поли в APU|
|---|---|
|![bcd_tran_orig](/BreakingNESWiki/imgstore/apu/bcd_tran_orig.png)|![bcd_tran_apu_missing](/BreakingNESWiki/imgstore/apu/bcd_tran_apu_missing.png)|

Это приводит к тому, что схема вычисления десятичного переноса при сложении и схема добавления/отнимания 6 к результату - не работают. Поэтому встроенный процессор APU всегда считает двоичными числами, даже если флаг D установлен.

Процесс исследования: http://youtu.be/Gmi1DgysGR0

Ключевые узлы по которым был проведен анализ (декодер, рандомная логика, флаги и АЛУ) представлена на следующем изображении:

![2a03_6502_diff_sm](/BreakingNESWiki/imgstore/apu/2a03_6502_diff_sm.jpg)

Чтобы понять больше суть различий в работе BCD-схемы, рекомендуется изучить устройство АЛУ 6502.
