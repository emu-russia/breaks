iverilog -D ICARUS -o testall.run ../../../Common/*.v ../../../Core6502/*.v testall.v
vvp testall.run