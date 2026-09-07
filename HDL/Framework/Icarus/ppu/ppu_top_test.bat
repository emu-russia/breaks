iverilog -D RP2C02 -D ICARUS -o ppu_top_test.run ../../../Common/*.v ../../../PPU/*.v ppu_top_test.v
vvp ppu_top_test.run
