iverilog -D ICARUS -o ir_test.run ../../../Common/*.v ../../../Core6502/*.v ir_test.v
vvp ir_test.run