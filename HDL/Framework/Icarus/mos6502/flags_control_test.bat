iverilog -D ICARUS -o flags_control_test.run ../../../Common/*.v ../../../Core6502/*.v flags_control_test.v
vvp flags_control_test.run