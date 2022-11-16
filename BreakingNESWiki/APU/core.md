# Ядро 6502 и сопутствующая логика

![apu_locator_core](/BreakingNESWiki/imgstore/apu/apu_locator_core.jpg)

В данном разделе описаны особенности ядра и окружающей его вспомогательной логики, предназначенной для интеграции с остальными компонентами.

В состав ядра 6502 и окружающей его логики входят следующие сущности:
- Главный тактовый сигнал и делитель частоты
- Привязка контактов ядра 6502 к остальной части APU
- Ядро 6502
- Декодер регистровых операций
- Отладочные регистры
- Внешние порты ввода/вывода

Чтобы вы не заблудились, вот более крупный масштаб рассматриваемых далее схем:

![6502_core_clock](/BreakingNESWiki/imgstore/apu/6502_core_clock.jpg)

![6502_core_pads_tran](/BreakingNESWiki/imgstore/apu/6502_core_pads_tran.jpg)

## Главный тактовый сигнал

Контакт CLK:

![pad_clk](/BreakingNESWiki/imgstore/apu/pad_clk.jpg)

Делитель частоты:

![div](/BreakingNESWiki/imgstore/apu/div.jpg)

(Для удобства схема положена "на бок").

TBD: Более подробное описание делителя.

Контакт M2:

![pad_m2](/BreakingNESWiki/imgstore/apu/pad_m2.jpg)

Схема для получения сигнала `NotDBG_RES`:

![notdbg_res_tran](/BreakingNESWiki/imgstore/apu/notdbg_res_tran.jpg)

По какой-то причине схема содержит отключенную "гребенку" транзисторов, которая представляет собой цепочку инверторов внутреннего сигнала `RES`.

В режиме отладки (когда DBG=1) - во время сброса внешний сигнал M2 не трогается. В обычном режиме (для Retail консолей) - во время сброса внешний сигнал M2 в состоянии `z` (Open-drain):

```c++
if ( RES & ~DBG) M2 = z;
else M2 = NOT(n_M2);
```

## Соединение 6502 и APU

В данном разделе рассматриваются соединения контактов ядра 6502 с APU.

### /NMI и /IRQ

Вспомогательная логика для обработки NMI и IRQ:

|Схема|Описание|
|---|---|
|![apu_core_irqnmi_logic1](/BreakingNESWiki/imgstore/apu/apu_core_irqnmi_logic1.jpg)|Просто промежуточные инвертеры|
|![apu_core_irqnmi_logic2](/BreakingNESWiki/imgstore/apu/apu_core_irqnmi_logic2.jpg)|/IRQ_INT: Комбинация внешнего или внутреннего прерывания.|

Терминал /NMI:

![apu_core_nmi](/BreakingNESWiki/imgstore/apu/apu_core_nmi.jpg)

Терминал /IRQ:

![apu_core_irq](/BreakingNESWiki/imgstore/apu/apu_core_irq.jpg)

### RDY

![apu_core_rdy](/BreakingNESWiki/imgstore/apu/apu_core_rdy.jpg)

Рядом со входом RDY есть ещё один транзистор, который в NTSC APU всегда открыт. TBD: Добавить про PAL APU.

### /RES

![apu_core_res](/BreakingNESWiki/imgstore/apu/apu_core_res.jpg)

На входе терминала /RES находится инвертер, чтобы инвертировать внутренний сигнал `RES`.

### PHI0, PHI1, PHI2

Генерация внутренних сигналов PHI:

![apu_core_phi_internal](/BreakingNESWiki/imgstore/apu/apu_core_phi_internal.jpg)

Генерация внешних сигналов PHI:

|PHI1|PHI2|
|---|---|
|![apu_core_phi1_ext](/BreakingNESWiki/imgstore/apu/apu_core_phi1_ext.jpg)|![apu_core_phi2_ext](/BreakingNESWiki/imgstore/apu/apu_core_phi2_ext.jpg)|

Ничего необычного.

### SO

![apu_core_so](/BreakingNESWiki/imgstore/apu/apu_core_so.jpg)

Терминал SO всегда подсоединен к `1`. Технически это нормально, т.к. на входе SO находится falling edge detector.

### R/W

![apu_core_rw](/BreakingNESWiki/imgstore/apu/apu_core_rw.jpg)

Ничего необычного.

Сигнал `RW` приходит не напрямую с терминала `R/W` ядра 6502, а получается в схеме буфера для спрайтовой DMA (см. ниже).

### SYNC

Контакт SYNC ни с чем не соединен (floating):

![apu_core_sync](/BreakingNESWiki/imgstore/apu/apu_core_sync.jpg)

### D0-D7

Контакты ядра 6502 соединяются напрямую с внутренней шиной данных D0-D7.

Схема сигнала `RD`:

![rd_tran](/BreakingNESWiki/imgstore/apu/rd_tran.jpg)

Буфер для спрайтовой DMA:

![sprbuf_tran](/BreakingNESWiki/imgstore/apu/sprbuf_tran.jpg)

Не очень к месту, но сказать придется именно в этом месте, т.к. кроме хранения данных для спрайтовой DMA данная схема также занимается получением сигнала `WR` для контактов внешней шины данных, а также сигнала `RW`.

