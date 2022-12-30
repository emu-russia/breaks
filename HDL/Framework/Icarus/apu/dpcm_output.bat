breakasm dpcm_sample.asm dpcm_sample.prg
iverilog -D ICARUS -o dpcm_output.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v dpcm_output.v
vvp dpcm_output.run