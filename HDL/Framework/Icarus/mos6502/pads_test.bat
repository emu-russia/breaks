iverilog -D ICARUS -o pads_test.run ../../../Common/*.v ../../../Core6502/*.v pads_test.v
vvp pads_test.run