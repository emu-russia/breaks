iverilog -D ICARUS -o addr_bus_test.run ../../../Common/*.v ../../../Core6502/*.v addr_bus_test.v
vvp addr_bus_test.run