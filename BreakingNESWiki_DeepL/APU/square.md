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

![square_shift_in_tran](/BreakingNESWiki/imgstore/apu/square_shift_in_tran.jpg)

![SQAURE_ShiftReg](/BreakingNESWiki/imgstore/apu/SQAURE_ShiftReg.jpg)

## Barrel Shifter

![square_barrel_shifter_tran1](/BreakingNESWiki/imgstore/apu/square_barrel_shifter_tran1.jpg)

![square_barrel_shifter_tran2](/BreakingNESWiki/imgstore/apu/square_barrel_shifter_tran2.jpg)

![SQUARE_BarrelShifter](/BreakingNESWiki/imgstore/apu/SQUARE_BarrelShifter.jpg)

## Adder

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

## Output

![square_output_tran](/BreakingNESWiki/imgstore/apu/square_output_tran.jpg)

![SQUARE_Output](/BreakingNESWiki/imgstore/apu/SQUARE_Output.jpg)
