# Дельта-модуляция (DPCM)

![apu_locator_dpcm](/BreakingNESWiki/imgstore/apu/apu_locator_dpcm.jpg)

Данное устройство используется для генерации PCM звука:
- Выходной регистр $4011 представляет собой реверсивный счётчик, который считает вниз, если следующий разряд битстрима равен 0 или вверх, если следующий разряд битстрима равен 1
- Есть также возможность загрузить значение непосредственно в регистр $4011 для Direct Playback
- Все остальное представляет собой набор счётчиков и управляющей логики, для организации процесса DMA
- DPCM DMA не использует средства [спрайтового DMA](dma.md), а организует собственный буфер для хранения выбранного PCM сэмпла. Для перехвата управления над спрайтовой DMA используется контрольный сигнал `RUNDMC`.

Отличие DMC DMA от спрайтовой DMA заключается в том, что DMC DMA прерывает процессор (RDY = 0) только на время выбора очередного сэмпла.

![DMC](/BreakingNESWiki/imgstore/apu/DMC.jpg)

Входные сигналы:

|Сигнал|Откуда|Описание|
|---|---|---|
|ACLK|Soft CLK|APU Clock (верхний уровень)|
|/ACLK|Soft CLK|APU Clock (нижний уровень)|
|PHI1|CPU|Первая половина цикла CPU. Используется только для определения Read Cycle ядра 6502 и для загрузки сэмплов. Все внутренние счётчики и большая часть управляющих схем тактируются ACLK.|
|RES|RES Pad|Внешний сигнал сброса|
|R/W|CPU|Режим работы шины данных CPU (1: Read, 0: Write)|
|LOCK|Core|Сигнал LOCK используется для временной приостановки звуковых генераторов, чтобы их значения были зафиксированы в отладочных регистрах|
|W401x|Reg Select|1: Операция записи в регистр $401x|
|/R4015|Reg Select|0: Операция чтения регистра $4015|

Выходные сигналы:

|Сигнал|Куда|Описание|
|---|---|---|
|#DMC/AB|Address MUX|0: Захватить управление адресной шиной для чтения DPCM сэмпла|
|RUNDMC|SPR DMA|1: DMC занята своими делами и перехватывает управление DMA|
|DMCRDY|SPR DMA|1: DMC готова. Используется для управления готовностью процессора (RDY)|
|DMCINT|Soft CLK|1: Прерывание DMC активно|
|DMC Out|DAC|Выходное значение для ЦАП|
|DMC Address|Address MUX|Адрес для чтения DPCM сэмпла|

Сигналы управления внутренним состоянием DMC:

|Сигнал|Откуда|Куда|Описание|
|---|---|---|---|
|DSLOAD|DPCM Control|Sample Counter, DPCM Address Counter|Загрузить значение в Sample Counter и одновременно в DPCM Address Counter|
|DSSTEP|DPCM Control|Sample Counter, DPCM Address Counter|Выполнить декремент Sample Counter и одновременно инкремент DPCM Address Counter|
|BLOAD|DPCM Control|Sample Buffer|Загрузить значение в Sample Buffer|
|BSTEP|DPCM Control|Sample Buffer|Выполнить сдвиг разряда Sample Buffer|
|NSTEP|DPCM Control|Sample Bit Counter|Выполнить инкремент Sample Bit Counter|
|DSTEP|DPCM Control|DPCM Output|Выполнить инкремент/декремент счётчика DPCM Output|
|PCM|DPCM Control|Sample Buffer|Загрузить новое значение сэмпла в Sample Buffer. Сигнал активен когда PHI1 = 0 и адресная шина захвачена (имитация чтения CPU)|
|LOOP|$4010\[7\]|DPCM Control|1: Зацикленное воспроизведение DPCM|
|/IRQEN|$4010\[6\]|DPCM Control|0: Разрешить прерывание от DPCM|
|DOUT|DPCM Output|DPCM Control|Счётчик DPCM Out закончил пересчёт|
|/NOUT|Sample Bit Counter|DPCM Control|0: Sample Bit Counter закончил пересчёт|
|SOUT|Sample Counter|DPCM Control|Sample Counter закончил пересчёт|
|DFLOAD|LFSR|DPCM Control|Frequency LFSR закончил пересчёт и перезагрузил сам себя|
|/BOUT|Sample Buffer|DPCM Output|Очередное значение бита, вытолкнутое из регистра сдвига Sample Buffer (инвертированное значение)|

Большая часть сигналов управления имеют однотипную природу:
- xLOAD: Загрузить новое значение
- xSTEP: Выполнить какое-то действие
- xOUT: Счётчик закончил пересчёт

Исключение составляет команда DFLOAD: Frequency LFSR перезагружает сам себя после пересчёта, но при этом одновременно сигнализирует в основной блок управления.

## DPCM Control Summary

![DPCM_Control](/BreakingNESWiki/imgstore/apu/DPCM_Control.jpg)

## DPCM Control Register ($4010)

|![dpcm_control_reg_tran](/BreakingNESWiki/imgstore/apu/dpcm_control_reg_tran.jpg)|![DPCM_ControlReg](/BreakingNESWiki/imgstore/apu/DPCM_ControlReg.jpg)|
|---|---|

## DPCM Interrupt Control

|![dpcm_int_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_int_control_tran.jpg)|![DPCM_IntControl](/BreakingNESWiki/imgstore/apu/DPCM_IntControl.jpg)|
|---|---|

## DPCM Enable Control

|![dpcm_enable_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_enable_control_tran.jpg)|![DPCM_EnableControl](/BreakingNESWiki/imgstore/apu/DPCM_EnableControl.jpg)|
|---|---|

## DPCM DMA Control

