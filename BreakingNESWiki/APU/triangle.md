# Треугольный канал

![apu_locator_triangle](/BreakingNESWiki/imgstore/apu/apu_locator_triangle.jpg)

![TRIANGLE](/BreakingNESWiki/imgstore/apu/TRIANGLE.jpg)

## Сигналы

|Сигнал|Описание|
|---|---|
|/LFO1|Сигнал низкочастотной осцилляции 1/4 периода (инверсная полярность)|
|NOTRI|Triangle LC не считает / отключен|
|TRI/LC|Входной перенос для Triangle LC|
|TCO|Выходной перенос со счётчика Linear Counter|
|FOUT|Выходной перенос со счётчика Frequency Counter|
|TLOAD|Загрузить счётчик Linear Counter|
|TSTEP|Выполнить шаг счётчика Frequency Counter|
|FLOAD|Загрузить счётчик Frequency Counter|
|FSTEP|Выполнить шаг счётчика Frequency Counter|
|TTSTEP|Выполнить шаг выходного счётчика Output|

Разработчики решили использовать для треугольного канала PHI1 в некоторых местах вместо ACLK, чтобы сгладить "ступенчатость" сигнала.

## Triangle Control

![tri_linear_counter_control_tran1](/BreakingNESWiki/imgstore/apu/tri_linear_counter_control_tran1.jpg)

![tri_linear_counter_control_tran2](/BreakingNESWiki/imgstore/apu/tri_linear_counter_control_tran2.jpg)

![tri_freq_counter_control_tran](/BreakingNESWiki/imgstore/apu/tri_freq_counter_control_tran.jpg)

![TRIANGLE_Control](/BreakingNESWiki/imgstore/apu/TRIANGLE_Control.jpg)

## Linear Counter

7-разрядный DownCounter.

![tri_linear_counter_tran](/BreakingNESWiki/imgstore/apu/tri_linear_counter_tran.jpg)

![TRIANGLE_LinearCounter](/BreakingNESWiki/imgstore/apu/TRIANGLE_LinearCounter.jpg)

## Frequency Counter

11-разрядный DownCounter.

![tri_freq_counter_tran](/BreakingNESWiki/imgstore/apu/tri_freq_counter_tran.jpg)

![TRIANGLE_FreqCounter](/BreakingNESWiki/imgstore/apu/TRIANGLE_FreqCounter.jpg)

## Output

5-разрядный UpCounter. Старший разряд управляет направлением "пилы".

![tri_output_tran](/BreakingNESWiki/imgstore/apu/tri_output_tran.jpg)

![TRIANGLE_Output](/BreakingNESWiki/imgstore/apu/TRIANGLE_Output.jpg)
