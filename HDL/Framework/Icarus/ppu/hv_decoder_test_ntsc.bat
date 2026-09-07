iverilog -D RP2C02 -D ICARUS -o hv_decoder_test.run ../../../Common/*.v ../../../PPU/*.v hv_decoder_test.v
vvp hv_decoder_test.run
