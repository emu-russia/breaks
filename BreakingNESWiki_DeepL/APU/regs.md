# Register Operations

![apu_locator_regs](/BreakingNESWiki/imgstore/apu/apu_locator_regs.jpg)

|Signal|From|Where to|Description|
|---|---|---|---|
|R/W| | | |
|/DBGRD| | | |
|CPU_A\[15:0\]| | | |
|A\[15:0\]| | | |
|D\[7:0\]| | | |
|/REGRD| | | |
|/REGWR| | | |
|/R4015| | | |
|/R4016| | | |
|/R4017| | | |
|/R4018| | | |
|/R4019| | | |
|/R401A| | | |
|W4000| | | |
|W4001| | | |
|W4002| | | |
|W4003| | | |
|W4004| | | |
|W4005| | | |
|W4006| | | |
|W4007| | | |
|W4008| | | |
|W400A| | | |
|W400B| | | |
|W400C| | | |
|W400E| | | |
|W400F| | | |
|W4010| | | |
|W4011| | | |
|W4012| | | |
|W4013| | | |
|W4014| | | |
|W4015| | | |
|W4016| | | |
|W4017| | | |
|W401A| | | |
|SQA\[3:0\]| | | |
|SQB\[3:0\]| | | |
|TRI\[3:0\]| | | |
|RND\[3:0\]| | | |
|DMC\[6:0\]| | | |
|LOCK| | | |

Pre-decoder, to select the address space of the APU registers:

![pdsel_tran](/BreakingNESWiki/imgstore/apu/pdsel_tran.jpg)

- PDSELR: Intermediate signal to form the 12-nor element to produce the `/REGRD` signal
- PDSELW: Intermediate signal to form the 12-nor element to produce the `/REGWR` signal

R/W decoder for register operations:

![reg_rw_decoder_tran](/BreakingNESWiki/imgstore/apu/reg_rw_decoder_tran.jpg)

Selecting a register operation:

![reg_select](/BreakingNESWiki/imgstore/apu/reg_select_tran.jpg)

:warning: The APU registers address space is selected by the value of the CPU address bus (`CPU_Ax`). But the choice of register is made by the value of the address, which is formed at the address multiplexer of DMA-controller (signals A0-A4).

## Debug Interface

Auxiliary circuits for internal `DBG` signal:

|Amplifying inverter|Intermediate inverter|/DBGRD Signal|
|---|---|---|
|![dbg_buf1](/BreakingNESWiki/imgstore/apu/dbg_buf1.jpg)|![dbg_not1](/BreakingNESWiki/imgstore/apu/dbg_not1.jpg)|![nDBGRD](/BreakingNESWiki/imgstore/apu/nDBGRD.jpg)|

Transistor circuits for reading debugging values of sound generators:

|Square 0|Square 1|Triangle|Noise|DPCM|
|---|---|---|---|---|
|![square0_debug_tran](/BreakingNESWiki/imgstore/apu/square0_debug_tran.jpg)|![square1_debug_tran](/BreakingNESWiki/imgstore/apu/square1_debug_tran.jpg)|![tri_debug_tran](/BreakingNESWiki/imgstore/apu/tri_debug_tran.jpg)|![noise_debug_tran](/BreakingNESWiki/imgstore/apu/noise_debug_tran.jpg)|![dpcm_debug_tran](/BreakingNESWiki/imgstore/apu/dpcm_debug_tran.jpg)|

Register operations with debug values are available only when DBG = 1.

LOCK circuit:

![lock_tran](/BreakingNESWiki/imgstore/apu/lock_tran.jpg)

The `LOCK` signal is used to suspend the sound generators so that their values can be locked and can be read using the registers. The lock can only be cleared by a reset.

:warning: The debug hookup is only available in 2A03. The PAL version of the APU (2A07) does not contain any debugging mechanisms.
