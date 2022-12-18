iverilog -D ICARUS -o regops.run ../../../Common/*.v ../../../APU/regs.v regops.v
vvp regops.run