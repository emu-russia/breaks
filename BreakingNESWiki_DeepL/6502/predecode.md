# Predecode

![6502_locator_predecode](/BreakingNESWiki/imgstore/6502/6502_locator_predecode.jpg)

The circuit is designed to define the "class" of an instruction: 
- A short instruction which is executed in 2 clock cycles (`TWOCYCLE`)
- An instruction of type `IMPLIED` which has no operands (takes 1 byte in memory)

![predecode_tran](/BreakingNESWiki/imgstore/predecode_tran.jpg)

The operation code received from the external data bus (D0...D7) is stored on the PREDECODE latch (PD) during PHI2 (in inverted form), after which the precoding logic immediately determines the instruction class (the circuit is combinatorial).

The output `/TWOCYCLE` is used by a short cycle counter. The output `/IMPLIED` is used by the PC increment logic.

The PD latch value is fed to the [instruction register](ir.md) input in inverted form.

Also the control line `0/IR` is fed to the Predecode logic input which "injects" the BRK operation into the instruction stream. This occurs during interrupt processing, to initialize the BRK sequence (all interrupts simply mimic the BRK instruction, with slight modifications).

The pre-decode circuit works closely with the [dispatcher](dispatch.md), all control signals go there.

## Logic

The corresponding gates are marked on the transistor schematic:

![predecode_tran_gates](/BreakingNESWiki/imgstore/predecode_tran_gates.jpg)

![predecode_logic](/BreakingNESWiki/imgstore/predecode_logic.jpg)

The predecoding logic is self-descriptive:
- 2-cycle instructions are: Direct operand instructions OR all single-byte instructions EXCEPT push/pull instructions (specified by mask XXX010X1 + 1XX000X0 + XXXX10X0 - 0XX0XX0X)
- Single-byte instructions are set by mask XXXX10X0

TWOCYCLE instructions:

![predecode_twocycle](/BreakingNESWiki/imgstore/predecode_twocycle.jpg)

IMPLIED instructions:

![predecode_implied](/BreakingNESWiki/imgstore/predecode_implied.jpg)
