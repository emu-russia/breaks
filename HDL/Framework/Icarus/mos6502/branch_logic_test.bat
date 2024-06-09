iverilog -D ICARUS -o branch_logic_test.run ../../../Common/*.v ../../../Core6502/*.v branch_logic_test.v
vvp branch_logic_test.run