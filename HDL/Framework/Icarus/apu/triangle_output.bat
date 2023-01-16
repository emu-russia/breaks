iverilog -D ICARUS -o triangle_output.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v triangle_output.v auxout.v
vvp triangle_output.run