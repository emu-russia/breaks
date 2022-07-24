iverilog -D ICARUS -o DivSRBit.run ../../Common/*.v ../../APU/*.v ../../Core6502/*.v ../../PPU/*.v DivSRBit_Test.v
vvp DivSRBit.run