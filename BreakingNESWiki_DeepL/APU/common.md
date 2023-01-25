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
- OAM DMA Address (high bits)

## Counters

|Counter name|Counter direction|Bit depth|Counter reset|Output carry|Output value|
|---|---|---|---|---|---|
|Square Sweep|Down|3|yes|yes|no|
|Square Freq|Down|11|yes|yes|no|
|Square Duty|Down|3|yes or W4003(7)|no|yes|
|Square Decay|Down|4|yes|yes|no|
|Square Envelope|Down|4|yes|yes|yes|
|Triangle Freq|Down|11|yes|yes|no|
|Triangle Linear|Down|7|yes|yes|no|
|Triangle Output|Up|5|yes|no|yes|
|Noise Decay|Down|4|yes|yes|no|
|Noise Envelope|Down|4|yes|yes|yes|
|DPCM Address|Up|15|yes|no|yes|
|DPCM Sample bit|Up|3|yes|yes|no|
|DPCM Sample length|Down|12|yes|yes|no|
|DPCM Output|Reversible|6|yes|yes|yes|
|OAM DMA (low bits)|Up|8|yes or W4014|yes|yes|
|Length|Down|8|yes|yes|no|

### Up Counter

The bit of the `up` counter:

![CounterBit_tran](/BreakingNESWiki/imgstore/apu/CounterBit_tran.jpg)

![CounterBit](/BreakingNESWiki/imgstore/apu/CounterBit.jpg)

### Down Counter

The bit of the `down` counter:

![DownCounterBit_tran](/BreakingNESWiki/imgstore/apu/DownCounterBit_tran.jpg)

![DownCounterBit](/BreakingNESWiki/imgstore/apu/DownCounterBit.jpg)

### Reversible (Up/Down) Counter

The bit of the `reversible` counter:

![RevCounterBit_tran](/BreakingNESWiki/imgstore/apu/RevCounterBit_tran.jpg)

![RevCounterBit](/BreakingNESWiki/imgstore/apu/RevCounterBit.jpg)
