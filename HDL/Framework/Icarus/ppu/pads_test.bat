iverilog -D RP2C02 -D ICARUS -o pads_test.run ../../../Common/*.v ../../../PPU/*.v pads_test.v
vvp pads_test.run
