# Дельта-модуляция (DPCM)

![apu_locator_dpcm](/BreakingNESWiki/imgstore/apu/apu_locator_dpcm.jpg)

Данное устройство используется для генерации PCM звука:
- Выходной регистр $4011 представляет собой реверсивный счетчик, который считает вверх, если следующий разряд битстрима равен 1 или вниз, если следующий разряд битстрима равен 0
- Все остальное представляет собой набор счетчиков и управляющей логики, для организации процесса DMA
- DPCM DMA не использует средства [спрайтового DMA](dma.md), а организует собственный буфер для хранения выбранного PCM сэмпла. Для перехвата управления над спрайтовой DMA используется контрольный сигнал `RUNDMC`.

![DMC](/BreakingNESWiki/imgstore/apu/DMC.jpg)

Входные сигналы:

|Сигнал|Откуда|Описание|
|---|---|---|
|ACLK|LFO|APU Clock (верхний уровень)|
|/ACLK|LFO|APU Clock (нижний уровень)|
|PHI1|CPU|Первая половина цикла CPU|
|RES|RES Pad|Внешний сигнал сброса|
|R/W|CPU|Режим работы шины данных CPU (1: Read, 0: Write)|
|LOCK|Core|TBD|
|W401x|Reg Select|1: Операция записи в регистр $401x|
|/R4015|Reg Select|0: Операция чтения регистра $4015|

Выходные сигналы:

|Сигнал|Куда|Описание|
|---|---|---|
|#DMC/AB|Address MUX|0: Захватить управление адресной шиной для чтения DPCM сэмпла|
|RUNDMC|SPR DMA|1: DMC занята своими делами и перехватывает управление DMA|
|DMCRDY|SPR DMA|1: DMC готова. Используется для управления готовностью процессора (RDY)|
|/DMCINT|LFO|0: Прерывание DMC активно|
|DMC Out|DAC|Выходное значение для ЦАП|
|DMC Address|Address MUX|Адрес для чтения DPCM сэмпла|

Сигналы управления внутренним состоянием DMC:

|Сигнал|Откуда|Куда|Описание|
|---|---|---|---|
|SLOAD|DPCM Control|Sample Counter, DPCM Address|Загрузить значение в Sample Counter|
|SSTEP|DPCM Control|Sample Counter, DPCM Address|Выполнить инкремент Sample Counter|
|BLOAD|DPCM Control|Sample Buffer|Загрузить значение в Sample Buffer|
|BSTEP|DPCM Control|Sample Buffer|Выполнить сдвиг разряда Sample Buffer|
|NSTEP|DPCM Control|Sample Bit Counter|Выполнить инкремент Sample Bit Counter|
|DSTEP|DPCM Control|DPCM Output|Выполнить инкремент/декремент счетчика DPCM Output|
|PCM|DPCM Control|Sample Buffer|Загрузить новое значение сэмпла в Sample Buffer. Сигнал активен когда PHI1 = 0 и адресная шина захвачена (имитация чтения CPU)|
|/LOOP|$4010\[7\]|DPCM Control|0: Зацикленное воспроизведение DPCM|
|IRQEN|$4010\[6\]|DPCM Control|1: Разрешить прерывание от DPCM|
|DOUT|DPCM Output|DPCM Control|Счетчик DPCM Out закончил пересчет|
|NOUT|Sample Bit Counter|DPCM Control|Sample Bit Counter закончил пересчет|
|SOUT|Sample Counter|DPCM Control|Sample Counter закончил пересчет|
|FLOAD|LFSR|DPCM Control|Frequency LFSR закончил пересчет и перезагрузил сам себя|
|BOUT|Sample Buffer|DPCM Output|Очередное значение бита, вытолкнутое из регистра сдвига Sample Buffer|

Большая часть сигналов управления имеют однотипную природу:
- xLOAD: Загрузить новое значение
- xSTEP: Выполнить какое-то действие
- xOUT: Счетчик закончил пересчет

Исключение составляет команда FLOAD: Frequency LFSR перезагружает сам себя после пересчета, но при этом одновременно сигнализирует в основной блок управления.

## Другой /ACLK

В самом центре схемы DPCM находится схема, для получения "другого" /ACLK, который используется в DPCM, а также в [спрайтовой DMA](dma.md). Данный сигнал /ACLK отличается от обычного небольшой задержкой.
Этот сигнал ещё можно встретить в наших схемах под названием `/ACLK2`.

![Other_nACLK](/BreakingNESWiki/imgstore/apu/Other_nACLK.jpg)

На схемах ниже стрелкой отмечены места, где используется `/ACLK2`.

## DPCM Control Summary

![DPCM_Control](/BreakingNESWiki/imgstore/apu/DPCM_Control.jpg)

## DPCM Control Register ($4010)

![dpcm_control_reg_tran](/BreakingNESWiki/imgstore/apu/dpcm_control_reg_tran.jpg)

## DPCM Interrupt Control

![dpcm_int_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_int_control_tran.jpg)

![DPCM_IntControl](/BreakingNESWiki/imgstore/apu/DPCM_IntControl.jpg)

## DPCM Enable Control

![dpcm_enable_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_enable_control_tran.jpg)

![DPCM_EnableControl](/BreakingNESWiki/imgstore/apu/DPCM_EnableControl.jpg)

## DPCM DMA Control

![dpcm_dma_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_dma_control_tran.jpg)

![DPCM_DMAControl](/BreakingNESWiki/imgstore/apu/DPCM_DMAControl.jpg)

## DPCM Sample Counter Control

![dpcm_sample_counter_control_tran1](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_control_tran1.jpg)

![dpcm_sample_counter_control_tran2](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_control_tran2.jpg)

(Вторая часть схемы также управляет счетчиком разрядов сэмпла)

![DPCM_SampleCounterControl](/BreakingNESWiki/imgstore/apu/DPCM_SampleCounterControl.jpg)

## DPCM Sample Buffer Control

![dpcm_sample_buffer_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_buffer_control_tran.jpg)

![DPCM_SampleBufferControl](/BreakingNESWiki/imgstore/apu/DPCM_SampleBufferControl.jpg)

## DPCM Sample Counter In ($4013)

![dpcm_sample_counter_in_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_in_tran.jpg)

## DPCM Sample Counter

![dpcm_sample_counter_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_tran.jpg)

## DPCM Sample Buffer

![dpcm_sample_buffer_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_buffer_tran.jpg)

## DPCM Sample Bit Counter

![dpcm_sample_bit_counter_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_bit_counter_tran.jpg)

## DPCM Decoder

![dpcm_decoder_tran](/BreakingNESWiki/imgstore/apu/dpcm_decoder_tran.jpg)

## DPCM Frequency Counter LFSR

![dpcm_freq_counter_lfsr_tran](/BreakingNESWiki/imgstore/apu/dpcm_freq_counter_lfsr_tran.jpg)

## DPCM Address Register ($4012)

![dpcm_addr_in_tran](/BreakingNESWiki/imgstore/apu/dpcm_addr_in_tran.jpg)

## DPCM Address

Младшая часть:

![dpcm_address_low_tran](/BreakingNESWiki/imgstore/apu/dpcm_address_low_tran.jpg)

Старшая часть:

![dpcm_address_high_tran](/BreakingNESWiki/imgstore/apu/dpcm_address_high_tran.jpg)

Вход DMC_A15 в адресном мультиплексоре подключен к Vdd:

![DMC_A15](/BreakingNESWiki/imgstore/apu/DMC_A15.jpg)

## DPCM Output ($4011)

![dpcm_output_tran](/BreakingNESWiki/imgstore/apu/dpcm_output_tran.jpg)
