iverilog -g2012 -D ICARUS -o bgcol_test.run ../../../Common/*.v ../../../PPU/bgcol.v bgcol_test.v
vvp bgcol_test.run
