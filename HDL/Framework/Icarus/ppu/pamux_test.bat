iverilog -g2012 -D RP2C02 -D ICARUS -o pamux_test.run ../../../Common/*.v ../../../PPU/pamux.v pamux_test.v
vvp pamux_test.run
