iverilog -D ICARUS -o alu_test.run ../../../Common/*.v ../../../Core6502/*.v alu_test.v
vvp alu_test.run