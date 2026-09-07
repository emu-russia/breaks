iverilog -D RP2C02 -D ICARUS -o cram_test.run ../../../Common/*.v ../../../PPU/*.v cram_test.v
vvp cram_test.run
