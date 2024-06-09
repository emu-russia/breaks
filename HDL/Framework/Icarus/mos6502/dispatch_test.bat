iverilog -D ICARUS -o dispatch_test.run ../../../Common/*.v ../../../Core6502/*.v dispatch_test.v
vvp dispatch_test.run