# Differential Pulse-code Modulation (DPCM) Channel

![apu_locator_dpcm](/BreakingNESWiki/imgstore/apu/apu_locator_dpcm.jpg)

This device is used to generate PCM audio:
- The $4011 output register is a reverse counter that counts down if the next bitstream bit is 0 or up if the next bitstream bit is 1
- It is also possible to load a value directly into the $4011 register for Direct Playback
- Everything else is a set of counters and control logic to organize the DMA process
- DPCM DMA does not use [sprite DMA](dma.md) facilities, but instead arranges its own buffer to store the selected PCM sample. The `RUNDMC` control signal is used to intercept control over sprite DMA.

The difference between DMC DMA and Sprite DMA is that DMC DMA interrupts the processor (RDY = 0) only while the next sample is fetched.

![DMC](/BreakingNESWiki/imgstore/apu/DMC.jpg)

Inputs:

|Signal|From where|Description|
|---|---|---|
|ACLK1|Soft CLK|APU Clock (first core cycle)|
|/ACLK2|Soft CLK|APU Clock (second core cycle, complement)|
|PHI1|CPU|First half of the CPU cycle. It is used only to detect the Read Cycle of the 6502 core and to load samples. All internal counters and most of the control circuits are clocked by ACLK.|
|RES|RES Pad|External reset signal|
|R/W|CPU|CPU data bus mode (1: Read, 0: Write)|
|LOCK|Core|The LOCK signal is used to temporarily suspend the sound generators so that their values can be fixed in the debug registers|
|W401x|Reg Select|1: $401x register write operation|
|/R4015|Reg Select|0: $4015 register read operation|

Outputs:

|Signal|Where|Description|
|---|---|---|
|#DMC/AB|Address MUX|0: Gain control of the address bus to read the DPCM sample|
|RUNDMC|SPR DMA|1: DMC is minding its own business and hijacks DMA control|
|DMCRDY|SPR DMA|1: DMC Ready. Used to control processor readiness (RDY)|
|DMCINT|Soft CLK|1: DMC interrupt is active|
|DMC Out|DAC|Output value for DAC|
|DMC Address|Address MUX|Address for reading the DPCM sample|

DMC internal state control signals:

|Signal|From where|Where to|Description|
|---|---|---|---|
|DSLOAD|DPCM Control|Sample Counter, DPCM Address Counter|Load value into Sample Counter and simultaneously into DPCM Address Counter|
|DSSTEP|DPCM Control|Sample Counter, DPCM Address Counter|Perform Sample Counter decrement and DPCM Address Counter increment simultaneously|
|BLOAD|DPCM Control|Sample Buffer|Load value into Sample Buffer|
|BSTEP|DPCM Control|Sample Buffer|Perform a Sample Buffer bit shift|
|NSTEP|DPCM Control|Sample Bit Counter|Perform Sample Bit Counter increment|
|DSTEP|DPCM Control|DPCM Output|Increment/decrement the DPCM Output counter|
|PCM|DPCM Control|Sample Buffer|Load new sample value into Sample Buffer. The signal is active when PHI1 = 0 and the address bus is captured (imitating CPU reading)|
|LOOP|$4010\[7\]|DPCM Control|1: DPCM looped playback|
|/IRQEN|$4010\[6\]|DPCM Control|0: Enable interrupt from DPCM|
|DOUT|DPCM Output|DPCM Control|DPCM Out counter has finished counting|
|/NOUT|Sample Bit Counter|DPCM Control|0: Sample Bit Counter has finished counting|
|SOUT|Sample Counter|DPCM Control|Sample Counter has finished counting|
|DFLOAD|LFSR|DPCM Control|Frequency LFSR finished counting and reloaded itself|
|n_BOUT|Sample Buffer|DPCM Output|The next bit value pushed out of the Sample Buffer shift register (inverted value)|

The majority of control signals are of the same nature:
- xLOAD: Load new value
- xSTEP: Perform some action
- xOUT: Counter finished counting

An exception is the DFLOAD command: Frequency LFSR reloads itself after counting, but at the same time signals to the main control unit.

## DPCM Control Summary

![DPCM_Control](/BreakingNESWiki/imgstore/apu/DPCM_Control.jpg)

## DPCM Control Register ($4010)

|![dpcm_control_reg_tran](/BreakingNESWiki/imgstore/apu/dpcm_control_reg_tran.jpg)|![DPCM_ControlReg](/BreakingNESWiki/imgstore/apu/DPCM_ControlReg.jpg)|
|---|---|

## DPCM Interrupt Control

|![dpcm_int_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_int_control_tran.jpg)|![DPCM_IntControl](/BreakingNESWiki/imgstore/apu/DPCM_IntControl.jpg)|
|---|---|

## DPCM Enable Control

|![dpcm_enable_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_enable_control_tran.jpg)|![DPCM_EnableControl](/BreakingNESWiki/imgstore/apu/DPCM_EnableControl.jpg)|
|---|---|

## DPCM DMA Control

|![dpcm_dma_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_dma_control_tran.jpg)|![DPCM_DMAControl](/BreakingNESWiki/imgstore/apu/DPCM_DMAControl.jpg)|
|---|---|

## DPCM Sample Counter Control

![dpcm_sample_counter_control_tran1](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_control_tran1.jpg)

