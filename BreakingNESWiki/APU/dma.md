# Спрайтовая DMA

![apu_locator_dma](/BreakingNESWiki/imgstore/apu/apu_locator_dma.jpg)

Данный компонент выполняет роль небольшого DMA-контроллера, который кроме спрайтовой DMA ещё занимается арбитражем адресной шины.

![SPRDMA](/BreakingNESWiki/imgstore/apu/SPRDMA.jpg)

## SPR DMA Address

Младшие разряды адреса:

![sprdma_addr_low_tran](/BreakingNESWiki/imgstore/apu/sprdma_addr_low_tran.jpg)

Старшие разряды адреса:

|![sprdma_addr_hi_tran](/BreakingNESWiki/imgstore/apu/sprdma_addr_hi_tran.jpg)|![SPRDMA_Control](/BreakingNESWiki/imgstore/apu/SPRDMA_Control.jpg)|
|---|---|

Стрелками отмечены места, где формируется константный адрес регистра PPU $2002.

## SPR DMA Control

![sprdma_control_tran](/BreakingNESWiki/imgstore/apu/sprdma_control_tran.jpg)

Стрелками отмечены "другие" /ACLK, которые отличаются от обычного /ACLK небольшой задержкой.

Логическая схема:

![SPRDMA_Control](/BreakingNESWiki/imgstore/apu/SPRDMA_Control.jpg)

## SPR DMA Buffer

![sprbuf_tran](/BreakingNESWiki/imgstore/apu/sprbuf_tran.jpg)

Логическая схема:

![SPRDMA_Buffer](/BreakingNESWiki/imgstore/apu/SPRDMA_Buffer.jpg)

## Address MUX

Адресный мультиплексор используется для арбитража внешней шины адреса. На базе контрольных сигналов выбирается кто сейчас "пользуется" шиной адреса:

- SPR/CPU: Адрес памяти для чтения в процессе спрайтовой DMA
- SPR/PPU: Установлено константное значение адреса для записи в регистр PPU $2002
- #DMC/AB: Шиной адреса управляет схема DMC, для выполнения DMC DMA
- По умолчанию (CPU/AB): Шиной адреса управляет процессор

Управление адресным мультиплексором:

![sprdma_addr_mux_control_tran](/BreakingNESWiki/imgstore/apu/sprdma_addr_mux_control_tran.jpg)

![sprdma_addr_mux_tran](/BreakingNESWiki/imgstore/apu/sprdma_addr_mux_tran.jpg)

Схема одного разряда:

![sprdma_addr_mux_bit_tran](/BreakingNESWiki/imgstore/apu/sprdma_addr_mux_bit_tran.jpg)

Логическая схема:

![Addr_MUX](/BreakingNESWiki/imgstore/apu/Addr_MUX.jpg)
