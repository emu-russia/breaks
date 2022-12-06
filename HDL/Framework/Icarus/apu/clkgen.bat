iverilog -D ICARUS -o clkgen.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v clkgen.v
vvp clkgen.run
