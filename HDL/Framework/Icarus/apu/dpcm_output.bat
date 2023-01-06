iverilog -D ICARUS -o dpcm_output.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v dpcm_output.v aclkgen.v
vvp dpcm_output.run