# Регистровые операции

![apu_locator_regs](/BreakingNESWiki/imgstore/apu/apu_locator_regs.jpg)

|Сигнал|Откуда|Куда|Описание|
|---|---|---|---|
|R/W| | | |
|/DBGRD| | | |
|CPU_A\[15:0\]| | | |
|A\[15:0\]| | | |
|/REGRD| | | |
|/REGWR| | | |
|/R4015| | | |
|/R4016| | | |
|/R4017| | | |
|/R4018| | | |
|/R4019| | | |
|/R401A| | | |
|W4000| | | |
|W4001| | | |
|W4002| | | |
|W4003| | | |
|W4004| | | |
|W4005| | | |
|W4006| | | |
|W4007| | | |
|W4008| | | |
|W400A| | | |
|W400B| | | |
|W400C| | | |
|W400E| | | |
|W400F| | | |
|W4010| | | |
|W4011| | | |
|W4012| | | |
|W4013| | | |
|W4014| | | |
|W4015| | | |
|W4016| | | |
|W4017| | | |
|W401A| | | |
|SQA\[3:0\]| | | |
|SQB\[3:0\]| | | |
|TRI\[3:0\]| | | |
|RND\[3:0\]| | | |
|DMC\[6:0\]| | | |
|LOCK| | | |

Предекодер, для выбора адресного пространства регистров APU:

![pdsel_tran](/BreakingNESWiki/imgstore/apu/pdsel_tran.jpg)

- PDSELR: Промежуточный сигнал для формирования элемента 12-nor для получения сигнала `/REGRD`
- PDSELW: Промежуточный сигнал для формирования элемента 12-nor для получения сигнала `/REGWR`

R/W декодер для регистровых операций:

![reg_rw_decoder_tran](/BreakingNESWiki/imgstore/apu/reg_rw_decoder_tran.jpg)

Выбор регистровой операции:

![reg_select](/BreakingNESWiki/imgstore/apu/reg_select_tran.jpg)

:warning: Выбор адресного пространства регистров APU производится по значению адресной шины CPU (`CPU_Ax`). Но выбор регистра производится по значению адреса, который формируется на адресном мультиплексоре DMA-контроллера (cигналы A0-A4).

## Отладочный интерфейс

Вспомогательные схемы для внутреннего сигнала `DBG`:

|Усиливающий инвертер|Промежуточный инвертер|Сигнал /DBGRD|
|---|---|---|
|![dbg_buf1](/BreakingNESWiki/imgstore/apu/dbg_buf1.jpg)|![dbg_not1](/BreakingNESWiki/imgstore/apu/dbg_not1.jpg)|![nDBGRD](/BreakingNESWiki/imgstore/apu/nDBGRD.jpg)|

Транзисторные схемы считывания отладочных значений генераторов звука:

|Канал|Схема|Регистровая операция|Значение|Куда|
|---|---|---|---|---|
|Square 0|![square0_debug_tran](/BreakingNESWiki/imgstore/apu/square0_debug_tran.jpg)|/R4018|SQA\[3:0\]|D\[3:0\]|
|Square 1|![square1_debug_tran](/BreakingNESWiki/imgstore/apu/square1_debug_tran.jpg)|/R4018|SQB\[3:0\]|D\[7:4\]|
|Triangle|![tri_debug_tran](/BreakingNESWiki/imgstore/apu/tri_debug_tran.jpg)|/R4019|TRI\[3:0\]|D\[3:0\]|
|Noise|![noise_debug_tran](/BreakingNESWiki/imgstore/apu/noise_debug_tran.jpg)|/R4019|RND\[3:0\]|D\[7:4\]|
|DPCM|![dpcm_debug_tran](/BreakingNESWiki/imgstore/apu/dpcm_debug_tran.jpg)|/R401A|DMC\[6:0\]|D\[6:0\]|

Регистровые операции с отладочными значениями доступны только когда DBG = 1.

Схема LOCK:

![lock_tran](/BreakingNESWiki/imgstore/apu/lock_tran.jpg)

Сигнал `LOCK` используется для приостановки звуковых генераторов, чтобы их значения были зафиксированы и могли быть прочитаны используя регистры.

:warning: Отладочная обвязка доступна только в 2A03. PAL-версия APU (2A07) не содержит отладочных механизмов.
