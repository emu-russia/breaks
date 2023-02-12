# Регистровые операции

![apu_locator_regs](/BreakingNESWiki/imgstore/apu/apu_locator_regs.jpg)

|Сигнал|Откуда|Куда|Описание|
|---|---|---|---|
|R/W|CPU Core|DMABuffer, Reg Select, OAM DMA, DPCM DMA|Терминал ядра 6502. В применении к DMA используется для детектирования цикла чтения CPU, для корректной установки терминала RDY|
|/DBGRD|Reg Select|DMABuffer|0: Производится чтение регистра APU и при этом включен тестовый режим (терминал DBG=1)|
|CPU_A\[15:0\]|CPU Core|Reg Predecode, Address Mux|Шина адреса ядра 6502. Участвует в выборе регистра APU и для мультиплексирования адреса|
|A\[15:0\]|Address Mux|External Address Pads|Выходное значение с адресного мультиплексора для терминалов AB|
|/REGRD|Reg Predecode|Reg Select|0: Производится чтение регистра APU со стороны ядра 6502|
|/REGWR|Reg Predecode|Reg Select|0: Производится запись в регистр APU со стороны ядра 6502|
|/R4015|Reg Select|SoftCLK, DMABuffer, Length, DPCM|0: Чтение регистра $4015. Обратите внимание что эта операция дополнительно отслеживается в DMABuffer.|
|/R4016|Reg Select|IOPorts|0: Чтение регистра $4016|
|/R4017|Reg Select|IOPorts|0: Чтение регистра $4017|
|/R4018|Reg Select|Test|0: Чтение отладочного регистра $4018 (только для 2A03)|
|/R4019|Reg Select|Test|0: Чтение отладочного регистра $4019 (только для 2A03)|
|/R401A|Reg Select|Test|0: Чтение отладочного регистра $401A (только для 2A03)|
|W4000|Reg Select|Square0|1: Запись регистра $4000|
|W4001|Reg Select|Square0|1: Запись регистра $4001|
|W4002|Reg Select|Square0|1: Запись регистра $4002|
|W4003|Reg Select|Square0|1: Запись регистра $4003|
|W4004|Reg Select|Square1|1: Запись регистра $4004|
|W4005|Reg Select|Square1|1: Запись регистра $4005|
|W4006|Reg Select|Square1|1: Запись регистра $4006|
|W4007|Reg Select|Square1|1: Запись регистра $4007|
|W4008|Reg Select|Triangle|1: Запись регистра $4008|
|W400A|Reg Select|Triangle|1: Запись регистра $400A|
|W400B|Reg Select|Triangle|1: Запись регистра $400B|
|W400C|Reg Select|Noise|1: Запись регистра $400C|
|W400E|Reg Select|Noise|1: Запись регистра $400E|
|W400F|Reg Select|Noise|1: Запись регистра $400F|
|W4010|Reg Select|DPCM|1: Запись регистра $4010|
|W4011|Reg Select|DPCM|1: Запись регистра $4011|
|W4012|Reg Select|DPCM|1: Запись регистра $4012|
|W4013|Reg Select|DPCM|1: Запись регистра $4013|
|W4014|Reg Select|OAM DMA|1: Запись регистра $4014|
|W4015|Reg Select|Length, DPCM|1: Запись регистра $4015|
|W4016|Reg Select|IOPorts|1: Запись регистра $4016|
|W4017|Reg Select|SoftCLK|1: Запись регистра $4017|
|W401A|Reg Select|Test, Triangle|1: Запись отладочного регистра $401A (только для 2A03)|
|SQA\[3:0\]|Square0|AUX A|Выходное цифровое значение звукового генератора Square0|
|SQB\[3:0\]|Square1|AUX A|Выходное цифровое значение звукового генератора Square1|
|TRI\[3:0\]|Triangle|AUX B|Выходное цифровое значение звукового генератора Triangle|
|RND\[3:0\]|Noise|AUX B|Выходное цифровое значение звукового генератора Noise|
|DMC\[6:0\]|DPCM|AUX B|Выходное цифровое значение звукового генератора DPCM|
|LOCK|Lock FF|Square0, Square1, Triangle, Noise, DPCM|Для фиксации громкости звуковых генераторов, чтобы можно было прочитать значение используя отладочные регистры|

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

:warning: Отладочная обвязка доступна только в 2A03. PAL-версия APU (2A07) не содержит отладочных механизмов (кроме сигнала RDY2).

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

Сигнал `LOCK` используется для приостановки или отсоединения звуковых генераторов от выхода, чтобы текущие значения громкости были зафиксированы и могли быть прочитаны используя отладочные регистры.
