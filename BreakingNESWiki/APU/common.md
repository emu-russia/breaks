# Общие элементы схемотехники APU

В данном разделе описаны модули APU, которые используются относительно часто в разных блоках.

## Register Bit

Разряд регистра:

![RegisterBit_tran](/BreakingNESWiki/imgstore/apu/RegisterBit_tran.jpg)

![RegisterBit](/BreakingNESWiki/imgstore/apu/RegisterBit.jpg)

Где применяется:
- IO Ports ($4016)
- SoftCLK Regs ($4017)
- Square 0/1 Freq Regs ($4002/$4003, $4006/$4007)
- Square 0/1 Shift/Control Reg ($4001, $4005)
- Square 0/1 Volume/Control Reg ($4000, $4004)
- Triangle Reg ($4008)
- Noise Regs ($400C, $400E)
- DPCM Regs ($4010, $4012, $4013)
- DPCM Sample Buffer

## Up Counter

Разряд прямого счётчика:

![CounterBit_tran](/BreakingNESWiki/imgstore/apu/CounterBit_tran.jpg)

![CounterBit](/BreakingNESWiki/imgstore/apu/CounterBit.jpg)

Где применяется:
- Triangle Output
- DPCM Sample Bit Counter
- DPCM Address Counter
- SPR DMA Address (младшие разряды)

## Down Counter

Разряд обратного счётчика:

![DownCounterBit_tran](/BreakingNESWiki/imgstore/apu/DownCounterBit_tran.jpg)

![DownCounterBit](/BreakingNESWiki/imgstore/apu/DownCounterBit.jpg)

Где применяется:
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

Разряд реверсивного счётчика:

![RevCounterBit_tran](/BreakingNESWiki/imgstore/apu/RevCounterBit_tran.jpg)

![RevCounterBit](/BreakingNESWiki/imgstore/apu/RevCounterBit.jpg)

Где применяется:
- Выходное значение DPCM
