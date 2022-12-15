iverilog -D ICARUS -o clkgen_with_reset.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v clkgen_with_reset.v
vvp clkgen_with_reset.run
