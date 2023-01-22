# Sound Generators

The APU contains the following audio channels (official designations):
- Sound A: Rectangular pulse tone generator (Square 0)
- Sound B: Rectangular pulse tone generator (Square 1)
- Sound C: Triangular tone generator
- Sound D: Noise generator
- Sound E: Channel for sample playback using delta modulation (direct playback of PCM samples is also available)

All circuits for generating sound are, for the most part, various counters controlled by simple control circuits.

![SoundGenerators](/BreakingNESWiki/imgstore/apu/SoundGenerators.jpg)

(In addition to the audio generators themselves, the diagram also shows the OAM DMA, as it interacts closely with the DPCM DMA).

## Timing

The sound generators are clocked by the following signals:
- PHI1/2: CPU Core clock frequency
- ACLK: Audio CLK. Two times slower PHI, but with a special overlapping phase pattern
- LFO1/2: Low frequency oscillation signals (on the order of hundreds of Hertz)

The developers decided to use PHI1 for the triangle channel instead of ACLK to smooth out the "stepped" signal.

## Sweep

Sweep is a time-constant increase or decrease in signal frequency (period). It affects pitch (tonality).

The word `Sweep` does not translate into other languages.

In APU it is used only in square channels.

![wave_sweep](/BreakingNESWiki/imgstore/apu/wave_sweep.png)

## Envelope

Envelope is the constant fading of the signal amplitude (as applied to APU audio generators).

Envelope is a special case of ADSR envelope, and specifically is a Decay component.

In APU it is used in square channels and noise generator.

![wave_envelope](/BreakingNESWiki/imgstore/apu/wave_envelope.png)

## Duty

Duty is a change in the duty cycle of a square wave signal.

In APU it is used only in square channels.

![wave_duty](/BreakingNESWiki/imgstore/apu/wave_duty.png)
