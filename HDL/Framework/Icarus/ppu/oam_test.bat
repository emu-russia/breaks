iverilog -D RP2C02 -D ICARUS -o oam_test.run ../../../Common/*.v ../../../PPU/*.v oam_test.v
vvp oam_test.run
