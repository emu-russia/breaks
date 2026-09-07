iverilog -D RP2C02 -D ICARUS -o obj_eval_test.run ../../../Common/*.v ../../../PPU/*.v obj_eval_test.v
vvp obj_eval_test.run
