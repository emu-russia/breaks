# APU HDL

APU implementation on Verilog.

Status: The implementation is complete, but the sound generators require verification (the rest is verified, including DPCM channel). Also the implementation is based on the external implementation of the 6502 core (`Core6502` module). Apart from that you have to somehow implement the DAC yourself (there are stubs in dac.v now).

![apu_schematic](/HDL/Design/apu_schematic.png)
