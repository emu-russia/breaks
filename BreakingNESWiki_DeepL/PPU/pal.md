# PAL PPU

This section describes the differences in schematics between the PAL PPU version (RP2C07) and the reference NTSC PPU (RP2C02).

## FSM

Found differences from NTSC PPU.

Significantly different EVEN/ODD circuitry (located to the right of the V PLA). The `EvenOddOut` signal goes into sprite logic instead of controlling the H/V counters:

![fsm_even_odd](/BreakingNESWiki/imgstore/ppu/pal/fsm_even_odd.png)

![EvenOdd_PAL](/BreakingNESWiki/imgstore/ppu/pal/EvenOdd_PAL.png)

Slightly different logic for clearing H/V counters:

![fsm_clear_counters](/BreakingNESWiki/imgstore/ppu/pal/fsm_clear_counters.png)

Bit V0 for the phase generator comes out of the VCounter (see VideoOut schematic):

![fsm_v0](/BreakingNESWiki/imgstore/ppu/pal/fsm_v0.png)

BLACK and /PICTURE signals are processed in a special way for PAL (with slight differences):

![fsm_npicture](/BreakingNESWiki/imgstore/ppu/pal/fsm_npicture.png)

Regarding BLACK, see below.

H/V Decoders are also different.

All other parts (Horizontal and vertical FSM logic, register selection circuit, H/V counters) are the same as NTSC PPU.

## H Decoder

![pal_h](/BreakingNESWiki/imgstore/ppu/pal/pal_h.png)

|HPLA output|Pixel numbers of the line|Bitmask|VB Tran|BLNK Tran|Involved|
|---|---|---|---|---|---|
|0|277|01101010011001100100| | |FPorch FF|
|1|256|01101010101010101000| | |FPorch FF|
|2|65|10100110101010100101| |yes|S/EV|
|3|0-7, 256-263|00101010101000000000| | |CLIP_O / CLIP_B|
|4|0-255|10000000000000000010|yes| |CLIP_O / CLIP_B|
|5|339|01100110011010010101| |yes|0/HPOS|
|6|63|10101001010101010101| |yes|/EVAL|
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

## V Decoder

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

CLK:

![vidout_clk](/BreakingNESWiki/imgstore/ppu/pal/vidout_clk.png)

PCLK:

![vidout_pclk](/BreakingNESWiki/imgstore/ppu/pal/vidout_pclk.png)

The color decoder is twice as big (due to the peculiarity of the PAL phase alteration). The V0 bit from the VCounter comes on the decoder to determine the parity of the current line (for phase alteration). The phase shifter is matched to a doubled decoder:

![vidout_phase_chroma](/BreakingNESWiki/imgstore/ppu/pal/vidout_phase_chroma.png)

![vidout_chroma_decoder](/BreakingNESWiki/imgstore/ppu/pal/vidout_chroma_decoder.png)

|Output|Bitmask|
|---|---|
|0|1001100110|
|1|0110100101|
|2|1010100101|
|3|0101100110|
|4|1001010110|
|5|0110011001|
|6|1010011010|
|7|0101011010|
|8|1001101001|
|9|0110101001|
|10|0010101010|
|11|1010100110|
|12|0101101010|
|13|1001011001|
|14|0110010110|
|15|1010010110|
|16|0101011001|
|17|1001101010|
|18|0110100110|
|19|1010101001|
|20|0101101001|
|21|1001011010|
|22|0110011010|
|23|1010011001|
|24|0101010110|

(The numbering of the outputs is topological from left to right. The bit order is top-down. 1 means there is a transistor. 0 means no transistor)

The /PICTURE signal undergoes additional processing (DLATCH delay):

![vidout_npicture](/BreakingNESWiki/imgstore/ppu/pal/vidout_npicture.png)

![nPICTURE_Pal](/BreakingNESWiki/imgstore/ppu/pal/nPICTURE_Pal.png)

The /PICTURE signal comes to the Color Buffer Control circuit in unmodified form (as in NTSC PPU).

DAC, Emphasis and Luma Decoder circuits are the same as NTSC.

## Regs

The `/SLAVE` signal goes through 2 additional inverters for amplification:

![regs_nslave](/BreakingNESWiki/imgstore/ppu/pal/regs_nslave.png)

The B/W signal goes by roundabout ways through the multiplexer, for this purpose it is amplified by two inverters (which do not reverse the polarity of the signal):

![regs_bw](/BreakingNESWiki/imgstore/ppu/pal/regs_bw.png)

The two signals O8/16 and I1/32 are output in inverse logic (there are additional inverters for them in the Data Reader):

![regs_o816_i132](/BreakingNESWiki/imgstore/ppu/pal/regs_o816_i132.png)

