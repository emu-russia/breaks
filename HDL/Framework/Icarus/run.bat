iverilog -D ICARUS -o apu_run ../../Common/*.v ../../APU/*.v ../../Core6502/*.v ../../PPU/*.v apu_run.v
vvp apu_run