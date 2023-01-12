iverilog -D ICARUS -o square_barrel.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v square_barrel.v
vvp square_barrel.run