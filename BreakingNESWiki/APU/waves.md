# Временные диаграммы

В данном разделе собраны временные развёртки сигналов для разных модулей APU. Инженеры-схемотехники любят такое вдумчиво поизучать.

В русскоязычной литературе данные сущности называются "временные диаграммы", "эпюры" или "разблядовка сигналов". Из всех вариантов наиболее благозвучно звучит вариант "временные диаграммы".

Вначале была идея добавить такие диаграммы внутри каждого раздела, но после некоторых раздумий было решено сделать этот раздел в виде "приложения".

Временная шкала соблюдена более-менее точно только для сигналов SoftCLK LFO, в остальных случаях timescale выбран произвольным (не имеет смысла делать точным).

Исходники всех тестов, с помощью которых были сделаны диаграммы находятся в папке `/HDL/Framework/Icarus`.

## Делитель CLK

![div](/BreakingNESWiki/imgstore/apu/waves/div.png)

Показаны значения внешнего пада `CLK`, сигнал `PHI0` для ядра и сигнал c внешнего пада `M2`.

## Генератор ACLK

В условиях сброса:

![aclk_with_reset](/BreakingNESWiki/imgstore/apu/waves/aclk_with_reset.png)

Без сброса:

![aclk](/BreakingNESWiki/imgstore/apu/waves/aclk.png)

## Счётчик SoftCLK (LFSR)

![softclk_lfsr](/BreakingNESWiki/imgstore/apu/waves/softclk_lfsr.png)

## Декодер SoftCLK, низкочастотные сигналы (LFO) и прерывание

Mode = 0:

![softclk_mode0](/BreakingNESWiki/imgstore/apu/waves/softclk_mode0.png)

Mode = 1:

![softclk_mode1](/BreakingNESWiki/imgstore/apu/waves/softclk_mode1.png)

## Декодер регистровых операций

Чтение регистров:

![regops_read](/BreakingNESWiki/imgstore/apu/waves/regops_read.png)

Запись регистров:

![regops_write](/BreakingNESWiki/imgstore/apu/waves/regops_write.png)

## Декодер счётчиков длительности

![length_decoder](/BreakingNESWiki/imgstore/apu/waves/length_decoder.png)

## Счётчик длительности

![length_counter](/BreakingNESWiki/imgstore/apu/waves/length_counter.png)

Диаграмма показывает суть работы, с некоторыми особенностями:
- Фазовый паттерн для ACLK соблюдён
- Частота LFO2, опеределяющая пересчёт счетчика не в масштабе, а синтетически укорочена
- Основная суть - показать что после заверешения обратного отсчёта схема выдаёт сигнал `NotCount` (который соответствует NOSQA/NOSQB/NOTRI/NORND сигналам для четырёх реальных счётчиков)
- Перед началом работы в счётчик загружается значение 0b1001 (9), которое после обработки на декодере соответствует значанию 0x07.

## Barrel Shifter прямоугольного канала

TBD.

## Сумматор прямоугольного канала

TBD.

## Duty Cycle прямоугольного канала

TBD.

## Декодер DPCM

![dpcm_decoder](/BreakingNESWiki/imgstore/apu/waves/dpcm_decoder.png)

## Декодер шумового канала

TBD.

## Спрайтовая DMA

TBD.

## DPCM DMA

TBD.

## Совместная работа спрайтовой DMA и DPCM

TBD.

## Тест прямоугольного канала

TBD.

## Тест треугольного канала

TBD.

## Тест шумового канала

TBD.
