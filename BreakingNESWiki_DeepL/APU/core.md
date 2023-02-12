# 6502 Core Binding

![apu_locator_core](/BreakingNESWiki/imgstore/apu/apu_locator_core.jpg)

This section describes the features of the core and the surrounding auxiliary logic designed to integrate with the rest of the components.

The 6502 core and surrounding logic includes the following entities:
- Master clock signal and clock divider
- Binding the terminals of the 6502 core to the rest of the APU
- 6502 core

## Signals

|Signal|From|Where to|Description|
|---|---|---|---|
|CLK| | | |
|/M2| | | |
|DBG| | | |
|NotDBG_RES| | | |
|RES| | | |
|R/W| | | |
|/NMI| | | |
|INT| | | |
|/IRQ| | | |
|/IRQ_INT| | | |
|PHI0| | | |
|PHI1| | | |
|PHI2| | | |
|RW| | | |
|WR| | | |
|RD| | | |
|RDY| | | |
|RDY2| | | |
|SPR/PPU| | | |
|/DBGRD| | | |
|CPU_A\[15:0\]| | | |
|A\[15:0\]| | | |
|D\[7:0\]| | | |

## Divider

The divider is a Johnson counter.

![div](/BreakingNESWiki/imgstore/apu/div.jpg)

(The diagram is placed "on its side" for convenience).

General purpose schematic:

![div_logisim](/BreakingNESWiki/imgstore/apu/div_logisim.jpg)

Schematic for 2A03:

![DIV_2A03](/BreakingNESWiki/imgstore/apu/DIV_2A03.jpg)

The shift register bit of the divider:

![DIV_SRBit](/BreakingNESWiki/imgstore/apu/DIV_SRBit.jpg)

## Connecting the 6502 and APU

This section discusses the connections between the 6502 core terminals and the APU.

### /NMI and /IRQ

Auxiliary logic for NMI and IRQ processing:

|Circuit|Description|
|---|---|
|![apu_core_irqnmi_logic1](/BreakingNESWiki/imgstore/apu/apu_core_irqnmi_logic1.jpg)|Just intermediate inverters|
|![apu_core_irqnmi_logic2](/BreakingNESWiki/imgstore/apu/apu_core_irqnmi_logic2.jpg)|/IRQ_INT: Combination of external and internal interrupt.|

/NMI terminal:

![apu_core_nmi](/BreakingNESWiki/imgstore/apu/apu_core_nmi.jpg)

/IRQ terminal:

![apu_core_irq](/BreakingNESWiki/imgstore/apu/apu_core_irq.jpg)

### RDY

![apu_core_rdy](/BreakingNESWiki/imgstore/apu/apu_core_rdy.jpg)

Next to the RDY input there is another transistor, which in the NTSC APU is always open (RDY2=1). The PAL APU uses the /DBG signal (inversion of the signal from the external DBG terminal) instead of the constant RDY2 signal.

### /RES

![apu_core_res](/BreakingNESWiki/imgstore/apu/apu_core_res.jpg)

There is an inverter on the /RES terminal input to invert the internal `RES` signal.

### PHI0, PHI1, PHI2

Generation of internal PHI signals:

![apu_core_phi_internal](/BreakingNESWiki/imgstore/apu/apu_core_phi_internal.jpg)

Generation of external PHI signals:

|PHI1|PHI2|
|---|---|
|![apu_core_phi1_ext](/BreakingNESWiki/imgstore/apu/apu_core_phi1_ext.jpg)|![apu_core_phi2_ext](/BreakingNESWiki/imgstore/apu/apu_core_phi2_ext.jpg)|

Nothing unusual.

### SO

![apu_core_so](/BreakingNESWiki/imgstore/apu/apu_core_so.jpg)

The SO terminal is always connected to `1`. Technically this is fine, because the SO input has a falling edge detector.

### R/W

![apu_core_rw](/BreakingNESWiki/imgstore/apu/apu_core_rw.jpg)

Nothing unusual.

The `RW` signal does not come directly from the terminal `R/W` of the 6502 core, but is obtained in the buffer circuit for sprite DMA (see below).

### SYNC

The SYNC terminal is not connected to anything (floating):

![apu_core_sync](/BreakingNESWiki/imgstore/apu/apu_core_sync.jpg)

### D0-D7

The 6502 core terminals connect directly to the internal data bus D0-D7.

Signal `RD` schematic:

![rd_tran](/BreakingNESWiki/imgstore/apu/rd_tran.jpg)

Buffer for sprite DMA:

![sprbuf_tran](/BreakingNESWiki/imgstore/apu/sprbuf_tran.jpg)

Not very appropriate, but I have to say it here, because in addition to storing data for the sprite DMA this circuit also produces the `WR` signal for the external data bus pads, as well as the `RW` signal.

:warning: It just so happens that the 6502 core signal `R/W` is very similar in name to the `RW` signal which goes to the external R/W pad. Don't get confused :smiley:

![RWDecode](/BreakingNESWiki/imgstore/apu/RWDecode.jpg)

### A0-A15

The outputs of the 6502 core address bus are associated with the internal CPU_A0-15 signals.

For CPU_A14 there is additionally an inverter that is used in the APU register address predecoding circuitry.

## Embedded 6502 Core

The 6502 core looks like a downsized copy of the original MOS processor.

After detailed study of 2A03 circuit following results were obtained:
- No differences were found in the instruction decoder
- Flag D works as expected, it can be set or reset by CLD/SED instructions; it is used in the regular way during interrupt processing (saved on stack) and after execution of PHP/PLP, RTI instructions.
- Random logic, responsible for generating the two control signals `/DAA` (decimal addition adjust) and `/DSA` (decimal subtraction adjust) works unchanged.

The difference lies in the fact that the control signals `/DAA` and `/DSA`, which enable decimal correction, are disconnected from the circuit, by cutting 5 pieces of polysilicon (see picture). Polysilicon marked as purple, missing pieces marked as cyan.

|Original circuit of the 6502|Missing poly in the APU|
|---|---|
|![bcd_tran_orig](/BreakingNESWiki/imgstore/apu/bcd_tran_orig.png)|![bcd_tran_apu_missing](/BreakingNESWiki/imgstore/apu/bcd_tran_apu_missing.png)|

As result decimal carry circuit and decimal-correction adders do not work. Therefore, the embedded processor of APU always considers add/sub operands as binary numbers, even if the D flag is set.

The research process: http://youtu.be/Gmi1DgysGR0

The key parts of the analysis (decoder, random logic, flags and ALU) are shown in the following image:

![2a03_6502_diff_sm](/BreakingNESWiki/imgstore/apu/2a03_6502_diff_sm.jpg)

To understand more about the differences in the operation of the BCD circuit, it is recommended to study the design of the [6502 ALU](/BreakingNESWiki_DeepL/6502/alu.md).
