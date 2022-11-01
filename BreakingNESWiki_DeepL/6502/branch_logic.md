# Branch Logic

![6502_locator_branch](/BreakingNESWiki/imgstore/6502/6502_locator_branch.jpg)

The logic of conditional branches determines:
- Whether the branch went forward or backward
- Whether a branch occurred at all

The branch direction is determined by the 7th bit of the branch instruction operand (relative offset) which is stored on the internal data bus (DB). If the 7th bit is 1, it means that branch is made "backwards" (PC = PC - offset).

The branch is checked according to the branch instruction (which differs by 6 and 7 bit of the operation code) as well as the flags: C, V, N, Z.

## Branch Forward

![branch_forward_tran](/BreakingNESWiki/imgstore/6502/branch_forward_tran.jpg)

The BRFW trigger is updated with the value D7 during BR3.PHI1. The rest of the time the trigger stores its current value. The value of the trigger is output as a `BRFW` control signal to the [Program Counter (PC) control circuit](pc_control.md).

The `BR2` is the X80 output of the decoder.

## Branch Taken

![branch_taken_tran](/BreakingNESWiki/imgstore/6502/branch_taken_tran.jpg)

The combinatorial logic first selects by IR6/IR7 which group the branch instruction belongs to (i.e. which flag it checks) and the subsequent XOR selects how the branch instruction is triggered (flag set/reset). 
The output of `/BRTAKEN` is in inverse logic, that is, if branch is triggered, then /BRTAKEN = 0. The consumer of the /BRTAKEN signal is also the PC control circuit.

Inputs `/IR6` and `/IR7` are decoder outputs X121 and X126 respectively. The `/IR5` input comes directly from the [instruction register](ir.md).

Note: The Branch Taken logic operates continuously and the value of the /BRTAKEN control line is updated every cycle, regardless of which instruction is being processed by the processor at the time.

## Logic

![branch_logic_logisim](/BreakingNESWiki/imgstore/logisim/branch_logic_logisim.jpg)

## Optimized Schematics

![6_branch_logic_logisim](/BreakingNESWiki/imgstore/6502/ttlworks/6_branch_logic_logisim.png)
