iverilog -D RP2C02 -D ICARUS -o readbuffer_test.run ../../../Common/*.v ../../../PPU/*.v readbuffer_test.v
vvp readbuffer_test.run
