# Features of Famiclone Chips

This section contains a description of the distinguishing features (which are sometimes essentially bugs) of well-known famiclone chips.

## Historical Background

Studying which chip factories existed in the early 90's in China/Taiwan, the following hypothesis can be made:

- Chips marked UM were produced in UMC factories (this is obvious since there are markings on the chips)
- Chips marked "MG" are relabeled UMC chips
- Chips labeled "HA" have not been investigated
- Chips marked TA/T/1818 were supposedly produced at TSMC Fab1 factory (https://anysilicon.com/history-and-milestones-of-tsmc/). No other "T" factory can be found. These chips have a different topology mask than UMC chips.

https://en.wikipedia.org/wiki/List_of_semiconductor_fabrication_plants

At the beginning the CPU/PPU were separate chips. Then they began to move towards integration: first there were NOACs without integrated memory, and then the WRAM/VRAM memory moved inside the NOAC.

## Summary Table

|Chip revision|Manufacturer|Year|Type|Distinguishing features|
|---|---|---|---|---|
|UA6527	|UMC	|no	|CPU	|The 25% and 50% duty cycle on both squares are reversed. Rich frequency response, juicier bass and treble compared to the originals.|
|UA6528	|UMC	|no	|PPU	|unknown|
|UA6540	|UMC	|no	|CPU	|The 25% and 50% duty cycle on both squares are reversed. Rich frequency response, juicier bass and treble compared to the originals.|
|UA6541	|UMC	|no	|PPU	|Red/Green emphasis bits are mixed up as in the official 2C07. Output levels are brighter than the official PAL|
|UA6527P	|UMC	|no	|CPU	|The 25% and 50% duty cycle on both squares are reversed. Rich frequency response, juicier bass and treble compared to the originals.|
|UA6538	|UMC	|no	|PPU	|Red/Green emphasis bits are mixed up as in the official 2C07. Output levels are brighter than the official PAL|
|UM6561	Family. F - in packages. H and T - in blobs|||||
|UM6561F-1	|UMC	|no	|FullNOAC	|Duty Cycle OK. Triangle clicks. Emphasis bits are brighter than needed (no idea if they are mixed up), so they darken more when all three are on.|
|UM6561AF-1	|UMC	|no	|FullNOAC	|Prince of Persia is wildly glitchy. The rest is like F and requires further study.|
|UM6561BF-1	|UMC	|no	|FullNOAC	|unknown.  On the forums they say that there are problems with DPCM, but this information is not verified|
|UM6561CF-1	|UMC	|no	|FullNOAC	|unknown.  On the forums they say that there are problems with DPCM, but this information is not verified|
|UM6561F-2	|UMC	|no	|FullNOAC	|Duty Cycle OK. Triangle clicks. Emphasis bits are brighter than needed (no idea if they are mixed up), so they darken more when all three are on.|
|UM6561AF-2	|UMC	|no	|FullNOAC	|Prince of Persia is wildly glitchy. The rest is like F and requires further study.|
|UM6561BF-2	|UMC	|no	|FullNOAC	|unknown.  On the forums they say that there are problems with DPCM, but this information is not verified|
|UM6561CF-2	|UMC	|no	|FullNOAC	|unknown.  On the forums they say that there are problems with DPCM, but this information is not verified|
|UM6561H	|UMC	|no	|FullNOAC	|Blobs are unexplored. Some may switch between NTSC and Dendy when changing the quartz and manipulating the pins|
|UM6561BH	|UMC	|no	|FullNOAC	|Blobs are unexplored. Some may switch between NTSC and Dendy when changing the quartz and manipulating the pins|
|UM6561T	|UMC	|no	|FullNOAC	|Blobs are unexplored. Some may switch between NTSC and Dendy when changing the quartz and manipulating the pins|
|T|||||
|T1818P	|unknown	|no	|PartialNOAC	|Partial Nes-On-A-Chip (NoAC), requires 2kb+2kb external RAM. Duty cycle mixed up, emphasis mixed up and darker. Triangle clicks. Frequency response is shit, bass is clunked, even if you bypass the internal Op-Amp.|
|1818P	|unknown	|no	|PartialNOAC	|the differences between 1818P and T1818P are unknown|
|TA|||||
|TA-03NP1 6527P	|TA	|no	|CPU	|Duty Cycle OK. DPCM can be problematic depending on the specimen. Frequency response is worse than UA6527x, but in general the chip is fine.|
|TA-02NP 6538	|TA	|no	|PPU	|Emphasis bits are mixed up like in all other PAL and Dendy, but NOT overshoot like in most NOACs. Signal levels are lower than UA65xx, and closer to the official|
|TA-03N	|TA	|no	|CPU	|unknown|
|TA-02N	|TA	|no	|PPU	|unknown|
|TA-02NPB	|TA	|no	|PPU	|unknown|
|TA-02NPB1	|TA	|no	|PPU	|unknown|
|MG|||||	
|MG-P-501	|MicroGenius	|no	|CPU|See UA6527P: in visual, audio and organoleptic tests - all the same|
|MG-P-502	|MicroGenius	|no	|PPU|See UA6538: in visual, sound and organoleptic tests - all the same|
|HA|||||
|HA6527P	|Haili?	|no	|CPU	|See UA6527P: in visual, audio and organoleptic tests - all the same|
|HA6538	|Haili?	|no	|PPU	|See UA6538: in visual, sound and organoleptic tests - all the same|

Credits: @eugene-nes

## Chip Features

By "features" you mean some unique solution for the famiclone chip, often in fact a bug. Where the APU and PPU are combined in NoAC, respectively, we can say that the specified features are features of the NoAC chip as a whole

List of known features of APU chips:
- Main quartz frequency
- CLK divider coefficient
- Incorrect DPCM decoder
- Wrong square channel duty cycle
- Clicking triangle channel generator
- Noise generator malfunction, most likely related to the corresponding decoder
- BCD correction circuit of the 6502 core ALU is still enabled
- Debug registers (2A03), pin30
- 6502 Core halt support (2C07), pin30

List of known features of PPU chips:
- Frequency of the main quartz (if a separate quartz is used for the PPU)
- PCLK divider similar to 2C02 (NTSC PPU)
- PCLK divider similar to 2C07 (PAL PPU)
- H/V decoder similar to 2C02 (NTSC PPU)
- H/V decoder similar to 2C07 (PAL PPU)
- Unusual H/V decoder with delayed VBlank (UMC)
- Unusual H/V decoder, still unexplored (TA)
- Extended Chroma decoder to support phase alteration (2C07)
- Delayed #PICTURE signal (2C07)
- Delayed BLACK signal (Rendering Disabled) (2C07)
- Special BLNK signal processing in OAM Eval (2C07)
- Write delay in $2003 (2C07)
- Emphasis bits mixed up (2C07)
- DAC similar to Ricoh PPU
- DAC of its own topology (TA)
- DAC with excessive saturation (most likely due to incorrect calculations in the chip area) (UMC)

See the APU/PPU sections on the Wiki for a more detailed comparison of the schematics of the respective chips.

See also:
- https://www.nesdev.org/wiki/CPU_variants
- https://www.nesdev.org/wiki/PPU_variants
- https://forums.nesdev.org/viewtopic.php?t=23916
