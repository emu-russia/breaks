iverilog -D ICARUS -o data_bus_test.run ../../../Common/*.v ../../../Core6502/*.v data_bus_test.v
vvp data_bus_test.run