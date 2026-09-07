iverilog -g2012 -D RP2C02 -D ICARUS -o par_test.run ../../../Common/*.v ../../../PPU/par.v par_test.v
vvp par_test.run
