iverilog -D ICARUS -o dispatcher_test.run ../../../Common/*.v ../../../Core6502/*.v dispatcher_test.v
vvp dispatcher_test.run