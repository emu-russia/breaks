iverilog -D ICARUS -o alu_control_test.run ../../../Common/*.v ../../../Core6502/*.v alu_control_test.v
vvp alu_control_test.run