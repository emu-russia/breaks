# Sound Generators

The APU contains the following audio channels (official designations):
- Sound A: Rectangular pulse tone generator (Square 0)
- Sound B: Rectangular pulse tone generator (Square 1)
- Sound C: Triangular tone generator
- Sound D: Noise generator
- Sound E: Channel for sample playback using delta modulation (direct playback of PCM samples is also available)

All circuits for generating sound are, for the most part, various counters controlled by simple control circuits.

![SoundGenerators](/BreakingNESWiki/imgstore/apu/SoundGenerators.jpg)

## Timing

The sound generators are clocked by the following signals:
- PHI1/2: CPU Core clock frequency
- ACLK: Audio CLK. Two times slower PHI, but with a special overlapping phase pattern
- LFO1/2: Low frequency oscillation signals (on the order of hundreds of Hertz)

The developers decided to use PHI1 for the triangle channel instead of ACLK to smooth out the "stepped" signal.

## Sweep

TBD: Description and picture.

## Envelope

TBD: Description and picture.

## Duty

TBD: Description and picture.
