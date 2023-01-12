iverilog -D ICARUS -o both_dma.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v both_dma.v aclkgen.v
vvp both_dma.run