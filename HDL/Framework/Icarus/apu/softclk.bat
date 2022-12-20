iverilog -D ICARUS -o softclk.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v softclk.v
vvp softclk.run