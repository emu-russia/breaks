iverilog -g2012 -D RP2C02 -D ICARUS -o tilecnt_test.run ../../../Common/*.v ../../../PPU/pclk.v ../../../PPU/hv.v ../../../PPU/hv_decoder.v ../../../PPU/fsm.v ../../../PPU/tilecnt.v tilecnt_test.v
vvp tilecnt_test.run
