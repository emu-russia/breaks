# 6502 Core

This section describes the features of the core and the surrounding auxiliary logic designed to integrate with the rest of the components.

## Differences between the APU 6502 core and the original

The 6502 core looks like a downsized copy of the original MOS processor.

After detailed study of 2A03 circuit following results were obtained:
- No differences were found in the instruction decoder
- Flag D works as expected, it can be set or reset by CLD/SED instructions; it is used in the regular way during interrupt processing (saved on stack) and after execution of PHP/PLP, RTI instructions.
- Random logic, responsible for generating the two control lines DAA (decimal addition adjust) and DSA (decimal subtraction adjust) works unchanged.

The difference lies in the fact that the control lines DAA and DSA, which enable decimal correction, are disconnected from the circuit, by cutting 5 pieces of polysilicon (see picture). Polysilicon marked as purple, missing pieces marked as cyan.

As result decimal carry circuit and decimal-correction adders do not work. Therefore, the embedded processor of APU always considers add/sub operands as binary numbers, even if the D flag is set.

The research process: http://youtu.be/Gmi1DgysGR0

The key parts of the analysis (decoder, random logic, flags and ALU) are shown in the following image:

<img src="/BreakingNESWiki/imgstore/apu/2a03_6502_diff_sm.jpg" width="400px">
