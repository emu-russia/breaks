iverilog -D ICARUS -o brk_test.run ../../../Common/*.v ../../../Core6502/*.v brk_test.v
vvp brk_test.run