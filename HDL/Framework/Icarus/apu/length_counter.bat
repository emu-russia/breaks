iverilog -D ICARUS -o length_counter.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v length_counter.v
vvp length_counter.run