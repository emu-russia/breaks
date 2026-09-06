iverilog -D RP2C02 -D ICARUS -o ppu_render.run ../../../Common/*.v ../../../PPU/*.v ppu_render.v
vvp ppu_render.run
