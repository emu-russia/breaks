# Ядро 6502 и сопутствующая логика

![apu_locator_core](/BreakingNESWiki/imgstore/apu/apu_locator_core.jpg)

В данном разделе описаны особенности ядра и окружающей его вспомогательной логики, предназначенной для интеграции с остальными компонентами.

## Делитель частоты

![CLK_DIVIDER_trans](/BreakingNESWiki/imgstore/apu/CLK_DIVIDER_trans.png)

## Встроенное ядро 6502

### Соединение 6502 и APU

### Различия между ядром 6502 APU и оригиналом

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

## Выбор регистра

![RW_DECODE](/BreakingNESWiki/imgstore/apu/RW_DECODE.png)

![REG_SELECT](/BreakingNESWiki/imgstore/apu/REG_SELECT.png)

## Отладочные регистры

Транзисторные схемы отладочных регистров:

|Square 1|Square 2|Triangle|Noise|DPCM|
|---|---|---|---|---|
|![square1_debug_tran](/BreakingNESWiki/imgstore/apu/square1_debug_tran.jpg)|![square2_debug_tran](/BreakingNESWiki/imgstore/apu/square2_debug_tran.jpg)|![tri_debug_tran](/BreakingNESWiki/imgstore/apu/tri_debug_tran.jpg)|![noise_debug_tran](/BreakingNESWiki/imgstore/apu/noise_debug_tran.jpg)|![dpcm_debug_tran](/BreakingNESWiki/imgstore/apu/dpcm_debug_tran.jpg)|

## Порты ввода/вывода

![io_tran](/BreakingNESWiki/imgstore/apu/io_tran.jpg)
