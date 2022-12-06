iverilog -D ICARUS -o DivSRBit.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v DivSRBit.v
vvp DivSRBit.run