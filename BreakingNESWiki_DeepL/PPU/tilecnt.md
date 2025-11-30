# Tile Counters

![ppu_locator_tilecnt](/BreakingNESWiki/imgstore/ppu/ppu_locator_tilecnt.jpg)

![TileCounters_All](/BreakingNESWiki/imgstore/ppu/TileCounters_All.png)

Tile counters are an entity commonly referred to as `v` in the nesdev community.

The output of tile counters are `AT_ADR` and `NT_ADR`, which are the address sources for the resulting [PPU Address Mux](pamux.md).

Counter operating modes:

|Counter|Bits|Max value|Max value (Blank)|Input carry source|Input carry source (Blank)|Counter reset source|Carry output|Carry output (Blank)|
|---|---|---|---|---|---|---|---|---|
|Tile Horizontal|5	|32	|32	|!(BLNK & I1/32)		|!(BLNK & I1/32)		|none					|yes	|yes|
|Tile Vertical	|5	|30	|32	|Fine Vertical CNT		|Tile Horizontal CNT	|carry TVZ + 1 TVSTEP	|yes	|yes|
|Name Table H	|1	|2	|2	|Tile Horizontal CNT	|Tile Vertical CNT		|none					|no		|yes|
|Name Table V	|1	|2	|2	|Tile Vertical CNT		|Name Table H  CNT		|none					|no		|yes|
|Fine Vertical	|3	|8	|8	|Tile Horizontal CNT	|Name Table V  CNT		|none					|yes	|no|

## Tile Counters Control

![ppu_tile_counters_control_top](/BreakingNESWiki/imgstore/ppu/ppu_tile_counters_control_top.jpg)

![ppu_tile_counters_control_bot](/BreakingNESWiki/imgstore/ppu/ppu_tile_counters_control_bot.jpg)

![TileCountersControl](/BreakingNESWiki/imgstore/ppu/TileCountersControl.png)

![TileCountersControl2](/BreakingNESWiki/imgstore/ppu/TileCountersControl2.png)

## Counter Bit

![TileCounterBit](/BreakingNESWiki/imgstore/ppu/TileCounterBit.png)

A reset variation is used for the TV counter:

![TileCounterBitReset](/BreakingNESWiki/imgstore/ppu/TileCounterBitReset.png)

## FV Counter

![ppu_tile_counters_fv](/BreakingNESWiki/imgstore/ppu/ppu_tile_counters_fv.jpg)

![Tile_FVCounter](/BreakingNESWiki/imgstore/ppu/Tile_FVCounter.png)

## NT Counters

![ppu_tile_counters_nt](/BreakingNESWiki/imgstore/ppu/ppu_tile_counters_nt.jpg)

![Tile_NTCounters](/BreakingNESWiki/imgstore/ppu/Tile_NTCounters.png)

## TV Counter

![ppu_tile_counters_tv](/BreakingNESWiki/imgstore/ppu/ppu_tile_counters_tv.jpg)

![Tile_TVCounter](/BreakingNESWiki/imgstore/ppu/Tile_TVCounter.png)

Note the tricky `0/TV` signal. This signal clears not only the contents of the counter's input FF on the Keep phase, but also makes a pulldown on its output value, but NOT the complementary output.

## TH Counter

![ppu_tile_counters_th](/BreakingNESWiki/imgstore/ppu/ppu_tile_counters_th.jpg)

![Tile_THCounter](/BreakingNESWiki/imgstore/ppu/Tile_THCounter.png)