iverilog -D ICARUS -o pc_control_test.run ../../../Common/*.v ../../../Core6502/*.v pc_control_test.v
vvp pc_control_test.run