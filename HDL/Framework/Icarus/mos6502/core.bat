iverilog -D ICARUS -o core.run ../../../Common/*.v ../../../Core6502/*.v core.v
vvp core.run