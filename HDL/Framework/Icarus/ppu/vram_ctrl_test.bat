iverilog -D RP2C02 -D ICARUS -o vram_ctrl_test.run ../../../Common/*.v ../../../PPU/*.v vram_ctrl_test.v
vvp vram_ctrl_test.run
