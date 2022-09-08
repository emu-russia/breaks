# 6502 Core Binding

![apu_locator_core](/BreakingNESWiki/imgstore/apu/apu_locator_core.jpg)

This section describes the features of the core and the surrounding auxiliary logic designed to integrate with the rest of the components.

The 6502 core and surrounding logic includes the following entities:
- Master clock signal and clock divider
- Binding the terminals of the 6502 core to the rest of the APU
- 6502 core
- Register operation decoder
- Debug registers
- External I/O ports

So you don't get lost, here's a larger scale of the schematics discussed below:

![6502_core_clock](/BreakingNESWiki/imgstore/apu/6502_core_clock.jpg)

![6502_core_pads_tran](/BreakingNESWiki/imgstore/apu/6502_core_pads_tran.jpg)

## Master Clock

CLK pin:

![pad_clk](/BreakingNESWiki/imgstore/apu/pad_clk.jpg)

CLK divider:

![div](/BreakingNESWiki/imgstore/apu/div.jpg)

(The diagram is placed "on its side" for convenience).

TBD: A more detailed description of the divider.

M2 pin:

![pad_m2](/BreakingNESWiki/imgstore/apu/pad_m2.jpg)

Circuit for obtaining the `NotDBG_RES` signal:

![notdbg_res_tran](/BreakingNESWiki/imgstore/apu/notdbg_res_tran.jpg)

For some reason the circuit contains a disabled "comb" of transistors, which is a chain of inverters of the internal `RES` signal.

In debug mode (when DBG=1) - the external signal M2 is not touched during reset. In regular mode (for Retail consoles) - during reset the external signal M2 is in `z` state (Open-drain):

```c++
if ( RES & ~DBG) M2 = z;
else M2 = NOT(n_M2);
```

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

There is another transistor next to the RDY input which is always open in the NTSC APU. TBD: Add about the PAL APU.

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

Not very appropriate, but I have to say it here, because in addition to storing data for the sprite DMA this circuit also produces the `WR` signal for the external data bus pins, as well as the `RW` signal.

:warning: It just so happens that the 6502 core signal `R/W` is very similar in name to the `RW` signal which goes to the external R/W pin. Don't get confused :smiley:

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

To understand more about the differences in the operation of the BCD circuit, it is recommended to study the design of the 6502 ALU.

## Register Operations

Pre-decoder, to select the address space of the APU registers:

![pdsel_tran](/BreakingNESWiki/imgstore/apu/pdsel_tran.jpg)

- PDSELR: Intermediate signal to form the 12-nor element to produce the `/REGRD` signal
- PDSELW: Intermediate signal to form the 12-nor element to produce the `/REGWR` signal

R/W decoder for register operations:

![reg_rw_decoder_tran](/BreakingNESWiki/imgstore/apu/reg_rw_decoder_tran.jpg)

Selecting a register operation:

![reg_select](/BreakingNESWiki/imgstore/apu/reg_select_tran.jpg)

:warning: The APU registers address space is selected by the value of the CPU address bus (`CPU_Ax`). But the choice of register is made by the value of the address, which is formed at the address multiplexer of DMA-controller (signals A0-A4).

## Debug Registers

DBG pin:

![pad_dbg](/BreakingNESWiki/imgstore/apu/pad_dbg.jpg)

Auxiliary circuits for DBG:

|Amplifying inverter|Intermediate inverter|/DBGRD Signal|
|---|---|---|
|![dbg_buf1](/BreakingNESWiki/imgstore/apu/dbg_buf1.jpg)|![dbg_not1](/BreakingNESWiki/imgstore/apu/dbg_not1.jpg)|![nDBGRD](/BreakingNESWiki/imgstore/apu/nDBGRD.png)|

Debug register circuits:

|Square 0|Square 1|Triangle|Noise|DPCM|
|---|---|---|---|---|
|![square0_debug_tran](/BreakingNESWiki/imgstore/apu/square0_debug_tran.jpg)|![square1_debug_tran](/BreakingNESWiki/imgstore/apu/square1_debug_tran.jpg)|![tri_debug_tran](/BreakingNESWiki/imgstore/apu/tri_debug_tran.jpg)|![noise_debug_tran](/BreakingNESWiki/imgstore/apu/noise_debug_tran.jpg)|![dpcm_debug_tran](/BreakingNESWiki/imgstore/apu/dpcm_debug_tran.jpg)|

Register operations with debug registers are available only when DBG = 1.

LOCK circuit:

![lock_tran](/BreakingNESWiki/imgstore/apu/lock_tran.jpg)

The `LOCK` signal is used to temporarily suspend the tone generators so that their values can be fixed in the debug registers.

## I/O Ports

Circuit for producing OUTx signals:

![out_tran](/BreakingNESWiki/imgstore/apu/out_tran.jpg)

- The output value for pins `OUT0-2` is derived from the internal signals `OUT0-2` (with the same name).
- The output value for pins `/IN0-1` is the internal signals `/R4016` and `/R4017` from the register selector.
