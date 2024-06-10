iverilog -D ICARUS -o busmux_test.run ../../../Common/*.v ../../../Core6502/*.v busmux_test.v
vvp busmux_test.run