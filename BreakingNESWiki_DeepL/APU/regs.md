# Register Operations

![apu_locator_regs](/BreakingNESWiki/imgstore/apu/apu_locator_regs.jpg)

|Signal|From|Where to|Description|
|---|---|---|---|
|R/W|CPU Core|DMABuffer, Reg Select, OAM DMA, DPCM DMA|6502 core terminal. When applied to DMA it is used to detect CPU read cycle, to set RDY terminal appropriately|
|/DBGRD|Reg Select|DMABuffer|0: The APU register is read and the test mode is enabled (DBG=1)|
|CPU_A\[15:0\]|CPU Core|Reg Predecode, Address Mux|The 6502 core address bus. Participates in APU register selection and for address multiplexing|
|A\[15:0\]|Address Mux|External Address Pads|Output value from the address multiplexer for AB terminals|
|/REGRD|Reg Predecode|Reg Select|0: The APU register is being read from the 6502 core side|
|/REGWR|Reg Predecode|Reg Select|0: Writing to the APU register on the 6502 core side|
|/R4015|Reg Select|SoftCLK, DMABuffer, Length, DPCM|0: Read register $4015. Note that this operation is additionally tracked in the DMABuffer.|
|/R4016|Reg Select|IOPorts|0: Read register $4016|
|/R4017|Reg Select|IOPorts|0: Read register $4017|
|/R4018|Reg Select|Test|0: Read debug register $4018 (2A03 only)|
|/R4019|Reg Select|Test|0: Read debug register $4019 (2A03 only)|
|/R401A|Reg Select|Test|0: Read debug register $401A (2A03 only)|
|W4000|Reg Select|Square0|1: Write register $4000|
|W4001|Reg Select|Square0|1: Write register $4001|
|W4002|Reg Select|Square0|1: Write register $4002|
|W4003|Reg Select|Square0|1: Write register $4003|
|W4004|Reg Select|Square1|1: Write register $4004|
|W4005|Reg Select|Square1|1: Write register $4005|
|W4006|Reg Select|Square1|1: Write register $4006|
|W4007|Reg Select|Square1|1: Write register $4007|
|W4008|Reg Select|Triangle|1: Write register $4008|
|W400A|Reg Select|Triangle|1: Write register $400A|
|W400B|Reg Select|Triangle|1: Write register $400B|
|W400C|Reg Select|Noise|1: Write register $400C|
|W400E|Reg Select|Noise|1: Write register $400E|
|W400F|Reg Select|Noise|1: Write register $400F|
|W4010|Reg Select|DPCM|1: Write register $4010|
|W4011|Reg Select|DPCM|1: Write register $4011|
|W4012|Reg Select|DPCM|1: Write register $4012|
|W4013|Reg Select|DPCM|1: Write register $4013|
|W4014|Reg Select|OAM DMA|1: Write register $4014|
|W4015|Reg Select|Length, DPCM|1: Write register $4015|
|W4016|Reg Select|IOPorts|1: Write register $4016|
|W4017|Reg Select|SoftCLK|1: Write register $4017|
|W401A|Reg Select|Test, Triangle|1: Write debug register $401A (2A03 only)|
|SQA\[3:0\]|Square0|AUX A|Output digital value of the Square0 sound generator|
|SQB\[3:0\]|Square1|AUX A|Output digital value of the Square1 sound generator|
|TRI\[3:0\]|Triangle|AUX B|Output digital value of the Triangle sound generator|
|RND\[3:0\]|Noise|AUX B|Output digital value of the Noise sound generator|
|DMC\[6:0\]|DPCM|AUX B|Output digital value of the DPCM sound generator|
|LOCK|Lock FF|Square0, Square1, Triangle, Noise, DPCM|To lock the volume of the audio generators so that you can read the value using the debug registers|

Pre-decoder, to select the address space of the APU registers:

![pdsel_tran](/BreakingNESWiki/imgstore/apu/pdsel_tran.jpg)

- PDSELR: Intermediate signal to form the 12-nor element to produce the `/REGRD` signal
- PDSELW: Intermediate signal to form the 12-nor element to produce the `/REGWR` signal

R/W decoder for register operations:

![reg_rw_decoder_tran](/BreakingNESWiki/imgstore/apu/reg_rw_decoder_tran.jpg)

![RegPredecode](/BreakingNESWiki/imgstore/apu/RegPredecode.jpg)

Selecting a register operation:

![reg_select](/BreakingNESWiki/imgstore/apu/reg_select_tran.jpg)

:warning: The APU registers address space is selected by the value of the CPU address bus (`CPU_Ax`). But the choice of register is made by the value of the address, which is formed at the address multiplexer of DMA-controller (signals A0-A4).

Bitmask:

```
101010110100
110010110100
101100110100
001100110101

110011001100
010100101011
001100101011
010101001011
010010101011

001011001011
010011001011
001011010011
001101001011
001010101011

001010110011
010011001101
001100110011
010010101101
010100110011

010101010011
001101010011
110101001100
010100101101
101101001100

001100101101
001101001101
001010101101
010101001101
001011001101
```

The bit mask is topological. 1 means there is a transistor, 0 means no transistor.

![RegSel](/BreakingNESWiki/imgstore/apu/RegSel.jpg)

## Debug Interface

:warning: The debug hookup is only available in 2A03. The PAL version of the APU (2A07) does not contain any debugging mechanisms (except RDY2).

Auxiliary circuits for internal `DBG` signal:

|Amplifying inverter|Intermediate inverter|/DBGRD Signal|
|---|---|---|
|![dbg_buf1](/BreakingNESWiki/imgstore/apu/dbg_buf1.jpg)|![dbg_not1](/BreakingNESWiki/imgstore/apu/dbg_not1.jpg)|![nDBGRD](/BreakingNESWiki/imgstore/apu/nDBGRD.jpg)|

Transistor circuits for reading debugging values of sound generators:

|Channel|Circuit|Register operation|Value|Where|
|---|---|---|---|---|
|Square 0|![square0_debug_tran](/BreakingNESWiki/imgstore/apu/square0_debug_tran.jpg)|/R4018|SQA\[3:0\]|D\[3:0\]|
|Square 1|![square1_debug_tran](/BreakingNESWiki/imgstore/apu/square1_debug_tran.jpg)|/R4018|SQB\[3:0\]|D\[7:4\]|
|Triangle|![tri_debug_tran](/BreakingNESWiki/imgstore/apu/tri_debug_tran.jpg)|/R4019|TRI\[3:0\]|D\[3:0\]|
|Noise|![noise_debug_tran](/BreakingNESWiki/imgstore/apu/noise_debug_tran.jpg)|/R4019|RND\[3:0\]|D\[7:4\]|
|DPCM|![dpcm_debug_tran](/BreakingNESWiki/imgstore/apu/dpcm_debug_tran.jpg)|/R401A|DMC\[6:0\]|D\[6:0\]|

Register operations with debug values are available only when DBG = 1.

Circuit for reading the debug value:

![DbgReadoutBit](/BreakingNESWiki/imgstore/apu/DbgReadoutBit.jpg)

LOCK circuit:

|![lock_tran](/BreakingNESWiki/imgstore/apu/lock_tran.jpg)|![lock](/BreakingNESWiki/imgstore/apu/lock.jpg)|
|---|---|

The `LOCK` signal is used to suspend or disconnect the audio generators from the output so that the current volume values are latched and can be read using the debug registers.