:warning: Так получилось, что сигнал ядра 6502 `R/W` по названию очень похож на сигнал `RW`, который уходит на внешний контакт R/W. Не перепутайте :smiley:

### A0-A15

Выходы шины адреса ядра 6502 ассоциированы с внутренними сигналами CPU_A0-15.

Для CPU_A14 дополнительно имеется инвертер, который используется в схеме предекодирования адреса регистров APU.

## Встроенное ядро 6502

Внешне ядро 6502 выглядит как копи-паста исходного процессора MOS в уменьшенном варианте.

После детального изучения схемы 2A03 были получены следующие результаты:
- Отличий в декодере не обнаружено
- Флаг D работает как обычно, его можно установить или сбросить, он используется нормальным образом при обработке прерываний (сохраняется в стеке) и после выполнения инструкций PHP/PLP, RTI.
- Рандомная логика отвечающая за генерацию двух контрольных сигналов `/DAA` (decimal addition adjust) и `/DSA` (decimal subtraction adjust) работает обычным образом.

Отличие заключается в том, что контрольные сигналы `/DAA` и `/DSA`, отвечающие за включение схем коррекции, отсоединены от схемы, путём вырезания 5 кусочков полисиликона (см. картинку). Полисиликон обозначен фиолетовым цветом, вырезанные кусочки обозначены голубым, а места обведены красным.

|Оригинальное изображение схемы 6502|Места с отсутствующим поли в APU|
|---|---|
|![bcd_tran_orig](/BreakingNESWiki/imgstore/apu/bcd_tran_orig.png)|![bcd_tran_apu_missing](/BreakingNESWiki/imgstore/apu/bcd_tran_apu_missing.png)|

Это приводит к тому, что схема вычисления десятичного переноса при сложении и схема добавления/отнимания 6 к результату - не работают. Поэтому встроенный процессор APU всегда считает двоичными числами, даже если флаг D установлен.

Процесс исследования: http://youtu.be/Gmi1DgysGR0

Ключевые узлы по которым был проведен анализ (декодер, рандомная логика, флаги и АЛУ) представлена на следующем изображении:

![2a03_6502_diff_sm](/BreakingNESWiki/imgstore/apu/2a03_6502_diff_sm.jpg)

Чтобы понять больше суть различий в работе BCD-схемы, рекомендуется изучить устройство АЛУ 6502.

## Регистровые операции

Предекодер, для выбора адресного пространства регистров APU:

![pdsel_tran](/BreakingNESWiki/imgstore/apu/pdsel_tran.jpg)

- PDSELR: Промежуточный сигнал для формирования элемента 12-nor для получения сигнала `/REGRD`
- PDSELW: Промежуточный сигнал для формирования элемента 12-nor для получения сигнала `/REGWR`

R/W декодер для регистровых операций:

![reg_rw_decoder_tran](/BreakingNESWiki/imgstore/apu/reg_rw_decoder_tran.jpg)

Выбор регистровой операции:

![reg_select](/BreakingNESWiki/imgstore/apu/reg_select_tran.jpg)

:warning: Выбор адресного пространства регистров APU производится по значению адресной шины CPU (`CPU_Ax`). Но выбор регистра производится по значению адреса, который формируется на адресном мультиплексоре DMA-контроллера (cигналы A0-A4).

## Отладочные регистры

Контакт DBG:

![pad_dbg](/BreakingNESWiki/imgstore/apu/pad_dbg.jpg)

Вспомогательные схемы для DBG:

|Усиливающий инвертер|Промежуточный инвертер|Сигнал /DBGRD|
|---|---|---|
|![dbg_buf1](/BreakingNESWiki/imgstore/apu/dbg_buf1.jpg)|![dbg_not1](/BreakingNESWiki/imgstore/apu/dbg_not1.jpg)|![nDBGRD](/BreakingNESWiki/imgstore/apu/nDBGRD.jpg)|

Транзисторные схемы отладочных регистров:

|Square 0|Square 1|Triangle|Noise|DPCM|
|---|---|---|---|---|
|![square0_debug_tran](/BreakingNESWiki/imgstore/apu/square0_debug_tran.jpg)|![square1_debug_tran](/BreakingNESWiki/imgstore/apu/square1_debug_tran.jpg)|![tri_debug_tran](/BreakingNESWiki/imgstore/apu/tri_debug_tran.jpg)|![noise_debug_tran](/BreakingNESWiki/imgstore/apu/noise_debug_tran.jpg)|![dpcm_debug_tran](/BreakingNESWiki/imgstore/apu/dpcm_debug_tran.jpg)|

Регистровые операции с отладочными регистрами доступны только когда DBG = 1.

Схема LOCK:

![lock_tran](/BreakingNESWiki/imgstore/apu/lock_tran.jpg)

Сигнал `LOCK` используется для временной приостановки тональных генераторов, чтобы их значения были зафиксированы в отладочных регистрах.

## Порты ввода/вывода

Схема для формирования сигналов OUTx:

![out_tran](/BreakingNESWiki/imgstore/apu/out_tran.jpg)

- Выходное значение для контактов `OUT0-2` получается из внутренних сигналов `OUT0-2` (с таким же названием).
- Выходное значение для контактов `/IN0-1` - это внутренние сигналы `/R4016` и `/R4017` с селектора регистров.
