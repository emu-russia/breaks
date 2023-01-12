iverilog -D ICARUS -o square_output.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v square_output.v aclkgen.v
vvp square_output.run