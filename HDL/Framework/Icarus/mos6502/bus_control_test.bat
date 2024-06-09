iverilog -D ICARUS -o bus_control_test.run ../../../Common/*.v ../../../Core6502/*.v bus_control_test.v
vvp bus_control_test.run