# PAL PPU

This section describes the differences in schematics between the PAL PPU version (RP2C07) and the reference NTSC PPU (RP2C02).

## FSM

Found differences from NTSC PPU:

- Significantly different EVEN/ODD circuitry (located to the right of the V PLA). The signal to the sprite logic is not yet clear from this circuit
- Slightly different logic for clearing H/V counters
- Bit V0 for the phase generator comes out of the VCounter (see VideoOut schematic)
- BLACK and PICTURE signals are processed in a special way for PAL (with slight differences)
- H/V Decoders are also different (see [Decoders](hv_dec.md))

All other parts (Horizontal and vertical FSM logic, register selection circuit, H/V counters) are the same as NTSC PPU.

## Video Out

Of the notable differences from the NTSC version of the PPU:

- The color decoder is twice as big (due to the peculiarity of the PAL phase alteration)
- In addition, the V0 bit from the VCounter comes on the decoder to determine the parity of the current line (for phase alteration)
- The phase shifter is matched to a doubled decoder
- The PICTURE signal undergoes additional processing (DLATCH delay)
- DAC, Emphasis and Luma Decoder circuits are the same as NTSC

## Regs

Also found additional logic for processing the `BLACK` control signal ("rendering disabled").

Of the notable differences:

- The `/SLAVE` signal goes through 2 additional inverters for amplification
- The B/W signal goes by roundabout ways through the multiplexer
- The two signals O8/16 and I1/32 are output in inverse logic (there are additional inverters for them in the Data Reader)
- Additionally, the BLACK signal processing logic is screwed on
- The output of the VBL control signal is slightly different (an additional cutoff transistor is used which is not present in the NTSC PPU)

## Sprite Logic

In general, the differences are minimal, but there are nuances. All differences are marked with an exclamation mark.

- No changes were found in the comparator logic.
- There is only one small change in the comparison control circuit (the lowest one), related to the fact that the signal O8/16 in PAL PPU is already in inverse logic, so an inverter is not required for it
- The counter digit circuits (OAM Counter and OAM2 Counter) are modified so that there is no inverter on the output. Therefore, the outputs (index to access the OAM memory) are in forward logic (`OAM0-7`) and not in inverse logic as in the NTSC PPU (`/OAM0-7`)
- The BLNK signal processing circuit (located just above the OAM2 Counter) is different
- The control circuit of OAM Counter for the control signal `OMSTEP` is additionally modified by the signal `ZOMG_PAL`, which comes from the EVEN/ODD circuit (this circuit is to the right of V PLA).

And the main difference: instead of the usual W3 Enabler, which is used in the NTSC PPU, a whole big circuit is used, which is at the very top, to the left of the RW Decoder. It generates the `W3'` signal similar to the NTSC PPU, but in the PAL PPU it goes through the delay line from the DLatch.

## OAM

![pal_oam_row_decoder_tran](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_row_decoder_tran.png)

![pal_oam_row_outputs1](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_row_outputs1.png)

![pal_oam_row_outputs2](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_row_outputs2.png)

## Data Reader

For the inverse signals `#O8/16` and `#I1/32`, 2 inverters have been added where these signals enter the circuit.

|PAL|NTSC|
|---|---|
|![o816_inv](/BreakingNESWiki/imgstore/ppu/pal/o816_inv.jpg)|![o816_orig](/BreakingNESWiki/imgstore/ppu/pal/o816_orig.jpg)|
|![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/pal/i132_inv.jpg)|![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/pal/i132_orig.jpg)|

## Interconnects

See [Interconnections](rails.md)
