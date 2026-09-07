iverilog -D RP2C02 -D ICARUS -o dac_test.run ../../../Common/*.v ../../../PPU/*.v dac_test.v
vvp dac_test.run
