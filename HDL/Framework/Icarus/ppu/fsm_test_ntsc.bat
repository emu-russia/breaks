iverilog -D RP2C02 -D ICARUS -o fsm_test.run ../../../Common/*.v ../../../PPU/*.v fsm_test.v
vvp fsm_test.run