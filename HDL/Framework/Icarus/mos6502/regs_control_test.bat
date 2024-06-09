iverilog -D ICARUS -o regs_control_test.run ../../../Common/*.v ../../../Core6502/*.v regs_control_test.v
vvp regs_control_test.run