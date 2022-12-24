iverilog -D ICARUS -o length_decoder.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v length_decoder.v
vvp length_decoder.run