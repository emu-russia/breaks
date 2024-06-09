iverilog -D ICARUS -o flags_test.run ../../../Common/*.v ../../../Core6502/*.v flags_test.v
vvp flags_test.run