# H/V Control Logic

The H/V logic is a finite state machine (FSM) that controls all other PPU parts. Schematically it is just a set of latches, like "this latch is active from 64th to 128th pixel", so the corresponding control line coming from this latch is also active.

## HPos Logic

"Horizontal" logic, responsible for generating control lines depending on the horizontal position of the beam (H):

<img src="/BreakingNESWiki/imgstore/7fc48a229053d2cf091195ec01a345ce.jpg" width="1000px">

## VPos Logic

TBD.

## Cleaning H/V Counters

TBD.

## ODD/EVEN Logic

![odd_1](/BreakingNESWiki/imgstore/5c4d95b2bf506ef6b183cf8bb46e9433.jpg) ![odd_2](/BreakingNESWiki/imgstore/e4220e0351932b00026250fc2f3c858a.jpg) ![odd_3](/BreakingNESWiki/imgstore/e7d09137ee29ae53340df1cb2285585f.jpg)

The ODD/EVEN logic consists of two closed to each other pseudo latches controlled by two multiplexers. This results in a very clever "macro" latch.

TODO: The schematic should be analyzed again, because what the hell is this "macro-latch"... In addition, the scheme for PAL PPU is different from the NTSC version.
