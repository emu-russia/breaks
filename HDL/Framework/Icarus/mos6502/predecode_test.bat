iverilog -D ICARUS -o predecode_test.run ../../../Common/*.v ../../../Core6502/*.v predecode_test.v
vvp predecode_test.run