The `BLACK` signal processing logic is screwed on:

![regs_black](/BreakingNESWiki/imgstore/ppu/pal/regs_black.png)

The /BLACK signal comes out of the register block. The FET that acts as a DLatch is in the FSM block. It produces the original BLACK signal.

![BLACK_Pal](/BreakingNESWiki/imgstore/ppu/pal/BLACK_Pal.png)

The output of the VBL control signal is slightly different (an additional cutoff transistor is used which is not present in the NTSC PPU):

![regs_vbl](/BreakingNESWiki/imgstore/ppu/pal/regs_vbl.png)

## Sprite Logic

In general, the differences are minimal, but there are nuances. All differences are marked with an exclamation mark.

No changes were found in the comparator logic.

There is only one small change in the comparison control circuit (the lowest one), related to the fact that the signal O8/16 in PAL PPU is already in inverse logic, so an inverter is not required for it:

![eval_o816](/BreakingNESWiki/imgstore/ppu/pal/eval_o816.png)

The counter digit circuits (OAM Counter and OAM2 Counter) are modified so that there is no inverter on the output. Therefore, the outputs (index to access the OAM memory) are in forward logic (`OAM0-7`) and not in inverse logic as in the NTSC PPU (`/OAM0-7`):

![eval_counters](/BreakingNESWiki/imgstore/ppu/pal/eval_counters.png)

The BLNK signal processing circuit (located just above the OAM2 Counter) is different:

![eval_blnk](/BreakingNESWiki/imgstore/ppu/pal/eval_blnk.png)

The control circuit of OAM Counter for the control signal `OMSTEP` is additionally modified by the signal `EvenOddOut`, which comes from the EVEN/ODD circuit (this circuit is to the right of V PLA):

![eval_even_odd](/BreakingNESWiki/imgstore/ppu/pal/eval_even_odd.png)

And the main difference: instead of the usual W3 Enabler, which is used in the NTSC PPU, a whole big circuit is used, which is at the very top, to the left of the RW Decoder. It generates the `W3'` signal similar to the NTSC PPU, but in the PAL PPU it goes through the delay line from the DLatch.

![eval_w3_enable](/BreakingNESWiki/imgstore/ppu/pal/eval_w3_enable.png)

## OAM

Since the OAM address (`OAM0-7`) is issued in direct logic, the outputs of rows 2 and 6 are rearranged for bits 2-4 of the OAM Buffer.

![pal_oam_row_decoder_tran](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_row_decoder_tran.png)

![pal_oam_row_outputs1](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_row_outputs1.png)

(NTSC PPU to the left)

![pal_oam_row_outputs2](/BreakingNESWiki/imgstore/ppu/pal/pal_oam_row_outputs2.png)

(NTSC PPU to the left)

## Data Reader

For the inverse signals `#O8/16` and `#I1/32`, 2 inverters have been added where these signals enter the circuit.

|PAL|NTSC|
|---|---|
|![o816_inv](/BreakingNESWiki/imgstore/ppu/pal/o816_inv.jpg)|![o816_orig](/BreakingNESWiki/imgstore/ppu/pal/o816_orig.jpg)|
|![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/pal/i132_inv.jpg)|![ppu_locator_dataread](/BreakingNESWiki/imgstore/ppu/pal/i132_orig.jpg)|

Thus the inverse propagation of these signals from the register block does not introduce any significant impact compared to the NTSC PPU.

## Interconnects

See [Interconnections](rails.md)

## Impact for emulation/simulation

This section is especially for authors of NES emulators.

It is hard to tell how to transfer these changes to your emulator sources, but here are some thoughts:

- You need to tweak the PPU rendering logic in terms of H/V timings, according to the H/V decoder of the PPU. Its output values are in the table, you just need to relate them to what you have for the NTSC PPU
- The PAL PPU has no NTSC Crawl logic and the Even/Odd circuit does completely different things. Its EvenOddOut signal goes into the control logic of the OAM Counter ($2003) and affects its recalculation (OMSTEP signal). You have to figure out by yourself how OMSTEP logic in NTSC PPU differs from PAL PPU, taking into account EvenOddOut signal.
- You also need to consider the write delay in register $2003, which is implemented by the W3 Enabler circuit.

Everything else is probably irrelevant to software emulation.

As for the video output, based on the Phase Shifter circuit and Chroma decoder values, it is now possible to make a filter/shader like the NTSC Filter by blargg. An experienced NES hacker can easily do it here.

Another mystery, we couldn't find where the Emphasis bits are mixed up. The values from the register block do NOT come out mixed up, which means they are mixed up somewhere in the Phase Shifter.
