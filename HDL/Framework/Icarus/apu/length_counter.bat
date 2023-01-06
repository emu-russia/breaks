iverilog -D ICARUS -o length_counter.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v length_counter.v aclkgen.v
vvp length_counter.run