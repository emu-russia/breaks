# Register Operations

![apu_locator_regs](/BreakingNESWiki/imgstore/apu/apu_locator_regs.jpg)

|Signal|From|Where to|Description|
|---|---|---|---|
|R/W|CPU Core| | |
|/DBGRD| | | |
|CPU_A\[15:0\]|CPU Core| | |
|A\[15:0\]|Address Mux| | |
|D\[7:0\]| | | |
|/REGRD|Reg Predecode| | |
|/REGWR|Reg Predecode| | |
|/R4015|Reg Select| | |
|/R4016|Reg Select| | |
|/R4017|Reg Select| | |
|/R4018|Reg Select| | |
|/R4019|Reg Select| | |
|/R401A|Reg Select| | |
|W4000|Reg Select| | |
|W4001|Reg Select| | |
|W4002|Reg Select| | |
|W4003|Reg Select| | |
|W4004|Reg Select| | |
|W4005|Reg Select| | |
|W4006|Reg Select| | |
|W4007|Reg Select| | |
|W4008|Reg Select| | |
|W400A|Reg Select| | |
|W400B|Reg Select| | |
|W400C|Reg Select| | |
|W400E|Reg Select| | |
|W400F|Reg Select| | |
|W4010|Reg Select| | |
|W4011|Reg Select| | |
|W4012|Reg Select| | |
|W4013|Reg Select| | |
|W4014|Reg Select| | |
|W4015|Reg Select| | |
|W4016|Reg Select| | |
|W4017|Reg Select| | |
|W401A|Reg Select| | |
|SQA\[3:0\]| | | |
|SQB\[3:0\]| | | |
|TRI\[3:0\]| | | |
|RND\[3:0\]| | | |
|DMC\[6:0\]| | | |
|LOCK|Lock FF| | |

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

:warning: The debug hookup is only available in 2A03. The PAL version of the APU (2A07) does not contain any debugging mechanisms.

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

The `LOCK` signal is used to suspend the sound generators so that their values can be locked and can be read using the registers.
