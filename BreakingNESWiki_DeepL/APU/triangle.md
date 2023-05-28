# Triangle Channel

![apu_locator_triangle](/BreakingNESWiki/imgstore/apu/apu_locator_triangle.jpg)

![TRIANGLE](/BreakingNESWiki/imgstore/apu/TRIANGLE.jpg)

## Signals

|Signal|Description|
|---|---|
|/LFO1|Low-frequency oscillation signal 1/4 period (inverse polarity)|
|NOTRI|Triangle LC does not count / is disabled|
|TRI/LC|Input carry for Triangle LC|
|TCO|Output carry from a Linear Counter|
|FOUT|Output carry from Frequency Counter|
|TLOAD|Load Linear Counter|
|TSTEP|Step Frequency Counter|
|FLOAD|Load Frequency Counter|
|FSTEP|Step Frequency Counter|
|TTSTEP|Step Output Counter|

The developers decided to use PHI1 for the triangular channel in some places instead of ACLK to smooth out the "stepped" signal.

## Triangle Control

![tri_linear_counter_control_tran1](/BreakingNESWiki/imgstore/apu/tri_linear_counter_control_tran1.jpg)

![tri_linear_counter_control_tran2](/BreakingNESWiki/imgstore/apu/tri_linear_counter_control_tran2.jpg)

![tri_freq_counter_control_tran](/BreakingNESWiki/imgstore/apu/tri_freq_counter_control_tran.jpg)

![TRIANGLE_Control](/BreakingNESWiki/imgstore/apu/TRIANGLE_Control.jpg)

## Linear Counter

7-bit DownCounter.

![tri_linear_counter_tran](/BreakingNESWiki/imgstore/apu/tri_linear_counter_tran.jpg)

![TRIANGLE_LinearCounter](/BreakingNESWiki/imgstore/apu/TRIANGLE_LinearCounter.jpg)

## Frequency Counter

11-bit DownCounter.

![tri_freq_counter_tran](/BreakingNESWiki/imgstore/apu/tri_freq_counter_tran.jpg)

![TRIANGLE_FreqCounter](/BreakingNESWiki/imgstore/apu/TRIANGLE_FreqCounter.jpg)

## Output

5-bit UpCounter. The most significant bit controls the direction of the "saw".

![tri_output_tran](/BreakingNESWiki/imgstore/apu/tri_output_tran.jpg)

![TRIANGLE_Output](/BreakingNESWiki/imgstore/apu/TRIANGLE_Output.jpg)
