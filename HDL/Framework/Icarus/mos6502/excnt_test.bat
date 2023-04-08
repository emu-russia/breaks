iverilog -D ICARUS -o excnt_test.run ../../../Common/*.v ../../../Core6502/*.v excnt_test.v
vvp excnt_test.run