iverilog -D ICARUS -o apu_player.run ../../../Common/*.v ../../../APU/*.v fake6502.v apu_player.v auxout.v
vvp apu_player.run