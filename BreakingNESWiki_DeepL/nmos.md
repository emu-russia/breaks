# NMOS

## DFF

![D Flip-Flop](/BreakingNESWiki/imgstore/nmos/DFF.png)

## Multiplexed Transparent Latch

![PlexedTranspLatch](/BreakingNESWiki/imgstore/nmos/PlexedTranspLatch.png)

This element acts as a switch-case construct in C++ terminology.

A group of Pass-gate transistors with a common output forms a chained multiplexer whose output is a Transparent D-Latch.

Normally the circuit is built in such a way that the selecting inputs are single-ended (only one of them can take value `1`).

If all selective inputs are closed - the last value from the multiplexer chain is stored on the latch.

Designs of this kind are widely used in counters.

## NXOR

![NXOR](/BreakingNESWiki/imgstore/nmos/NXOR.png)

## Counter Bit

![NMOS_CounterBit](/BreakingNESWiki/imgstore/nmos/NMOS_CounterBit.png)

## AOI

And-Or-Inverted:

![AOI](/BreakingNESWiki/imgstore/nmos/AOI.png)

## OAI

Or-And-Inverted:

![OAI](/BreakingNESWiki/imgstore/nmos/OAI.png)
