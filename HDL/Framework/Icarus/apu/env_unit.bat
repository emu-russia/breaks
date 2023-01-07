iverilog -D ICARUS -o env_unit.run ../../../Common/*.v ../../../APU/*.v ../../../Core6502/*.v env_unit.v aclkgen.v
vvp env_unit.run