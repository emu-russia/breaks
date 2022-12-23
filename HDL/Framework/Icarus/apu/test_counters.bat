iverilog -D ICARUS -o test_counters.run ../../../Common/*.v ../../../APU/common.v test_counters.v
vvp test_counters.run