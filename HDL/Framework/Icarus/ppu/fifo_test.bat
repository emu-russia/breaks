iverilog -D RP2C02 -D ICARUS -o fifo_test.run ../../../Common/*.v ../../../PPU/*.v fifo_test.v
vvp fifo_test.run
