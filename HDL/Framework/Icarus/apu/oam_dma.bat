iverilog -D ICARUS -o oam_dma.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v oam_dma.v aclkgen.v
vvp oam_dma.run