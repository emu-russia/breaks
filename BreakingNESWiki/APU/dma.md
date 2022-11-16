# Спрайтовая DMA

![apu_locator_dma](/BreakingNESWiki/imgstore/apu/apu_locator_dma.jpg)

Данный компонент выполняет роль небольшого DMA-контроллера, который кроме спрайтовой DMA ещё занимается арбитражем адресной шины и контролем готовности процессора (RDY).

![SPRDMA](/BreakingNESWiki/imgstore/apu/SPRDMA.jpg)

Спрайтовая DMA весьма тесно переплетена с [DMC DMA](dpcm.md) и находится у неё в "подчинении" (пока сигнал RUNDMC = 1 спрайтовая DMA находится в режиме ожидания).

К сожалению, целевой адрес спрайтовой DMA невозможно конфигурировать и он жестко настроен на регистр PPU $2004.

## SPR DMA Address

Младшие разряды адреса:

|![sprdma_addr_low_tran](/BreakingNESWiki/imgstore/apu/sprdma_addr_low_tran.jpg)|![SPRDMA_AddrLowCounter](/BreakingNESWiki/imgstore/apu/SPRDMA_AddrLowCounter.jpg)|
|---|---|

Старшие разряды адреса:

|![sprdma_addr_hi_tran](/BreakingNESWiki/imgstore/apu/sprdma_addr_hi_tran.jpg)|![SPRDMA_AddrHigh](/BreakingNESWiki/imgstore/apu/SPRDMA_AddrHigh.jpg)|
|---|---|

Знаком :warning: отмечены места, где формируется константный адрес регистра PPU $2004.

## SPR DMA Control

![sprdma_control_tran](/BreakingNESWiki/imgstore/apu/sprdma_control_tran.jpg)

Знаком :warning: отмечены "другие" /ACLK, которые отличаются от обычного /ACLK небольшой задержкой.

Логическая схема:

![SPRDMA_Control](/BreakingNESWiki/imgstore/apu/SPRDMA_Control.jpg)

Контрольные сигналы для взаимодействия с DMC:
- RUNDMC: DMC делает свои дела. Пока он не закончит - спрайтовая DMA находится в режиме ожидания
- #DMC/AB: DMC занимает шину адреса
- DMCRDY: Готовность DMC. Если DMC не готов - то сигнал RDY также принудительно устанавливается в 0.

Контрольные сигналы от процессора:
- PHI1 и R/W: Спрайтовая DMA может начаться только если процессор переходит в цикл чтения (PHI1 = 0 и R/W = 1). Без этого условия контрольный сигнал `DOSPR` не будет активен. Сделано это для "оттягивания" начала DMA, т.к. сброс RDY игнорируется на циклах записи 6502.

![Write_4014_Timing](/BreakingNESWiki/imgstore/apu/Write_4014_Timing.jpg)

|STA T0 PHI1|STA T0 PHI2|STA T1 PHI1|STA T1 PHI2|
|---|---|---|---|
|![SPRDMA_Control_T0_Phi1](/BreakingNESWiki/imgstore/apu/SPRDMA_Control_T0_Phi1.jpg)|![SPRDMA_Control_T0_Phi2](/BreakingNESWiki/imgstore/apu/SPRDMA_Control_T0_Phi2.jpg)|![SPRDMA_Control_T1_Phi1](/BreakingNESWiki/imgstore/apu/SPRDMA_Control_T1_Phi1.jpg)|![SPRDMA_Control_T1_Phi2](/BreakingNESWiki/imgstore/apu/SPRDMA_Control_T1_Phi2.jpg)|

Сигналы, влияющие на процесс DMA:
- W4014: Записью в регистр $4014 младшая часть адреса очищается, а в старшую попадает записываемое значение. После этого DMA стартует.
- SPRS: Выполнить инкремент младшей части адреса ("Step")
- SPRE: Закончить выполнение DMA ("End")

Сразу после начала спрайтовой DMA контрольные сигналы SPR/PPU и SPR/CPU попеременно начинают менять своё значение, для того чтобы значение вначале прочиталось из памяти в спрайтовый буфер, а затем записалось в регистр PPU $2004.

## SPR DMA Buffer

![sprbuf_tran](/BreakingNESWiki/imgstore/apu/sprbuf_tran.jpg)

Логическая схема:

![SPRDMA_Buffer](/BreakingNESWiki/imgstore/apu/SPRDMA_Buffer.jpg)

## Address MUX

Адресный мультиплексор используется для арбитража внешней шины адреса. На базе контрольных сигналов выбирается кто сейчас "пользуется" шиной адреса:

- SPR/CPU: Адрес памяти для чтения в процессе спрайтовой DMA
- SPR/PPU: Установлено константное значение адреса для записи в регистр PPU $2004
- #DMC/AB: Шиной адреса управляет схема DMC, для выполнения DMC DMA
- По умолчанию (CPU/AB): Шиной адреса управляет процессор

Управление адресным мультиплексором:

![sprdma_addr_mux_control_tran](/BreakingNESWiki/imgstore/apu/sprdma_addr_mux_control_tran.jpg)

Сам мультиплексор состоит из 16 повторяющихся схем, для каждого разряда:

![sprdma_addr_mux_bit_tran](/BreakingNESWiki/imgstore/apu/sprdma_addr_mux_bit_tran.jpg)

Логическая схема:

![Addr_MUX](/BreakingNESWiki/imgstore/apu/Addr_MUX.jpg)
