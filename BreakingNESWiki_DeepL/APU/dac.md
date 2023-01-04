# DAC

![apu_locator_dac](/BreakingNESWiki/imgstore/apu/apu_locator_dac.jpg)

The DAC does not use separate pins for "analog" VDD/GND, but uses common VDD/GND. The DAC power supply is wired in a star topology.

@ttlworks made a good description of the DAC:

![APU_2_dacs](/BreakingNESWiki/imgstore/apu/ttlworks/APU_2_dacs.png)

Source: http://forum.6502.org/viewtopic.php?p=94693#p94693

## AUX A/B Terminals

Inside the microcircuit the pads for the terminals are not loaded in any way and are just pads.

Outside on the board there are usually small pull-down resistors to GND (usually 100 ohms on each AUX output).

## Square 0/1

![dac_square_tran](/BreakingNESWiki/imgstore/apu/dac_square_tran.jpg)

Maximum amplitude measurements of DAC AUX A:
- RP2A03G chip
- External resistance 75 Ohm (unusual, but does not affect the essence of what is happening much)
- The dac_square.nes demo was used (https://github.com/bbbradsmith/nes-audio-tests)
- SQA = 0xf, SQB = 0xf

![dac_auxa_max](/BreakingNESWiki/imgstore/apu/waves/dac_auxa_max.jpg)

Results:
- Maximum AUX A voltage: 272 mV
- You can see that the lower level also has a small voltage relative to ground (the moment is controversial, because the probe can introduce its own distortions)

Credits: @HardWareMan

## Triangle/Noise/DPCM

![dac_other_tran](/BreakingNESWiki/imgstore/apu/dac_other_tran.jpg)

TBD.
