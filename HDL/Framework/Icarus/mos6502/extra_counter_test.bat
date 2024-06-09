iverilog -D ICARUS -o extra_counter_test.run ../../../Common/*.v ../../../Core6502/*.v extra_counter_test.v
vvp extra_counter_test.run