iverilog -D ICARUS -o apu.run ../../Common/*.v ../../APU/*.v ../../Core6502/*.v apu_run.v
vvp apu.run