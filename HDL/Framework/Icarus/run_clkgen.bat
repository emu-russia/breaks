iverilog -D ICARUS -o clkgen.run ../../Common/*.v ../../APU/*.v ../../Core6502/*.v ../../PPU/*.v clkgen_run.v
vvp clkgen.run
