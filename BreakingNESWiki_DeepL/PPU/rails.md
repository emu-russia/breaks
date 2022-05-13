# Wiring

This section contains a summary table of all signals.

TBD: The inversion of some signals can be corrected after clarification.

If a signal is repeated somewhere, it is usually not specified again, except in cases where it is important.

The signals for the PAL version of the PPU are marked in the pictures only where there are differences from NTSC.

The most important control signals of the PPU [FSM](hv_fsm.md) are marked with a special icon (:zap:).

## Left Side

![ppu_locator_rails_left](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_left.jpg)

|NTSC|PAL|
|---|---|
|![ntsc_rails1](/BreakingNESWiki/imgstore/ppu/ntsc_rails1.jpg)|![pal_rails1](/BreakingNESWiki/imgstore/ppu/pal_rails1.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|PCLK|PCLK Gen|All|The PPU is in the PCLK=1 state|
|/PCLK|PCLK Gen|All|The PPU is in the PCLK=0 state|
|RC|/RES Pad|Regs|"Registers Clear"|
|EXT0-3 IN|EXT Pads|MUX|Input subcolor from Master PPU|
|/EXT0-3 OUT|EXT Pads|MUX|Output color for Slave PPU|
|/SLAVE|Regs $2000\[6\]|EXT Pads|PPU operating mode (Master/Slave)|
|R/W|R/W Pad|RW Decoder, Reg Select|CPU interface operating mode (read/write)|
|/DBE|/DBE Pad|Regs|"Data Bus Enable", enable CPU interface|
|RS0-3|RS Pads|Reg Select|Selecting a register for the CPU interface|
|/W6/1|Reg Select| |First write to $2006|
|/W6/2|Reg Select| |Second write to $2006|
|/W5/1|Reg Select| |First write to $2005|
|/W5/2|Reg Select| |Second write to $2005|
|/R7|Reg Select| |Read $2007|
|/W7|Reg Select| |Write $2007|
|/W4|Reg Select| |Write $2004|
|/W3|Reg Select| |Write $2003|
|/R2|Reg Select| |Read $2002|
|/W1|Reg Select| |Write $2001|
|/W0|Reg Select| |Write $2000|
|/R4|Reg Select| |Read $2004|
|V0-7|VCounter|Sprite Compare, Sprite Eval|The V counter bits. Bit V7 additionally goes into the Sprite Eval logic.|
|:zap:RESCL (VCLR)|FSM|All|"Reset FF Clear" / "VBlank Clear". VBlank period end event. Initially the connection was established with contact /RES, but then it turned out a more global purpose of the signal. Therefore, the signal has two names.|
|OMFG|Sprite Eval|OAM Counters Ctrl|TBD: Control signal|
|:zap:BLNK|FSM|HDecoder, All|Active when PPU rendering is disabled (by `BLACK` signal) or during VBlank|
|:zap:PAR/O|FSM|All|"PAR for Object". Selecting a tile for an object (sprite)|
|ASAP|OAM Counters Ctrl|OAM Counters Ctrl|TBD: Control signal|
|:zap:/VIS|FSM|Sprite Logic|"Not Visible". The invisible part of the signal (used in sprite logic)|
|:zap:I/OAM2|FSM|Sprite Logic|"Init OAM2". Initialize an additional (temp) OAM|
|/H2'|HCounter|All|H2 signal delayed by one DLatch (in inverse logic)|
|SPR_OV|OAM Counters Ctrl|Sprite Eval|OAM counter overflow|
|:zap:EVAL|FSM|Sprite Logic|"Sprite Evaluation in Progress"|
|H0'|HCounter|All|H0 signal delayed by one DLatch|
|EvenOddOut|Even/Odd Circuit|OAM Counters Ctrl|:warning: Only for PAL PPU.|

|NTSC|PAL|
|---|---|
|![ntsc_rails2](/BreakingNESWiki/imgstore/ppu/ntsc_rails2.jpg)|![pal_rails2](/BreakingNESWiki/imgstore/ppu/pal_rails2.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|:zap:E/EV|FSM|Sprite Logic|"End Sprite Evaluation"|
|:zap:S/EV|FSM|Sprite Logic|"Start Sprite Evaluation"|
|/H1'|HCounter|All|H1 signal delayed by one DLatch (in inverse logic)|
|/H2'|HCounter|All|H2 signal delayed by one DLatch (in inverse logic)|
|:zap:/FO|FSM|Data Reader|"Fetch Output Enable"|
|:zap:F/AT|FSM|Data Reader|"Fetch Attribute Table"|
|:zap:#F/NT|FSM|Data Reader, OAM Eval|0: "Fetch Name Table"|
|:zap:F/TA|FSM|Data Reader|"Fetch Tile A"|
|:zap:F/TB|FSM|Data Reader|"Fetch Tile B"|
|:zap:CLIP_O|FSM|Control Regs|"Clip Objects". 1: Do not show the left 8 screen points for sprites. Used to get the `CLPO` signal that goes into the OAM FIFO.|
|:zap:CLIP_B|FSM|Control Regs|"Clip Background". 1: Do not show the left 8 points of the screen for the background. Used to get the `CLPB` signal that goes into the Data Reader.|
|VBL|Regs $2000\[7\]|FSM|Used in the VBlank interrupt handling circuitry|
|/TB|Regs $2001\[7\]|VideoOut|"Tint Blue". Modifying value for Emphasis|
|/TG|Regs $2001\[6\]|VideoOut|"Tint Green". Modifying value for Emphasis|
|/TR|Regs $2001\[5\]|VideoOut|"Tint Red". Modifying value for Emphasis|
|:zap:SC/CNT|FSM|Data Reader|"Scroll Counters Control". Update the scrolling registers.|
|:zap:0/HPOS|FSM|OAM FIFO|"Clear HPos". Clear the H counters in the sprite FIFO and start the FIFO|
|I2SEV|Sprite Eval|Spr0 Stike|To define a `Sprite 0 Hit` event|
|/OBCLIP|Regs $2001\[2\]|FSM|To generate the `CLIP_O` control signal|
|/BGCLIP|Regs $2001\[1\]|FSM|To generate the `CLIP_B` control signal|
|H0'' - H5''|HCounter|All|H0-H5 signals delayed by two DLatch|
|BLACK|Control Regs|FSM|Active when PPU rendering is disabled (see $2001[3] и $2001[4]). :warning: The circuitry for the signal generation is slightly different in the PAL PPU.|
|DB0-7|All|All|Internal data bus DB|
|B/W|Regs $2001\[0\]|Color Buffer|Disable Color Burst, to generate a monochrome picture|
|TH/MUX|VRAM Ctrl|MUX, Color Buffer|Send the TH Counter value to the MUX input, which will cause the value to go into the palette as Direct Color.|
|DB/PAR|VRAM Ctrl|Data Reader, Color Buffer|TBD: Control signal|

|NTSC|PAL|
|---|---|
|![ntsc_rails3](/BreakingNESWiki/imgstore/ppu/ntsc_rails3.jpg)|![pal_rails3](/BreakingNESWiki/imgstore/ppu/pal_rails3.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|PAL0-4|MUX|Palette|Palette RAM Address|

## Right Side

![ppu_locator_rails_right](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_right.jpg)

|PPU Version|Image|
|---|---|
|NTSC|![ntsc_rails4](/BreakingNESWiki/imgstore/ppu/ntsc_rails4.jpg)|
|PAL|![pal_rails4](/BreakingNESWiki/imgstore/ppu/pal_rails4.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|/OAM0-2|OAM Counters|OAM|OAM Address. :warning: The NTSC version of the PPU uses values in inverse logic (/OAM0-7). The PAL version of the PPU uses values in forward logic (OAM0-7)|
|OAM8|OAM2 Counter|OAM|Selects an additional (temp) OAM for addressing|

|NTSC|PAL|
|---|---|
|![ntsc_rails5](/BreakingNESWiki/imgstore/ppu/ntsc_rails5.jpg)|![rails5](/BreakingNESWiki/imgstore/ppu/pal_rails5.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|/OAM0-7|OAM Counters|OAM|OAM Address. :warning: The NTSC version of the PPU uses values in inverse logic (/OAM0-7). The PAL version of the PPU uses values in forward logic (OAM0-7)|
|OAM8|OAM2 Counter|OAM|Selects an additional (temp) OAM for addressing|
|OAMCTR2|OAM Counters Ctrl|OAM Buffer Ctrl|OAM Buffer Control|
|OB0-7'|OAM Buffer|Sprite Compare|OB output values passed through the PCLK tristates.|

Note: The different inversion of OAM address values of PAL and NTSC PPUs causes the values on the cells in the PAL PPU to be stored in reverse order relative to the NTSC PPU. It does not cause anything else in particular.

|NTSC|PAL|
|---|---|
|![ntsc_rails6](/BreakingNESWiki/imgstore/ppu/ntsc_rails6.jpg)|![rails6](/BreakingNESWiki/imgstore/ppu/pal_rails6.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|OV0-3|Sprite Compare|V Inversion|Bit 0-3 of the V sprite value|
|OB7|OAM Bufer|OAM Eval|OAM Buffer output value, bit 7. For the OAM Eval circuit, this value is exclusively transmitted directly from the OB, without using the PCLK tristate.|
|PD/FIFO|OAM Eval|H Inversion|To zero the output of the H. Inv circuit|
|I1/32|Regs $2000\[2\]|PAR Counters Ctrl|Increment PPU address 1/32. :warning: PAL PPU uses an inverse version of the signal (#I1/32)|
|OBSEL|Regs $2000\[3\]|Pattern Readout|Selecting Pattern Table for sprites|
|BGSEL|Regs $2000\[4\]|Pattern Readout|Selecting Pattern Table for background|
|O8/16|Regs $2000\[5\]|OAM Eval, Pattern Readout|Object lines 8/16 (sprite size). :warning: The PAL PPU uses an inverse version of the signal (#O8/16)|

|NTSC|PAL|
|---|---|
|![ntsc_rails7](/BreakingNESWiki/imgstore/ppu/ntsc_rails7.jpg)|![rails7](/BreakingNESWiki/imgstore/ppu/pal_rails7.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|/SH2|Near MUX|OAM FIFO, V. Inversion|Sprite H value bits. /SH2 also goes into V. Inversion.|
|/SH3|Near MUX|OAM FIFO|Sprite H value bits|
|/SH5|Near MUX|OAM FIFO|Sprite H value bits|
|/SH7|Near MUX|OAM FIFO|Sprite H value bits|
|/SPR0HIT|OAM Priority|Spr0 Strike|To detect a `Sprite 0 Hit` event|
|BGC0-3|BG Color|MUX|Background color|
|/ZCOL0, /ZCOL1, ZCOL2, ZCOL3|OAM FIFO|MUX|Sprite color. :warning: The lower 2 bits are in inverse logic, the higher 2 bits are in direct logic.|
|/ZPRIO|OAM Priority|MUX|0: Priority of sprite over background|
|THO0-4'|PAR TH Counter|MUX|THO0-3 value passed through the PCLK tristate. Direct Color value from TH Counter.|

## Bottom Part

![ppu_locator_rails_bottom](/BreakingNESWiki/imgstore/ppu/ppu_locator_rails_bottom.jpg)

|PPU Version|Image|
|---|---|
|NTSC|![ntsc_rails8](/BreakingNESWiki/imgstore/ppu/ntsc_rails8.jpg)|
|PAL|![pal_rails8](/BreakingNESWiki/imgstore/ppu/pal_rails8.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|OB0-7|OAM Buffer|OAM FIFO, Pattern Readout|OAM Buffer output value|
|CLPO|Regs|OAM FIFO|To enable sprite clipping|
|CLPB|Regs|BG Color|To enable background clipping|
|PD/FIFO|OAM Eval|H Inversion|To zero the output of the H. Inv circuit|
|BGSEL|Regs|Pattern Readout|Selecting Pattern Table for background|
|OV0-3|Sprite Compare|V Inversion|Bit 0-3 of the V sprite value|

|NTSC|PAL|
|---|---|
|![ntsc_rails9](/BreakingNESWiki/imgstore/ppu/ntsc_rails9.jpg)|![pal_rails9](/BreakingNESWiki/imgstore/ppu/pal_rails9.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|/PA0-7|PAR|PPU Address|VRAM address bus|
|/PA8-13|PAR|PPU Address, VRAM Ctrl|VRAM address bus|
|THO0-4|PAR TH Counter|BG Color, MUX|Bit 1 of TH Counter is used in the BG Color circuit. THO0-4 is used in the Multiplexer as Direct Color.|
|TSTEP|VRAM Ctrl|PAR Counters Ctrl|For PAR Counters control logic|
|TVO1|PAR TV Counter|BG Color|Bit 1 of TV Counter|
|FH0-2|Scroll Regs|BG Color|Fine H value|

`/PA0-7` are not shown in the picture, they are on the right side of the [PPU address register](par.md).

|NTSC|PAL|
|---|---|
|![ntsc_rails10](/BreakingNESWiki/imgstore/ppu/ntsc_rails10.jpg)|![pal_rails10](/BreakingNESWiki/imgstore/ppu/pal_rails10.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|PD0-7|All Bottom|All Bottom|VRAM data bus, used at the bottom for data transfer. It is associated with the corresponding PPU pins (`AD0-7`).|
|THO1|PAR TH Counter|BG Color|Bit 1 of TH Counter|
|TVO1|PAR TV Counter|BG Color|Bit 1 of TV Counter|
|BGC0-3|BG Color|MUX|Background color|
|FH0-2|Scroll Regs|BG Color|Fine H value|

|PPU Version|Image|
|---|---|
|NTSC|![ntsc_rails11](/BreakingNESWiki/imgstore/ppu/ntsc_rails11.jpg)|
|PAL|![pal_rails11](/BreakingNESWiki/imgstore/ppu/pal_rails11.jpg)|

|Signal|From|Where|Purpose|
|---|---|---|---|
|PD/RB|VRAM Ctrl|Read Buffer (RB)|Opens RB input (connect PD and RB).|
|XRB|VRAM Ctrl|Read Buffer (RB)|Opens RB output (connect RB and DB).|
|RD|VRAM Ctrl|Pad|Output value for `/RD` pin|
|WR|VRAM Ctrl|Pad|Output value for `/WR` pin|
|/ALE|VRAM Ctrl|Pad|Output value for `ALE` pin|
