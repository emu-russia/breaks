iverilog -D ICARUS -o decoder_test.run ../../../Common/*.v ../../../Core6502/*.v decoder_test.v
vvp decoder_test.run