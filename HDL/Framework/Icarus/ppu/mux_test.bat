iverilog -g2012 -D RP2C02 -D ICARUS -o mux_test.run ../../../Common/*.v ../../../PPU/mux.v mux_test.v
vvp mux_test.run
