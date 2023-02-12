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
|CLK|CLK Pad|Divider|Input CLK|
|/M2|Divider|M2 Pad|Intermediate signal for M2 terminal ( inverse polarity)|
|DBG|DBG Pad|Test|1: Activation of test mode. In 2A03 the debug registers become available. In 2A07 it is converted to RDY2 signal (DBG=1 -> RDY2=0), essentially acting as a debugging WAIT|
|NotDBG_RES|Test|M2 Pad|Intermediate signal for controlling the M2 terminal under reset and test mode conditions|
|RES|/RES Pad|All|Global reset signal. Spreads to almost all corners of the APU|
|R/W|CPU Core|DMABuffer, Reg Select, OAM DMA, DPCM DMA|6502 core terminal. When applied to DMA it is used to detect CPU read cycle, to set RDY terminal appropriately|
|/NMI|/NMI Pad|CPU Core|From the /NMI terminal, the signal goes almost immediately to the core (not counting the intermediate inverters)|
|INT|SoftCLK|IRQ Combine|Combined DPCM and/or Timer interrupt from SoftCLK (which acts also as a Daisy Chain)|
|/IRQ|/IRQ Pad|IRQ Combine|The external interrupt signal is combined with the INT signal from SoftCLK|
|/IRQ_INT|IRQ Combine|CPU Core|Combined interrupt signal for the core|
|PHI0|Divider|CPU Core|Base clock signal for the core|
|PHI1|CPU Core|SoftCLK, Triangle|The first half of the core cycle|
|PHI2|CPU Core|SoftCLK|The second half of the core cycle|
|RW|DMABuffer|R/W Pad|The external R/W terminal is controlled by the DMABuffer circuit|
|WR|DMABuffer|External DataBus Pads|1: Write mode for external data bus terminals|
|RD|DMABuffer|External DataBus Pads|1: Read mode for external data bus terminals|
|RDY|OAM DMA|CPU Core|Readiness signal for the core. The core readiness is controlled by the OAM DMA circuit|
|RDY2|Test|CPU Core|An additional test signal for core readiness. In 2A03 it is always 1. In 2A07 it can be controlled externally using the DBG Pad|
|SPR/PPU|OAM DMA|DMABuffer|DMABuffer mode (1: Write to register $2004, 0: Read the next byte for OAM DMA from memory)|
|/DBGRD|Reg Select|DMABuffer|0: The APU register is read and the test mode is enabled (DBG=1)|
|CPU_A\[15:0\]|CPU Core|Reg Predecode, Address Mux|The 6502 core address bus. Participates in selecting the APU registers address space and for address multiplexing|
|A\[15:0\]|Address Mux|External Address Pads|Output value from the address multiplexer for AB terminals. Also involved in selecting a specific APU register|
|D\[7:0\]|Internal DataBus|External DataBus Pads|Internal data bus, to which the 6502 core is also connected|

As you can see the signals associated with the core are very tightly twisted. Yes, this part in APU is the most complicated, in sound generators everything is much simpler and more straightforward.

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
