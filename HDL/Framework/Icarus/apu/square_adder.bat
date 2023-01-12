iverilog -D ICARUS -o square_adder.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v square_adder.v
vvp square_adder.run