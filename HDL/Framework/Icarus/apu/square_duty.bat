iverilog -D ICARUS -o square_duty.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v square_duty.v
vvp square_duty.run