# Ядро 6502 и сопутствующая логика

![apu_locator_core](/BreakingNESWiki/imgstore/apu/apu_locator_core.jpg)

В данном разделе описаны особенности ядра и окружающей его вспомогательной логики, предназначенной для интеграции с остальными компонентами.

В состав ядра 6502 и окружающей его логики входят следующие сущности:
- Главный тактовый сигнал и делитель частоты
- Привязка контактов ядра 6502 к остальной части APU
- Ядро 6502
- Декодер регистровых операций
- Отладочные регистры
- Внешние порты ввода/вывода

## Главный тактовый сигнал

Делитель частоты:

![CLK_DIVIDER_trans](/BreakingNESWiki/imgstore/apu/CLK_DIVIDER_trans.png)

## Соединение 6502 и APU

В данном разделе рассматриваются соединения контактов ядра 6502 с APU.

### /NMI

TBD.

### /IRQ

TBD.

### RDY

TBD.

### /RES

TBD.

### PHI0, PHI1, PHI2

TBD.

### SO

TBD.

### R/W

TBD.

### SYNC

TBD.

### D0-D7

TBD.

### A0-A15

![cpu_a14_tran](/BreakingNESWiki/imgstore/apu/cpu_a14_tran.jpg)

## Встроенное ядро 6502

Внешне ядро 6502 выглядит как копи-паста исходного процессора MOS в уменьшенном варианте.

После детального изучения схемы 2A03 были получены следующие результаты:
- Отличий в декодере не обнаружено
- Флаг D работает как обычно, его можно установить или сбросить, он используется нормальным образом при обработке прерываний (сохраняется в стеке) и после выполнения инструкций PHP/PLP, RTI.
- Рандомная логика отвечающая за генерацию двух контрольных сигналов `/DAA` (decimal addition adjust) и `/DSA` (decimal subtraction adjust) работает обычным образом.

Отличие заключается в том, что контрольные сигналы /DAA и /DSA, отвечающие за включение схем коррекции, отсоединены от схемы, путём вырезания 5 кусочков полисиликона (см. картинку). Полисиликон обозначен фиолетовым цветом, вырезанные кусочки обозначены голубым, а места обведены красным.

Это приводит к тому, что схема вычисления десятичного переноса при сложении и схема добавления/отнимания 6 к результату - не работают. Поэтому встроенный процессор APU всегда считает двоичными числами, даже если флаг D установлен.

Процесс исследования: http://youtu.be/Gmi1DgysGR0

Ключевые узлы по которым был проведен анализ (декодер, рандомная логика, флаги и АЛУ) представлена на следующем изображении:

<img src="/BreakingNESWiki/imgstore/apu/2a03_6502_diff_sm.jpg" width="400px">

## Регистровые операции

![pdsel_tran](/BreakingNESWiki/imgstore/apu/pdsel_tran.jpg)

![rw_decode](/BreakingNESWiki/imgstore/apu/rw_decode.jpg)

![reg_select](/BreakingNESWiki/imgstore/apu/reg_select.jpg)

## Отладочные регистры

Транзисторные схемы отладочных регистров:

|Square 1|Square 2|Triangle|Noise|DPCM|
|---|---|---|---|---|
|![square1_debug_tran](/BreakingNESWiki/imgstore/apu/square1_debug_tran.jpg)|![square2_debug_tran](/BreakingNESWiki/imgstore/apu/square2_debug_tran.jpg)|![tri_debug_tran](/BreakingNESWiki/imgstore/apu/tri_debug_tran.jpg)|![noise_debug_tran](/BreakingNESWiki/imgstore/apu/noise_debug_tran.jpg)|![dpcm_debug_tran](/BreakingNESWiki/imgstore/apu/dpcm_debug_tran.jpg)|

## Порты ввода/вывода

![out_tran](/BreakingNESWiki/imgstore/apu/out_tran.jpg)
