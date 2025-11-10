iverilog -D RP2C02 -D ICARUS -o ppu.run ../../../Common/*.v ../../../PPU/*.v ppu.v
vvp ppu.run