# PAL PPU

This section describes the differences in schematics between the PAL PPU version (RP2C07) and the reference NTSC PPU (RP2C02).

## FSM

Found differences from NTSC PPU:

- Significantly different EVEN/ODD circuitry (located to the right of the V PLA). The signal to the sprite logic (`EvenOddOut`) is not yet clear from this circuit
- Slightly different logic for clearing H/V counters
- Bit V0 for the phase generator comes out of the VCounter (see VideoOut schematic)
- BLACK and PICTURE signals are processed in a special way for PAL (with slight differences)
- H/V Decoders are also different

All other parts (Horizontal and vertical FSM logic, register selection circuit, H/V counters) are the same as NTSC PPU.

## H Decoder (PAL PPU)

![pal_h](/BreakingNESWiki/imgstore/ppu/pal/pal_h.png)

|HPLA output|Pixel numbers of the line|Bitmask|VB Tran|BLNK Tran|Involved|
|---|---|---|---|---|---|
|0|277|01101010011001100100| | |FPorch FF|
|1|256|01101010101010101000| | |FPorch FF|
|2|65|10100110101010100101| |yes|S/EV|
|3|0-7, 256-263|00101010101000000000| | |CLIP_O / CLIP_B|
|4|0-255|10000000000000000010|yes| |CLIP_O / CLIP_B|
|5|339|01100110011010010101| |yes|0/HPOS|
|6|63|10101001010101010101| |yes|EVAL|
|7|255|00010101010101010101| |yes|E/EV|
|8|0-63|10101000000000000001| |yes|I/OAM2|
|9|256-319|01101000000000000001| |yes|PAR/O|
|10|0-255|10000000000000000011|yes|yes|/VIS|
|11|Each 0..1|00000000000010100001| |yes|#F/NT|
|12|Each 6..7|00000000000001010000| | |F/TB|
|13|Each 4..5|00000000000001100000| | |F/TA|
|14|320-335|01000110100000000001| |yes|/FO|
|15|0-255|10000000000000000001| |yes|F/AT|
|16|Each 2..3|00000000000010010000| | |F/AT|
|17|256|01101010101010101000| | |BPorch FF|
|18|4|10101010101001101000| | |BPorch FF|
|19|277|01101010011001100100| | |HBlank FF|
|20|302|01101001100101011000| | |HBlank FF|
|21|321|01100110101010100100| | |BURST FF|
|22|306|01101001011010011000| | |BURST FF|
|23|340|01100110011001101000| | |HCounter clear / VCounter step|

## V Decoder (PAL PPU)

![pal_v](/BreakingNESWiki/imgstore/ppu/pal/pal_v.png)

|VPLA output|Line number|Bitmask|Involved|
|---|---|---|---|
|0|272|011010100110101010|VSYNC FF|
|1|269|011010101001011001|VSYNC FF|
|2|1|101010101010101001|PICTURE FF|
|3|240|000101010110101010|PICTURE FF|
|4|241|000101010110101001|/VSET|
|5|0|101010101010101010|VB FF|
|6|240|000101010110101010|VB FF, BLNK FF|
|7|311|011010010110010101|BLNK FF|
|8|311|011010010110010101|VCLR|
|9|265|011010101001101001|Even/Odd|

## Video Out

Of the notable differences from the NTSC version of the PPU:

- The color decoder is twice as big (due to the peculiarity of the PAL phase alteration)
- In addition, the V0 bit from the VCounter comes on the decoder to determine the parity of the current line (for phase alteration)
- The phase shifter is matched to a doubled decoder
- The PICTURE signal undergoes additional processing (DLATCH delay)
- DAC, Emphasis and Luma Decoder circuits are the same as NTSC

## Regs

The `/SLAVE` signal goes through 2 additional inverters for amplification:

![regs_nslave](/BreakingNESWiki/imgstore/ppu/pal/regs_nslave.png)

The B/W signal goes by roundabout ways through the multiplexer:

![regs_bw](/BreakingNESWiki/imgstore/ppu/pal/regs_bw.png)

The two signals O8/16 and I1/32 are output in inverse logic (there are additional inverters for them in the Data Reader):

![regs_o816_i132](/BreakingNESWiki/imgstore/ppu/pal/regs_o816_i132.png)

The `BLACK` signal processing logic is screwed on:

![regs_black](/BreakingNESWiki/imgstore/ppu/pal/regs_black.png)

The output of the VBL control signal is slightly different (an additional cutoff transistor is used which is not present in the NTSC PPU):

![regs_vbl](/BreakingNESWiki/imgstore/ppu/pal/regs_vbl.png)

## Sprite Logic

In general, the differences are minimal, but there are nuances. All differences are marked with an exclamation mark.

- No changes were found in the comparator logic.
- There is only one small change in the comparison control circuit (the lowest one), related to the fact that the signal O8/16 in PAL PPU is already in inverse logic, so an inverter is not required for it
- The counter digit circuits (OAM Counter and OAM2 Counter) are modified so that there is no inverter on the output. Therefore, the outputs (index to access the OAM memory) are in forward logic (`OAM0-7`) and not in inverse logic as in the NTSC PPU (`/OAM0-7`)
- The BLNK signal processing circuit (located just above the OAM2 Counter) is different
- The control circuit of OAM Counter for the control signal `OMSTEP` is additionally modified by the signal `EvenOddOut`, which comes from the EVEN/ODD circuit (this circuit is to the right of V PLA).

And the main difference: instead of the usual W3 Enabler, which is used in the NTSC PPU, a whole big circuit is used, which is at the very top, to the left of the RW Decoder. It generates the `W3'` signal similar to the NTSC PPU, but in the PAL PPU it goes through the delay line from the DLatch.

## OAM

Since the OAM address (`OAM0-7`) is issued in direct logic, the outputs of rows 2 and 6 are rearranged for bits 2-4 of the OAM Buffer.

![pal_oam_row_decoder_tran](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_row_decoder_tran.png)

![pal_oam_row_outputs1](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_row_outputs1.png)

![pal_oam_row_outputs2](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_row_outputs2.png)

## Data Reader

For the inverse signals `#O8/16` and `#I1/32`, 2 inverters have been added where these signals enter the circuit.

|PAL|NTSC|
|---|---|
|![o816_inv](/BreakingNESWiki/imgstore/ppu/pal/o816_inv.jpg)|![o816_orig](/BreakingNESWiki/imgstore/ppu/pal/o816_orig.jpg)|
|![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/pal/i132_inv.jpg)|![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/pal/i132_orig.jpg)|

Thus the inverse propagation of these signals from the register block does not introduce any significant impact compared to the NTSC PPU.

## Interconnects

See [Interconnections](rails.md)
