# Дельта-модуляция (DPCM)

![apu_locator_dpcm](/BreakingNESWiki/imgstore/apu/apu_locator_dpcm.jpg)

![DMC](/BreakingNESWiki/imgstore/apu/DMC.jpg)

## Другой /ACLK

В самом центре схемы DPCM находится схема, для получения "другого" /ACLK, который используется в DPCM, а также в [спрайтовой DMA](dma.md). Данный сигнал /ACLK отличается от обычного небольшой задержкой.
Этот сигнал ещё можно встретить в наших схемах под названием `/ACLK2`.

![Other_nACLK](/BreakingNESWiki/imgstore/apu/Other_nACLK.jpg)

На схемах ниже стрелкой отмечены места, где используется `/ACLK2`.

## DPCM Control Register ($4010)

![dpcm_control_reg_tran](/BreakingNESWiki/imgstore/apu/dpcm_control_reg_tran.jpg)

## DPCM Interrupt Control

![dpcm_int_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_int_control_tran.jpg)

## DPCM Enable Control

![dpcm_enable_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_enable_control_tran.jpg)

## DPCM DMA Control

![dpcm_dma_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_dma_control_tran.jpg)

## DPCM Sample Counter In ($4013)

![dpcm_sample_counter_in_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_in_tran.jpg)

## DPCM Sample Counter

![dpcm_sample_counter_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_tran.jpg)

## DPCM Sample Counter Control

![dpcm_sample_counter_control_tran1](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_control_tran1.jpg)

![dpcm_sample_counter_control_tran2](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_control_tran2.jpg)

(Вторая часть схемы также управляет счетчиком разрядов сэмпла)

## DPCM Sample Buffer

![dpcm_sample_buffer_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_buffer_tran.jpg)

## DPCM Sample Buffer Control

![dpcm_sample_buffer_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_buffer_control_tran.jpg)

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
