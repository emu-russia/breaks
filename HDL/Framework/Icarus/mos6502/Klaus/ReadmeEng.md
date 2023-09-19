# 6502 functional tests by Klaus Dormann

Source: https://github.com/Klaus2m5/6502_65C02_functional_tests

The original .bin file has been modified: the reset vector is set to address 0x400 (start of tests).

In addition to the .bin file, 2 more variants have been added for practical use:
- .hex: to load into Logisim model
- .mem: for loading into Verilog model using the `$readmemh` directive.

Tests run for about 96 million cycles, or about 30 million instructions. That is quite a long time.

http://forum.6502.org/viewtopic.php?f=8&t=6202

## How do I know if the tests have been passed

Tests hang at address 0x3469 (infinite jmp = success).
