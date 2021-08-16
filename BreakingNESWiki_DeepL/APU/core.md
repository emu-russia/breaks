# Ядро 6502 и сопутствующая логика

After detailed study of 2A03 circuit following results were obtained:
  * No differences were found in the instruction decoder
  * Flag D works as expected, it can be set or reset by CLD/SED instructions; it is used in the normal way during interrupt processing (saved on stack) and after execution of PHP/PLP, RTI instructions.
  * Random logic, responsible for generating the two control lines DAA (decimal addition adjust) and DSA (decimal subtraction adjust) works normally.

The difference lies in the fact that the control lines DAA and DSA, which enable decimal correction, are disconnected from the circuit, by cutting 5 pieces of polysilicon (see picture). Polysilicon marked as purple, missing pieces marked as cyan.

As result decimal carry circuit and decimal-correction adders do not work.
Therefore, the embedded processor of 2A03 always considers add/sub operands as binary numbers, even if the D flag is set.

Процесс исследования:

{{youtube>Gmi1DgysGR0}}

Ключевые узлы по которым был проведен анализ (декодер, рандомная логика, флаги и АЛУ) представлена на следующем изображении:

{{:apu:2a03_6502_diff_sm.jpg?400|}}
