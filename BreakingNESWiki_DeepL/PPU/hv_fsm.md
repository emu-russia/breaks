# H/V Control Logic

The H/V logic is a finite state machine (FSM) that controls all other PPU parts. Schematically it is just a set of latches, like "this latch is active from 64th to 128th pixel", so the corresponding control line coming from this latch is also active.

The H/V FSM includes the following components:
- Delayed counter H value output circuits
- Horizontal logic associated with an H decoder
- Vertical logic associated with the V decoder
- PPU interrupt handling (VBlank)
- EVEN/ODD circuitry
- H/V counter control circuitry

The control logic is loaded with all kinds of signals that come and go to almost every possible PPU component.

Inputs:

|Signal|From|Description|
|---|---|---|
|H0-5|HCounter|HCounter bits 0-5, for outputting to the outside with a delay.|
|V8|VCounter|VCounter bit 8. Used in EVEN/ODD logic.|
|/V8|VDecoder|VCounter bit 8 (inverted). Used in EVEN/ODD logic.|
|HPLA_0-23|HDecoder|Outputs from H decoder|
|VPLA_0-8|VDecoder|Outputs from V decoder|
|/OBCLIP|Control Regs ($2001\[2\])|To generate the `CLIP_O` control signal|
|/BGCLIP|Control Regs ($2001\[1\])|To generate the `CLIP_B` control signal|
|BLACK|Control Regs|Active when PPU rendering is disabled (see $2001\[3\] and $2001\[4\])|
|DB7|Internal data bus DB|To read $2002\[7\]. Used in the VBlank interrupt handling circuit.|
|VBL|Control Regs ($2000\[7\])|Used in the VBlank interrupt handling circuit.|
|/R2|Reg Select|Register $2002 read operation. Used in the VBlank interrupt handling circuit.|
|/DBE|/DBE Pad|Enable the CPU interface. Used in the VBlank interrupt handling circuit.|
|RES|/RES Pad|Global reset signal. Used in EVEN/ODD logic.|

Outputs:

|Signal|Where|Description|
|---|---|---|
|**HCounter delayed outputs**|||
|H0'|All|H0 signal delayed by one DLatch|
|/H1'|All|H1 signal delayed by one DLatch (in inverse logic)|
|/H2'|All|H2 signal delayed by one DLatch (in inverse logic)|
|H0''-H5''|All|H0-H5 signals delayed by two DLatch|
|**Horizontal control signals**|||
|S/EV|Sprite Logic|"Start Sprite Evaluation"|
|CLIP_O|Control Regs|"Clip Objects". Do not show the left 8 screen pixels for sprites. Used to get the `CLPO` signal that goes into the OAM FIFO.|
|CLIP_B|Control Regs|"Clip Background". Do not show the left 8 pixels of the screen for the background. Used to get the `CLPB` signal that goes into the Data Reader.|
|0/HPOS|OAM FIFO|"Clear HPos". Clear the H counters in the [sprite FIFO](fifo.md) and start the FIFO|
|EVAL|Sprite Logic|"Sprite Evaluation in Progress"|
|E/EV|Sprite Logic|"End Sprite Evaluation"|
|I/OAM2|Sprite Logic|"Init OAM2". Initialize an extra [OAM](oam.md)|
|PAR/O|All|"PAR for Object". Selecting a tile for an object (sprite)|
|/VIS|Sprite Logic|"Not Visible". The invisible part of the signal (used by [sprite logic](sprite_eval.md))|
|F/NT|Data Reader|"Fetch Name Table"|
|F/TB|Data Reader|"Fetch Tile B"|
|F/TA|Data Reader|"Fetch Tile A"|
|/FO|Data Reader|"Fetch Output Enable"|
|F/AT|Data Reader|"Fetch Attribute Table"|
|SC/CNT|Data Reader|"Scroll Counters Control". Update the scrolling registers.|
|BURST|Video Out|Color Burst|
|SYNC|Video Out|Horizontal sync pulse|
|**Vertical control signals**|||
|VSYNC|Video Out|Vertical sync pulse|
|PICTURE|Video Out|Visible part of the scan-lines|
|VB|HDecoder|Active when the invisible part of the video signal is output (used only in H Decoder)|
|BLNK|HDecoder, All|Active when PPU rendering is disabled (by `BLACK` signal) or during VBlank|
|RESCL (VCLR)|All|"Reset FF Clear" / "VBlank Clear". VBlank period end event. Initially the connection was established with contact /RES, but then it turned out a more global purpose of the signal. Therefore, the signal has two names.|
|**Misc**|||
|HC|HCounter|"HCounter Clear"|
|VC|VCounter|"VCounter Clear"|
|V_IN|VCounter|"VCounter In". Increment the VCounter|
|INT|/INT Pad|"Interrupt". PPU Interrupt|

Auxiliary signals:

|Signal|From|Where|Description|
|---|---|---|---|
|/FPORCH|Horizontal logic (FPORCH FF)|Obtaining the `SYNC` control signal|"Front Porch"|
|BPORCH|Horizontal logic (BPORCH FF)|Obtaining the `PICTURE` control signal|"Back Porch"|
|/HB|Horizontal logic (HBLANK FF)|Obtaining the `VSYNC` control signal|"HBlank"|
|/VSET|Vertical logic|VBlank interrupt handling circuit|"VBlank Set". VBlank period start event.|
|EvenOddOut|EVEN/ODD circuit|H/V counter control|Intermediate signal for the HCounter control circuit.|

## Outputting the H

H counter bits are used in other PPU components.

![h_counter_output](/BreakingNESWiki/imgstore/ppu/h_counter_output.jpg)

## HPos Logic

"Horizontal" logic, responsible for generating control lines depending on the horizontal position of the beam (H):

![hv_fporch](/BreakingNESWiki/imgstore/ppu/hv_fporch.jpg)

![hv_fsm_horz](/BreakingNESWiki/imgstore/ppu/hv_fsm_horz.jpg)

## VPos Logic

"Vertical" logic.

![hv_fsm_vert](/BreakingNESWiki/imgstore/ppu/hv_fsm_vert.jpg)

## VBlank Interrupt Handling

![hv_fsm_int](/BreakingNESWiki/imgstore/ppu/hv_fsm_int.jpg)

## EVEN/ODD Logic

![even_odd_tran](/BreakingNESWiki/imgstore/ppu/even_odd_tran.jpg) ![even_odd_flow1](/BreakingNESWiki/imgstore/ppu/even_odd_flow1.jpg) ![even_odd_flow2](/BreakingNESWiki/imgstore/ppu/even_odd_flow2.jpg)

The EVEN/ODD logic consists of two closed to each other pseudo latches controlled by two multiplexers. This results in a very clever "macro" latch.

TODO: The schematic should be analyzed again, because what the hell is this "macro-latch"... In addition, the scheme for PAL PPU is different from the NTSC version.

## H/V Counters Control

![hv_counters_control](/BreakingNESWiki/imgstore/ppu/hv_counters_control.jpg)
