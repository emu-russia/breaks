iverilog -D ICARUS -o square_sweep.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v square_sweep.v aclkgen.v lfo.v
vvp square_sweep.run