|![dpcm_dma_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_dma_control_tran.jpg)|![DPCM_DMAControl](/BreakingNESWiki/imgstore/apu/DPCM_DMAControl.jpg)|
|---|---|

## DPCM Sample Counter Control

![dpcm_sample_counter_control_tran1](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_control_tran1.jpg)

![dpcm_sample_counter_control_tran2](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_control_tran2.jpg)

(Вторая часть схемы также управляет счётчиком разрядов сэмпла)

![DPCM_SampleCounterControl](/BreakingNESWiki/imgstore/apu/DPCM_SampleCounterControl.jpg)

## DPCM Sample Buffer Control

![dpcm_sample_buffer_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_buffer_control_tran.jpg)

![DPCM_SampleBufferControl](/BreakingNESWiki/imgstore/apu/DPCM_SampleBufferControl.jpg)

## DPCM Sample Counter Register ($4013)

|![dpcm_sample_counter_in_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_in_tran.jpg)|![DPCM_SampleCounterReg](/BreakingNESWiki/imgstore/apu/DPCM_SampleCounterReg.jpg)|
|---|---|

## DPCM Sample Counter

Применяется обратный счётчик.

|![dpcm_sample_counter_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_tran.jpg)|![DPCM_SampleCounter](/BreakingNESWiki/imgstore/apu/DPCM_SampleCounter.jpg)|
|---|---|

## DPCM Sample Buffer

|![dpcm_sample_buffer_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_buffer_tran.jpg)|![DPCM_SampleBuffer](/BreakingNESWiki/imgstore/apu/DPCM_SampleBuffer.jpg)|
|---|---|

Регистр сдвига:

|![DPCM_SRBit](/BreakingNESWiki/imgstore/apu/DPCM_SRBit.jpg)|![DPCM_ShiftReg8](/BreakingNESWiki/imgstore/apu/DPCM_ShiftReg8.jpg)|
|---|---|

## DPCM Sample Bit Counter

Применяется прямой счётчик.

|![dpcm_sample_bit_counter_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_bit_counter_tran.jpg)|![DPCM_SampleBitCounter](/BreakingNESWiki/imgstore/apu/DPCM_SampleBitCounter.jpg)|
|---|---|

## DPCM Decoder

![dpcm_decoder_tran](/BreakingNESWiki/imgstore/apu/dpcm_decoder_tran.jpg)

![DPCM_Decoder](/BreakingNESWiki/imgstore/apu/DPCM_Decoder.jpg)

PLA1 является обычным демультиплексором 4-в-16, а PLA2 формирует входное значение для загрузки в LFSR.

|Decoder In|Decoder Out|
|---|---|
|0|0x173|
|1|0x08A|
|2|0x143|
|3|0x0DB|
|4|0x1EE|
|5|0x03F|
|6|0x07D|
|7|0x1D1|
|8|0x009|
|9|0x0DC|
|10|0x0F1|
|11|0x0F9|
|12|0x08D|
|13|0x189|
|14|0x18E|
|15|0x156|

|PLA1|PLA2|
|---|---|
|![DPCM_PLA1](/BreakingNESWiki/imgstore/apu/DPCM_PLA1.jpg)|![DPCM_PLA2](/BreakingNESWiki/imgstore/apu/DPCM_PLA2.jpg)|

Первая стадия декодера (демультиплексор 4-to-16):

```
10101010
01101010
10011010
01011010
10100110
01100110
10010110
01010110

10101001
01101001
10011001
01011001
10100101
01100101
10010101
01010101
```

Вторая стадия декодера:

```
100101010
100011100
011011100
010011101
011000001
011100001
110001001
011011111

011101000
010000011
000000111
100010000
001001001
001111010
101011101
001100010
```

Битовая маска топологическая. 1 означает есть транзистор, 0 означает нет транзистора.

## DPCM Frequency Counter LFSR

|![dpcm_freq_counter_lfsr_tran](/BreakingNESWiki/imgstore/apu/dpcm_freq_counter_lfsr_tran.jpg)|![DPCM_FreqLFSR](/BreakingNESWiki/imgstore/apu/DPCM_FreqLFSR.jpg)|
|---|---|

LFSR:

|![DPCM_LFSRBit](/BreakingNESWiki/imgstore/apu/DPCM_LFSRBit.jpg)|![DPCM_LFSR](/BreakingNESWiki/imgstore/apu/DPCM_LFSR.jpg)|
|---|---|

## DPCM Address Register ($4012)

|![dpcm_addr_in_tran](/BreakingNESWiki/imgstore/apu/dpcm_addr_in_tran.jpg)|![DPCM_AddressReg](/BreakingNESWiki/imgstore/apu/DPCM_AddressReg.jpg)|
|---|---|

## DPCM Address Counter

Применяется прямой счётчик.

|Младшая часть|Старшая часть|
|---|---|
|![dpcm_address_low_tran](/BreakingNESWiki/imgstore/apu/dpcm_address_low_tran.jpg)|![dpcm_address_high_tran](/BreakingNESWiki/imgstore/apu/dpcm_address_high_tran.jpg)|

Вход DMC_A15 в адресном мультиплексоре подключен к Vdd:

![DMC_A15](/BreakingNESWiki/imgstore/apu/DMC_A15.jpg)

![DPCM_AddressCounter](/BreakingNESWiki/imgstore/apu/DPCM_AddressCounter.jpg)

## DPCM Output ($4011)

Применяется реверсивный счётчик.

![dpcm_output_tran](/BreakingNESWiki/imgstore/apu/dpcm_output_tran.jpg)

![DPCM_Output](/BreakingNESWiki/imgstore/apu/DPCM_Output.jpg)
