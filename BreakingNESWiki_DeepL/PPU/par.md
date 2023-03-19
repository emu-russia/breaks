# Picture Address Register

![ppu_locator_par](/BreakingNESWiki/imgstore/ppu/ppu_locator_par.jpg)

![PAR_All](/BreakingNESWiki/imgstore/ppu/PAR_All.png)

The PAR address register stores the value for the external address bus (`/PA0-13`) (14 bit).

Sources for writing to the PAR:
- A pattern address (`PAD0-12`) (13 bit)
- The value from the data bus (`DB0-7`) (8 bit)
- The value from the PAR counters which are also part of this circuit. The PAR counters are loaded from the scrolling registers.

## PAR Counters

Counter operating modes:

|Counter|Bits|Max value|Max value (Blank)|Input carry source|Input carry source (Blank)|Counter reset source|Carry output|Carry output (Blank)|
|---|---|---|---|---|---|---|---|---|
|Tile Horizontal|5	|32	|32	|!(BLNK & I1/32)		|!(BLNK & I1/32)		|none					|yes	|yes|
|Tile Vertical	|5	|30	|32	|Fine Vertical CNT		|Tile Horizontal CNT	|carry TVZ + 1 TVSTEP	|yes	|yes|
|Name Table H	|1	|2	|2	|Tile Horizontal CNT	|Tile Vertical CNT		|none					|no		|yes|
|Name Table V	|1	|2	|2	|Tile Vertical CNT		|Name Table H  CNT		|none					|no		|yes|
|Fine Vertical	|3	|8	|8	|Tile Horizontal CNT	|Name Table V  CNT		|none					|yes	|no|

### PAR Counters Control

![ppu_dataread_par_counters_control_top](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_control_top.jpg)

![ppu_dataread_par_counters_control_bot](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_control_bot.jpg)

![PAR_CountersControl](/BreakingNESWiki/imgstore/ppu/PAR_CountersControl.png)

![PAR_CountersControl2](/BreakingNESWiki/imgstore/ppu/PAR_CountersControl2.png)

### Counter Bit

![PAR_CounterBit](/BreakingNESWiki/imgstore/ppu/PAR_CounterBit.png)

A reset variation is used for the TV counter:

![PAR_CounterBitReset](/BreakingNESWiki/imgstore/ppu/PAR_CounterBitReset.png)

### FV Counter

![ppu_dataread_par_counters_fv](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_fv.jpg)

![PAR_FVCounter](/BreakingNESWiki/imgstore/ppu/PAR_FVCounter.png)

### NT Counters

![ppu_dataread_par_counters_nt](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_nt.jpg)

![PAR_NTCounters](/BreakingNESWiki/imgstore/ppu/PAR_NTCounters.png)

### TV Counter

![ppu_dataread_par_counters_tv](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_tv.jpg)

![PAR_TVCounter](/BreakingNESWiki/imgstore/ppu/PAR_TVCounter.png)

Note the tricky `0/TV` signal. This signal clears not only the contents of the counter's input FF on the Keep phase, but also makes a pulldown on its output value, but NOT the complementary output.

### TH Counter

![ppu_dataread_par_counters_th](/BreakingNESWiki/imgstore/ppu/ppu_par_counters_th.jpg)

![PAR_THCounter](/BreakingNESWiki/imgstore/ppu/PAR_THCounter.png)

## PAR

![PAR](/BreakingNESWiki/imgstore/ppu/PAR.png)

The circuit looks a bit scary, this is because of the large number of input sources to load into the PAR register bits.

### PAR Control

The control circuit is designed to select one of the sources for writing to PAR.

![ppu_dataread_par_control](/BreakingNESWiki/imgstore/ppu/ppu_par_control.jpg)

![PAR_Control](/BreakingNESWiki/imgstore/ppu/PAR_Control.png)

### PAR Outputs

![ppu_dataread_par_low](/BreakingNESWiki/imgstore/ppu/ppu_par_low.jpg)

![ppu_dataread_par_high](/BreakingNESWiki/imgstore/ppu/ppu_par_high.jpg)

![PAR_LowBit](/BreakingNESWiki/imgstore/ppu/PAR_LowBit.png)

![PAR_HighBit](/BreakingNESWiki/imgstore/ppu/PAR_HighBit.png)
