iverilog -D ICARUS -o clock_test.run ../../../Common/*.v ../../../Core6502/*.v clock_test.v
vvp clock_test.run