# Прямоугольные каналы

![apu_locator_square](/BreakingNESWiki/imgstore/apu/apu_locator_square.jpg)

APU содержит два тональных генератора прямоугольных сигналов. Схемы зеркально повторяют друг друга, поэтому рассмотрим только тональный генератор первого прямоугольного канала (SQUARE 0, расположен правее).

Отличие SQUARE0 от SQUARE1 заключается в схеме входного переноса для сумматора:
- Для SQUARE0 входной перенос подключен к Vdd
- Для SQUARE1 на входной перенос подается сигнал `INC`

Иногда вместо Square0/Square1 у нас встречается обозначение SquareA/SquareB.

![SQUARE](/BreakingNESWiki/imgstore/apu/SQUARE.jpg)

## Frequency Reg

![square_freq_in_tran](/BreakingNESWiki/imgstore/apu/square_freq_in_tran.jpg)

![SQUARE_FreqReg](/BreakingNESWiki/imgstore/apu/SQUARE_FreqReg.jpg)

![SQUARE_FreqRegBit](/BreakingNESWiki/imgstore/apu/SQUARE_FreqRegBit.jpg)

## Shift Reg

Содержит значение сдвига для сдвигателя (0...7).

![square_shift_in_tran](/BreakingNESWiki/imgstore/apu/square_shift_in_tran.jpg)

![SQAURE_ShiftReg](/BreakingNESWiki/imgstore/apu/SQAURE_ShiftReg.jpg)

## Barrel Shifter

Сдвигатель 12-битного значения вправо со знаком (бит msb сдвигаясь вправо заполняет все остальные биты). Старший бит затем отбрасывается, формируя 11-битный результат.

![square_barrel_shifter_tran1](/BreakingNESWiki/imgstore/apu/square_barrel_shifter_tran1.jpg)

![square_barrel_shifter_tran2](/BreakingNESWiki/imgstore/apu/square_barrel_shifter_tran2.jpg)

![SQUARE_BarrelShifter](/BreakingNESWiki/imgstore/apu/SQUARE_BarrelShifter.jpg)

## Adder

Отличительной особенностью сумматора является комплементарная разводка сигналов a/b между разрядами и комплементарная цепочка переноса, а также инверсная полярность результата (`#sum`) и выходного переноса (`#COUT`).

![square_adder_tran](/BreakingNESWiki/imgstore/apu/square_adder_tran.jpg)

![SQUARE_Adder](/BreakingNESWiki/imgstore/apu/SQUARE_Adder.jpg)

![SQUARE_AdderBit](/BreakingNESWiki/imgstore/apu/SQUARE_AdderBit.jpg)

## Frequency Counter

![square_freq_counter_tran](/BreakingNESWiki/imgstore/apu/square_freq_counter_tran.jpg)

![square_freq_counter_control_tran](/BreakingNESWiki/imgstore/apu/square_freq_counter_control_tran.jpg)

![SQUARE_FreqCounter](/BreakingNESWiki/imgstore/apu/SQUARE_FreqCounter.jpg)

## Envelope

Decay Counter:

![square_decay_counter_tran](/BreakingNESWiki/imgstore/apu/square_decay_counter_tran.jpg)

![square_envelope_control_tran1](/BreakingNESWiki/imgstore/apu/square_envelope_control_tran1.jpg)

![square_envelope_control_tran2](/BreakingNESWiki/imgstore/apu/square_envelope_control_tran2.jpg)

Envelope Counter:

![square_envelope_counter_tran](/BreakingNESWiki/imgstore/apu/square_envelope_counter_tran.jpg)

Схема идентична схеме Envelope в генераторе шума.

![EnvelopeUnit](/BreakingNESWiki/imgstore/apu/EnvelopeUnit.jpg)

|Сигнал EnvelopeUnit|Square0 Channel|Square1 Channel|
|---|---|---|
|WR_Reg|W4000|W4004|
|WR_LC|W4003|W4007|
|LC|SQA/LC|SQB/LC|

## Sweep

