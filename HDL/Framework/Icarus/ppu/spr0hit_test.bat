iverilog -g2012 -D RP2C02 -D ICARUS -o spr0hit_test.run ../../../Common/*.v ../../../PPU/mux.v spr0hit_test.v
vvp spr0hit_test.run
