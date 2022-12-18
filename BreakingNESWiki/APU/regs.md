# Регистровые операции

![apu_locator_regs](/BreakingNESWiki/imgstore/apu/apu_locator_regs.jpg)

|Сигнал|Откуда|Куда|Описание|
|---|---|---|---|
|R/W|CPU Core| | |
|/DBGRD| | | |
|CPU_A\[15:0\]|CPU Core| | |
|A\[15:0\]|Address Mux| | |
|/REGRD|Reg Predecode| | |
|/REGWR|Reg Predecode| | |
|/R4015|Reg Select| | |
|/R4016|Reg Select| | |
|/R4017|Reg Select| | |
|/R4018|Reg Select| | |
|/R4019|Reg Select| | |
|/R401A|Reg Select| | |
|W4000|Reg Select| | |
|W4001|Reg Select| | |
|W4002|Reg Select| | |
|W4003|Reg Select| | |
|W4004|Reg Select| | |
|W4005|Reg Select| | |
|W4006|Reg Select| | |
|W4007|Reg Select| | |
|W4008|Reg Select| | |
|W400A|Reg Select| | |
|W400B|Reg Select| | |
|W400C|Reg Select| | |
|W400E|Reg Select| | |
|W400F|Reg Select| | |
|W4010|Reg Select| | |
|W4011|Reg Select| | |
|W4012|Reg Select| | |
|W4013|Reg Select| | |
|W4014|Reg Select| | |
|W4015|Reg Select| | |
|W4016|Reg Select| | |
|W4017|Reg Select| | |
|W401A|Reg Select| | |
|SQA\[3:0\]| | | |
|SQB\[3:0\]| | | |
|TRI\[3:0\]| | | |
|RND\[3:0\]| | | |
|DMC\[6:0\]| | | |
|LOCK|Lock FF| | |

Предекодер, для выбора адресного пространства регистров APU:

![pdsel_tran](/BreakingNESWiki/imgstore/apu/pdsel_tran.jpg)

- PDSELR: Промежуточный сигнал для формирования элемента 12-nor для получения сигнала `/REGRD`
- PDSELW: Промежуточный сигнал для формирования элемента 12-nor для получения сигнала `/REGWR`

R/W декодер для регистровых операций:

![reg_rw_decoder_tran](/BreakingNESWiki/imgstore/apu/reg_rw_decoder_tran.jpg)

![RegPredecode](/BreakingNESWiki/imgstore/apu/RegPredecode.jpg)

Выбор регистровой операции:

![reg_select](/BreakingNESWiki/imgstore/apu/reg_select_tran.jpg)

:warning: Выбор адресного пространства регистров APU производится по значению адресной шины CPU (`CPU_Ax`). Но выбор регистра производится по значению адреса, который формируется на адресном мультиплексоре DMA-контроллера (cигналы A0-A4).

Битовая маска:

```
101010110100
110010110100
101100110100
001100110101

110011001100
010100101011
001100101011
010101001011
010010101011

001011001011
010011001011
001011010011
001101001011
001010101011

001010110011
010011001101
001100110011
010010101101
010100110011

010101010011
001101010011
110101001100
010100101101
101101001100

001100101101
001101001101
001010101101
010101001101
001011001101
```

Битовая маска топологическая. 1 означает есть транзистор, 0 означает нет транзистора.

![RegSel](/BreakingNESWiki/imgstore/apu/RegSel.jpg)

## Отладочный интерфейс

:warning: Отладочная обвязка доступна только в 2A03. PAL-версия APU (2A07) не содержит отладочных механизмов.

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

Схема для чтения отладочного значения:

![DbgReadoutBit](/BreakingNESWiki/imgstore/apu/DbgReadoutBit.jpg)

Схема LOCK:

|![lock_tran](/BreakingNESWiki/imgstore/apu/lock_tran.jpg)|![lock](/BreakingNESWiki/imgstore/apu/lock.jpg)|
|---|---|

Сигнал `LOCK` используется для приостановки звуковых генераторов, чтобы их значения были зафиксированы и могли быть прочитаны используя регистры.
