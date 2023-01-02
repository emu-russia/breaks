# Common elements of APU circuitry

This section describes APU modules that are used relatively often in different units.

## Register Bit

The register bit:

![RegisterBit_tran](/BreakingNESWiki/imgstore/apu/RegisterBit_tran.jpg)

![RegisterBit](/BreakingNESWiki/imgstore/apu/RegisterBit.jpg)

Used in:
- IO Ports ($4016)
- SoftCLK Regs ($4017)
- Square 0/1 Freq Regs ($4002/$4003, $4006/$4007)
- Square 0/1 Shift/Control Reg ($4001, $4005)
- Square 0/1 Volume/Control Reg ($4000, $4004)
- Triangle Reg ($4008)
- Noise Regs ($400C, $400E)
- Noise Random LFSR
- DPCM Regs ($4010, $4012, $4013)
- DPCM Sample Buffer
- SPR DMA Address (high bits)

## Up Counter

The bit of the `up` counter:

![CounterBit_tran](/BreakingNESWiki/imgstore/apu/CounterBit_tran.jpg)

![CounterBit](/BreakingNESWiki/imgstore/apu/CounterBit.jpg)

Used in:
- Triangle Output
- DPCM Sample Bit Counter
- DPCM Address Counter
- SPR DMA Address (low bits)

## Down Counter

The bit of the `down` counter:

![DownCounterBit_tran](/BreakingNESWiki/imgstore/apu/DownCounterBit_tran.jpg)

![DownCounterBit](/BreakingNESWiki/imgstore/apu/DownCounterBit.jpg)

Used in:
- Length Counters
- Square 0/1 Freq Counter
- Square 0/1 Envelope
- Square 0/1 Sweep
- Square 0/1 Duty
- Triangle Linear Counter
- Triangle Freq Counter
- Noise Envelope
- Noise Output
- DPCM Sample Counter

## Reversible (Up/Down) Counter

The bit of the `reversible` counter:

![RevCounterBit_tran](/BreakingNESWiki/imgstore/apu/RevCounterBit_tran.jpg)

![RevCounterBit](/BreakingNESWiki/imgstore/apu/RevCounterBit.jpg)

Used in:
- DPCM Output
