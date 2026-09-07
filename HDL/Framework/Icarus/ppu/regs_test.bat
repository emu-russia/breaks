iverilog -D RP2C02 -D ICARUS -o regs_test.run ../../../Common/*.v ../../../PPU/*.v regs_test.v
vvp regs_test.run
