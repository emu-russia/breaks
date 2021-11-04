# VRAM Controller

The circuitry is the "auxiliary brain" of the bottom of the PPU to control the VRAM interface.

In addition, the controller also includes a READ BUFFER (RB), an intermediate data storage for exchange with VRAM.

## Transistor Circuit

<img src="/BreakingNESWiki/imgstore/vram_control_tran.jpg" width="1000px">

Anatomically the circuit is divided into 2 large halves, the left one is more connected to the WR_internal control signal and the right one to the RD_internal.
Each half includes an RS trigger and a delay line that automatically sets the trigger.

The circuit outputs a number of control lines to the outside:
- RD (RD_internal): to /RD output
- WR (WR_internal): to /WR output
- /ALE: to the ALE output (ALE=1 when the AD bus works as an address bus, ALE=0 when AD works as a data bus)
- TSTEP: to the DATAREAD circuit, allows TV/TH counters to perform incremental
- DB/PAR: on the DATAREAD circuit, connects the internal PPU DB bus to the PAR (PPU address register) pseudo register
- PD/RB: connects the external PPU bus to a read buffer to load a new value into it
- TH/MUX: preliminary name. Connects the TH register to the MUX output, causing the value to go to the color-buffer and presumably to the palette.
- XRB: enable tri-state logic that disconnects the PPU read buffer from the internal data bus.

## Logic

<img src="/BreakingNESWiki/imgstore/vram_control_logisim.jpg" width="1000px">

To say something more specific, you need to first examine the rest of the PPU parts.

TBD.

## PAL PPU Difference

No differences in the circuit were found.

<img src="/BreakingNESWiki/imgstore/vram_ctrl_pal.jpg" width="1000px">

The surface of the chip in this area was a little dirty, but I marked all the key control lines, so there is no doubt that the circuit is identical to the NTSC PPU.

## Read Buffer (RB)

Located to the right of [OAM FIFO](fifo.md).

![ppu_readbuffer](/BreakingNESWiki/imgstore/ppu_readbuffer.jpg)

![ppu_logisim_rb](/BreakingNESWiki/imgstore/ppu_logisim_rb.jpg)

## Simulation

TBD.
