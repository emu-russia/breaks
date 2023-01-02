iverilog -D ICARUS -o noise_decoder.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v noise_decoder.v
vvp noise_decoder.run