![dpcm_sample_counter_control_tran2](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_control_tran2.jpg)

(The second part of the circuit also controls the Sample Bit Counter)

![DPCM_SampleCounterControl](/BreakingNESWiki/imgstore/apu/DPCM_SampleCounterControl.jpg)

## DPCM Sample Buffer Control

![dpcm_sample_buffer_control_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_buffer_control_tran.jpg)

![DPCM_SampleBufferControl](/BreakingNESWiki/imgstore/apu/DPCM_SampleBufferControl.jpg)

## DPCM Sample Counter Register ($4013)

|![dpcm_sample_counter_in_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_in_tran.jpg)|![DPCM_SampleCounterReg](/BreakingNESWiki/imgstore/apu/DPCM_SampleCounterReg.jpg)|
|---|---|

## DPCM Sample Counter

Down counter is used.

|![dpcm_sample_counter_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_counter_tran.jpg)|![DPCM_SampleCounter](/BreakingNESWiki/imgstore/apu/DPCM_SampleCounter.jpg)|
|---|---|

## DPCM Sample Buffer

|![dpcm_sample_buffer_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_buffer_tran.jpg)|![DPCM_SampleBuffer](/BreakingNESWiki/imgstore/apu/DPCM_SampleBuffer.jpg)|
|---|---|

Shift register:

|![DPCM_SRBit](/BreakingNESWiki/imgstore/apu/DPCM_SRBit.jpg)|![DPCM_ShiftReg8](/BreakingNESWiki/imgstore/apu/DPCM_ShiftReg8.jpg)|
|---|---|

## DPCM Sample Bit Counter

Up counter is used.

|![dpcm_sample_bit_counter_tran](/BreakingNESWiki/imgstore/apu/dpcm_sample_bit_counter_tran.jpg)|![DPCM_SampleBitCounter](/BreakingNESWiki/imgstore/apu/DPCM_SampleBitCounter.jpg)|
|---|---|

## DPCM Decoder

![dpcm_decoder_tran](/BreakingNESWiki/imgstore/apu/dpcm_decoder_tran.jpg)

![DPCM_Decoder](/BreakingNESWiki/imgstore/apu/DPCM_Decoder.jpg)

PLA1 is a regular 4-in-16 demultiplexer and PLA2 generates the input value to load into the LFSR.

|Decoder In|Decoder Out|
|---|---|
|0|0x173|
|1|0x08A|
|2|0x143|
|3|0x0DB|
|4|0x1EE|
|5|0x03F|
|6|0x07D|
|7|0x1D1|
|8|0x009|
|9|0x0DC|
|10|0x0F1|
|11|0x0F9|
|12|0x08D|
|13|0x189|
|14|0x18E|
|15|0x156|

|PLA1|PLA2|
|---|---|
|![DPCM_PLA1](/BreakingNESWiki/imgstore/apu/DPCM_PLA1.jpg)|![DPCM_PLA2](/BreakingNESWiki/imgstore/apu/DPCM_PLA2.jpg)|

The first stage of the decoder (4-to-16 demultiplexer):

```
10101010
01101010
10011010
01011010
10100110
01100110
10010110
01010110

10101001
01101001
10011001
01011001
10100101
01100101
10010101
01010101
```

The second stage of the decoder:

```
100101010
100011100
011011100
010011101
011000001
011100001
110001001
011011111

011101000
010000011
000000111
100010000
001001001
001111010
101011101
001100010
```

The bit mask is topological. 1 means there is a transistor, 0 means no transistor.

## DPCM Frequency Counter LFSR

|![dpcm_freq_counter_lfsr_tran](/BreakingNESWiki/imgstore/apu/dpcm_freq_counter_lfsr_tran.jpg)|![DPCM_FreqLFSR](/BreakingNESWiki/imgstore/apu/DPCM_FreqLFSR.jpg)|
|---|---|

LFSR:

|![DPCM_LFSRBit](/BreakingNESWiki/imgstore/apu/DPCM_LFSRBit.jpg)|![DPCM_LFSR](/BreakingNESWiki/imgstore/apu/DPCM_LFSR.jpg)|
|---|---|

## DPCM Address Register ($4012)

|![dpcm_addr_in_tran](/BreakingNESWiki/imgstore/apu/dpcm_addr_in_tran.jpg)|![DPCM_AddressReg](/BreakingNESWiki/imgstore/apu/DPCM_AddressReg.jpg)|
|---|---|

## DPCM Address Counter

Up counter is used.

|Low|High|
|---|---|
|![dpcm_address_low_tran](/BreakingNESWiki/imgstore/apu/dpcm_address_low_tran.jpg)|![dpcm_address_high_tran](/BreakingNESWiki/imgstore/apu/dpcm_address_high_tran.jpg)|

DMC_A15 input is connected to Vdd in the address multiplexer:

![DMC_A15](/BreakingNESWiki/imgstore/apu/DMC_A15.jpg)

![DPCM_AddressCounter](/BreakingNESWiki/imgstore/apu/DPCM_AddressCounter.jpg)

## DPCM Output ($4011)

Reversible counter is used.

![dpcm_output_tran](/BreakingNESWiki/imgstore/apu/dpcm_output_tran.jpg)

![DPCM_Output](/BreakingNESWiki/imgstore/apu/DPCM_Output.jpg)
