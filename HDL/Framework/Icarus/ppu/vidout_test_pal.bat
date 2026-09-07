iverilog -D RP2C07 -D ICARUS -o vidout_test.run ../../../Common/*.v ../../../PPU/*.v vidout_test.v
vvp vidout_test.run