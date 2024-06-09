iverilog -D ICARUS -o pc_test.run ../../../Common/*.v ../../../Core6502/*.v pc_test.v
vvp pc_test.run