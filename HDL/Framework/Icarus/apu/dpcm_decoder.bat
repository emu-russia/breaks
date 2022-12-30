iverilog -D ICARUS -o dpcm_decoder.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v dpcm_decoder.v
vvp dpcm_decoder.run