# Square Channels

![apu_locator_square](/BreakingNESWiki/imgstore/apu/apu_locator_square.jpg)

The APU contains two square wave tone generators. The circuits mirror each other, so let's consider only the tone generator of the first square channel (SQUARE 0, located on the right side).

The difference between SQUARE0 and SQUARE1 is the input carry design for the adder:
- For SQUARE0, the input carry is connected to Vdd.
- For SQUARE1 the input carry is connected to the `INC` signal

Sometimes instead of Square0/Square1 we have the designation SquareA/SquareB.

![SQUARE](/BreakingNESWiki/imgstore/apu/SQUARE.jpg)

## Frequency Reg

![square_freq_in_tran](/BreakingNESWiki/imgstore/apu/square_freq_in_tran.jpg)

![SQUARE_FreqReg](/BreakingNESWiki/imgstore/apu/SQUARE_FreqReg.jpg)

![SQUARE_FreqRegBit](/BreakingNESWiki/imgstore/apu/SQUARE_FreqRegBit.jpg)

## Shift Reg

Contains the shift value for the shifter (0...7).

![square_shift_in_tran](/BreakingNESWiki/imgstore/apu/square_shift_in_tran.jpg)

![SQAURE_ShiftReg](/BreakingNESWiki/imgstore/apu/SQAURE_ShiftReg.jpg)

## Barrel Shifter

Shifts the 12-bit value to the right with the sign (the msb bit shifts to the right and fills all other bits). The most significant bit is then discarded, forming an 11-bit result.

![square_barrel_shifter_tran1](/BreakingNESWiki/imgstore/apu/square_barrel_shifter_tran1.jpg)

![square_barrel_shifter_tran2](/BreakingNESWiki/imgstore/apu/square_barrel_shifter_tran2.jpg)

![SQUARE_BarrelShifter](/BreakingNESWiki/imgstore/apu/SQUARE_BarrelShifter.jpg)

## Adder

A distinctive feature of the adder is the complementary layout of the a/b signals between the bits and the complementary carry chain, as well as the inverse polarity of the result (`#sum`) and output carry (`#COUT`).

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

The circuit is identical to the Envelope circuit in the noise generator.

![EnvelopeUnit](/BreakingNESWiki/imgstore/apu/EnvelopeUnit.jpg)

|EnvelopeUnit Signal|Square0 Channel|Square1 Channel|
|---|---|---|
|WR_Reg|W4000|W4004|
|WR_LC|W4003|W4007|
|LC|SQA/LC|SQB/LC|

## Sweep

|Signal/Group|From Where|Where To|Description|
|---|---|---|---|
|DO_SWEEP|Sweep|Freq Reg|The main signal that controls the Sweep process of the frequency value loaded in the Freq Reg. The signal is set only during PHI1, so as not to conflict with the register writes by the CPU, which only occur during PHI2.|
|SR\[2:0\], SRZ|Shift Reg|Sweep,Shifter|Determines the shift magnitude of the source frequency. If SR=0, the DO_SWEEP signal is never generated (obviously)|
|DEC (and its complement INC)|Dir Reg|Sweep,Shifter,Adder|Defines the direction of frequency step (DEC=1: frequency decreases, DEC=0: frequency increases)|
|#COUT|Adder|Sweep|Adder output carry (inverse polarity)|
|SW_OVF|Sweep|Sweep,Output|Equals 1 when INC=1 and adder output carry is active. When SW_OVF=1 - DO_SWEEP is 0. That is the Sweep process does not happen at frequency overflow (obviously)|
|SW_UVF|Adder|Sweep,Output|1: Frequency value is less than 4 (Freq Reg bits \[10:2\] are zeros). When SW_UVF=1 - DO_SWEEP is 0. That is, when the frequency is too low it makes no sense to do Sweep|
|NOSQ|Length Counter|Common|1: The length counter has finished counting/deactivated. When the length counter is disabled the DO_SWEEP signal is never generated (obviously)|
|/LFO2|SoftCLK|Common|Low-frequency oscillation signal (inverse polarity). When applied to Sweep - it resets the Sweep counter with a value from the Sweep Reg|
|SCO|Sweep|Sweep|Sweep Counter output carry. While Sweep Counter is counting - DO_SWEEP is 0|
|SWRELOAD|Sweep|Sweep|1: Perform a Sweep Counter restart|
|SWDIS|Register WR1\[3\]|Sweep|1: Disable Sweep process, DO_SWEEP is always 0|

By carefully examining and understanding all the signals that are used in the Sweep Unit you can get a picture of what is going on:
- The main driver of the Sweep process is the DO_SWEEP signal. When this signal is activated the frequency modulation process in the Freq Reg is started using the shift register and the adder
- The Sweep counter iterates with the low frequency oscillation signal `/LFO2`
- The Sweep counter is overloaded by itself with the value from the Sweep Reg register, at the same time the DO_SWEEP signal is triggered (if all conditions are met, see below)

Sweep does NOT occur under the following conditions (in the schematic it is a large NOR):
- Sweep is disabled by the appropriate control register (SWDIS)
- A square channel length counter has finished counting or has been disabled (NOSQ)
- The magnitude value of the Shift Reg is 0 (SRZ)
- Frequency value led to an overflow of the adder, in the frequency increase mode (SW_OVF)
- Frequency value is less than 4 (SW_UVF)
- Sweep counter has not completed its work (SCO=0)
- Low-frequency oscillation signal is not active (/LFO2=1)

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

Principle of operation:
- The FLOAD signal used to load the frequency counter is simultaneously used to iterate the Duty counter
- Loading the length counter clears the Duty counter of the corresponding square channel
- Frequency counter output carry (FCO signal) is the input carry for the Duty counter
- When the `DUTY` signal is 0 at the output of the square generator is also 0

Table of DUTY signal values depending on Duty counter values and Duty register settings (d):

|Duty counter value|d=0 (12.5%)|d=1 (25%)|d=2 (50%)|d=3 (75%)|
|---|---|---|---|---|
|7|1|1|1|0|
|6|0|1|1|0|
|5|0|0|1|1|
|4|0|0|1|1|
|3|0|0|0|1|
|2|0|0|0|1|
|1|0|0|0|1|
|0|0|0|0|1|

## Output

![square_output_tran](/BreakingNESWiki/imgstore/apu/square_output_tran.jpg)

![SQUARE_Output](/BreakingNESWiki/imgstore/apu/SQUARE_Output.jpg)
