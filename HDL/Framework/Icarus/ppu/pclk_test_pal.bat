iverilog -D RP2C07 -D ICARUS -o pclk_test.run ../../../Common/*.v ../../../PPU/*.v pclk_test.v
vvp pclk_test.run
