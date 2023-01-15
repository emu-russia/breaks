iverilog -D ICARUS -o noise_output.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v noise_output.v
vvp noise_output.run