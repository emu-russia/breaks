iverilog -D RP2C02 -D ICARUS -o hv_test.run ../../../Common/*.v ../../../PPU/*.v hv_test.v
vvp hv_test.run
