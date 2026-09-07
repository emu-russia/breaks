iverilog -D RP2C02 -D ICARUS -o scroll_regs_test.run ../../../Common/*.v ../../../PPU/*.v scroll_regs_test.v
vvp scroll_regs_test.run