|Сигнал/Группа сигналов|Откуда|Куда|Назначение|
|---|---|---|---|
|ADDOUT|Sweep|Freq Reg|Основной сигнал, который управляет процессом Sweep значения частоты, загруженной в Freq Reg|
|SR\[2:0\], SRZ|Shift Reg|Sweep,Shifter|Определяет магнитуду сдвига исходной частоты. Если SR=0, то сигнал ADDOUT никогда не генерируется (логично)|
|DEC (и его комплемент INC)|Dir Reg|Sweep,Shifter,Adder|Определяет направление приращения частоты (DEC=1: частота снижается, DEC=0: частота повышается)|
|#COUT|Adder|Sweep|Выходной перенос сумматора (инверсная полярность)|
|SWCTRL|Sweep|Sweep,Output|Равен 1 когда INC=1 и активен выходной перенос сумматора. Когда значение SWCTRL=1 - ADDOUT равен 0. То есть при переполнении частоты процесс Sweep не происходит (логично)|
|SWEEP|Adder|Sweep,Output|1: Значение частоты меньше 4 (сброшены биты \[10:2\] Freq Reg). Когда значение SWEEP=1 - ADDOUT равен 0. То есть при слишком низкой частоте нет смысла делать Sweep|
|NOSQ|Length Counter|Common|1: Счётчик длительности завершил свой отсчёт/отключен. Когда счётчик длительности не работает сигнал ADDOUT никогда не генерируется (логично)|
|/LFO2|SoftCLK|Common|Сигнал низкочастотной осцилляции (инверсная полярность). В применении к Sweep - производит перезагрузку счётчика Sweep значением из регистра Sweep Reg|
|SCO|Sweep|Sweep|Выходной перенос Sweep Counter. Пока Sweep Counter считает - ADDOUT равен 0|
|SWRELOAD|Sweep|Sweep|1: Выполнить перезагрузку Sweep Counter|
|SWDIS|Значение регистра WR1\[3\]|Sweep|1: Отключить процесс Sweep, ADDOUT всегда равен 0|

Внимательно изучив и осмыслив все сигналы, которые используется в Sweep Unit можно составить картину происходящего:
- Основным драйвером процесса Sweep является сигнал ADDOUT. Когда этот сигнал активируется - запускается процесс модуляции частоты в регистре Freq Req, используя регистр сдвига и сумматор
- Итерация счётчика Sweep осуществляется сигналом низкочастотной осцилляции `/LFO2`
- Счётчик Sweep перегружается самостоятельно значением из регистра Sweep Reg, одновременно срабатывает сигнал ADDOUT (если все условия выполнены, см. ниже)

Sweep НЕ происходит при следующих условиях (на схеме - это большой NOR):
- Sweep отключен соответствующим управляющим регистром (SWDIS)
- Счётчик длительности прямоугольного канала завершил свой отсчёт или отключен (NOSQ)
- Значение магнитуды регистре Shift Reg равно 0 (SRZ)
- Значение частоты привело к переполнению сумматора, в режиме увеличения частоты (SWCTRL)
- Значение частоты менее 4 (SWEEP)
- Счётчик Sweep не завершил свою работу (SCO=0)
- Сигнал низкочастотной осцилляции не активен (/LFO2=1)

![square_sweep_control_tran1](/BreakingNESWiki/imgstore/apu/square_sweep_control_tran1.jpg)

![square_sweep_control_tran2](/BreakingNESWiki/imgstore/apu/square_sweep_control_tran2.jpg)

Sweep Counter:

![square_sweep_counter_tran](/BreakingNESWiki/imgstore/apu/square_sweep_counter_tran.jpg)

![square_sweep_counter_control_tran](/BreakingNESWiki/imgstore/apu/square_sweep_counter_control_tran.jpg)

![SQUARE_Sweep](/BreakingNESWiki/imgstore/apu/SQUARE_Sweep.jpg)

## Duty

Duty Counter:

![square_duty_counter_tran](/BreakingNESWiki/imgstore/apu/square_duty_counter_tran.jpg)

![square_duty_cycle_tran](/BreakingNESWiki/imgstore/apu/square_duty_cycle_tran.jpg)

![SQUARE_Duty](/BreakingNESWiki/imgstore/apu/SQUARE_Duty.jpg)

Принцип работы:
- Сигнал FLOAD, используемый для загрузки счётчика частоты одновременно используется для итерации счётчика Duty
- Загрузка счётчика длительности очищает счётчик Duty соответствующего прямоугольного канала
- Выходной перенос счётчика частоты (сигнал FCO) является входным переносом для счётчика Duty
- Когда сигнал `DUTY` равен 0 на выходе прямоугольного генератора также 0

Таблица значений сигнала DUTY в зависимости от значений счётчика Duty и настроек регистра Duty (d):

|Значение счётчика Duty|d=0 (12.5%)|d=1 (25%)|d=2 (50%)|d=3 (75%)|
|---|---|---|---|---|
|0|0|0|0|1|
|1|0|0|0|1|
|2|0|0|0|1|
|3|0|0|0|1|
|4|0|0|1|1|
|5|0|0|1|1|
|6|0|1|1|0|
|7|1|1|1|0|

## Output

![square_output_tran](/BreakingNESWiki/imgstore/apu/square_output_tran.jpg)

![SQUARE_Output](/BreakingNESWiki/imgstore/apu/SQUARE_Output.jpg)
