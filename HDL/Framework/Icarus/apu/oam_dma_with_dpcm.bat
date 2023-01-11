iverilog -D ICARUS -o oam_dma_with_dpcm.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v oam_dma_with_dpcm.v aclkgen.v
vvp oam_dma_with_dpcm.run