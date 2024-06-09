iverilog -D ICARUS -o regs_test.run ../../../Common/*.v ../../../Core6502/*.v regs_test.v
vvp regs_test.run