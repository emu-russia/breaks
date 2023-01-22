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

## Envelope Unit

![env_unit](/BreakingNESWiki/imgstore/apu/waves/env_unit.png)

:warning: Симуляция генерации LFO искусственно подстроена для более частого срабатывания.

## Barrel Shifter прямоугольного канала

![square_barrel](/BreakingNESWiki/imgstore/apu/waves/square_barrel.png)

## Сумматор прямоугольного канала

Full Adder (один бит сумматора):

![adder_single](/BreakingNESWiki/imgstore/apu/waves/adder_single.png)

Результат суммирования где-то по середине:

![adder_full](/BreakingNESWiki/imgstore/apu/waves/adder_full.png)

Суммирование максимальных значений:

![adder_full_max](/BreakingNESWiki/imgstore/apu/waves/adder_full_max.png)

## Sweep Unit прямоугольного канала

![sweep_tb](/BreakingNESWiki/imgstore/apu/waves/sweep_tb.png)

С помощью этого теста мы пытаемся заставить блок Sweep генерировать сигнал ADDOUT так, как это должно быть для работы процесса Sweep.

То есть, нам нужно установить искусственную генерацию сигнала /LFO2 (не слишком медленную, как в реальных условиях, чтобы ускорить процесс)
и проверить, что сигнал ADDOUT генерируется так, как должен.

Для этого теста не имеет значения, что происходит с Freq Reg, шифтером, сумматором и всеми остальными частями генератора прямоугольных сигналов.

![sweep_unit](/BreakingNESWiki/imgstore/apu/waves/sweep_unit.png)

:warning: Симуляция генерации LFO искусственно подстроена для более частого срабатывания.

## Duty Unit прямоугольного канала

![duty_tb](/BreakingNESWiki/imgstore/apu/waves/duty_tb.png)

Проверить генерацию сигнала DUTY в зависимости от различных настроек регистра Duty и значений счётчика Duty.

Генерация сигнала FLOAD (для итерации счётчика Duty) искусственно ускорена.

![duty_unit](/BreakingNESWiki/imgstore/apu/waves/duty_unit.png)

## Декодер DPCM

![dpcm_decoder](/BreakingNESWiki/imgstore/apu/waves/dpcm_decoder.png)

## Декодер шумового канала

![noise_decoder](/BreakingNESWiki/imgstore/apu/waves/noise_decoder.png)

## Тест DPCM

![dpcm_output](/BreakingNESWiki/imgstore/apu/waves/dpcm_output.png)

## Тест прямоугольного канала

![square_output](/BreakingNESWiki/imgstore/apu/waves/square_output.png)

```
W4015 <= 0000000 1  (SQA Length counter enable: 1)
W4000 <= 10 0 0 0110 (D=2, Length Counter #carry in=0, ConstVol=0, Vol=6)
W4001 <= 1 001 0 010 (Sweep=1, Period=1, Negative=0, Magnitude=2^2)
W4002 <= 0110 1001  (Freq Lo=0x69)
W4003 <= 11111 010  (Length=11111, Freq Hi=2)
```

## Тест треугольного канала

TBD.

## Тест шумового канала

TBD.

## Спрайтовая DMA

Тестовая среда:

![oam_dma_tb](/BreakingNESWiki/imgstore/apu/waves/oam_dma_tb.png)

Начало OAM DMA (выровненное на #ACLK):

![oam_dma_start1](/BreakingNESWiki/imgstore/apu/waves/oam_dma_start1.png)

Начало OAM DMA (невыровненное на #ACLK, требуется 1 дополнительный цикл CPU):

![oam_dma_start2](/BreakingNESWiki/imgstore/apu/waves/oam_dma_start2.png)

Завершение OAM DMA:

![oam_dma_last](/BreakingNESWiki/imgstore/apu/waves/oam_dma_last.png)

## Совместная работа спрайтовой DMA и DPCM

![both_dma_tb](/BreakingNESWiki/imgstore/apu/waves/both_dma_tb.png)

Начало DPCM DMA (запись в регистры $400x и несколько итераций процесса):

![both_dma_start_dpcm](/BreakingNESWiki/imgstore/apu/waves/both_dma_start_dpcm.png)

Начало OAM DMA (запись в регистр $4014)

![both_dma_start_oam](/BreakingNESWiki/imgstore/apu/waves/both_dma_start_oam.png)

Момент пересечения DPCM DMA и OAM DMA:

![both_dma](/BreakingNESWiki/imgstore/apu/waves/both_dma.png)

Момент пересечения DPCM DMA и OAM DMA (приближенная версия конкретного момента):

![both_dma_zoom](/BreakingNESWiki/imgstore/apu/waves/both_dma_zoom.png)

Завершение OAM DMA:

![both_dma_last_oam](/BreakingNESWiki/imgstore/apu/waves/both_dma_last_oam.png)

Некоторое затишье после окончания OAM DMA и началом следующего DPCM DMA:

![both_dma_after_oam_before_next_dpcm](/BreakingNESWiki/imgstore/apu/waves/both_dma_after_oam_before_next_dpcm.png)

Обычный DPCM DMA в сравнении с пересекаемым OAM DMA:

![both_side_by_side](/BreakingNESWiki/imgstore/apu/waves/both_side_by_side.png)

Видно что часть циклов DPCM DMA резервируется для возможной передачи OAM DMA, так как невозможно сделать 2 чтения одновременно. Поэтому в начале DPCM передачи находится "окно", после которого сигналом RUNDMC подавляется возможная активная OAM DMA.
