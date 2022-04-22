# Picture Address Register

![ppu_locator_par](/BreakingNESWiki/imgstore/ppu/ppu_locator_par.jpg)

## PAR Counters

Counter operating modes:

|Counter|Bits|Max value|Max value (Blank)|Input carry source|Input carry source (Blank)|Counter reset source|Carry output|Carry output (Blank)|
|---|---|---|---|---|---|---|---|---|
|Tile Horizontal|5	|32	|32	|!(BLNK & I1/32)		|!(BLNK & I1/32)		|none					|yes	|yes|
|Tile Vertical	|5	|30	|32	|Fine Vertical CNT		|Tile Horizontal CNT	|carry TVZB + 1 TVSTEP	|yes	|yes|
|Name Table H	|1	|2	|2	|Tile Horizontal CNT	|Tile Vertical CNT		|none					|no		|yes|
|Name Table V	|1	|2	|2	|Tile Vertical CNT		|Name Table H  CNT		|none					|no		|yes|
|Fine Vertical	|3	|8	|8	|Tile Horizontal CNT	|Name Table V  CNT		|none					|yes	|no|

### PAR Counters Control

![ppu_dataread_par_counters_control_top](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_control_top.jpg)

![ppu_dataread_par_counters_control_bot](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_control_bot.jpg)

### FV Counter

![ppu_dataread_par_counters_fv](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_fv.jpg)

### NT Counters

![ppu_dataread_par_counters_nt](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_nt.jpg)

### TV Counter

![ppu_dataread_par_counters_tv](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_tv.jpg)

### TH Counter

![ppu_dataread_par_counters_th](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_th.jpg)

## PAR

### PAR Control

![ppu_dataread_par_control](/BreakingNESWiki/imgstore/ppu/ppu_par_control.jpg)

### PAR Outputs

![ppu_dataread_par_low](/BreakingNESWiki/imgstore/ppu/ppu_par_low.jpg)

![ppu_dataread_par_high](/BreakingNESWiki/imgstore/ppu/ppu_par_high.jpg)

## Logisim Circuit

For now in this version, then we will saw into pieces, for easy perception:

<img src="/BreakingNESWiki/imgstore/ppu_logisim_pargen.jpg" width="1000px">
