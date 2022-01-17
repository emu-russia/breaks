# MOS 6502 Core

MOS 6502 processor core emulator on the gate level.

Yeah, it's that simple. We take the 6502 logic circuits from Wiki and just duplicate them in c++.

To understand what's going on here, it's enough to understand how circuits work. The code simply repeats their work.

## Approaches to simulation

Some modules are simulated immediately with output values. And for some, simulation and output values are separated for convenience.

In general, the source code is a bit like Verilog, but unlike the latter, we choose the sequence of execution of circuit elements ourselves,
thereby imitating the propagation delay that we have in real circuits.

If the module has few inputs/outputs, they are passed as parameters. If there are a lot of inputs/outputs, an array indexed by enum definitions is used as a parameter.

## Combinatorial and sequential circuits

As you know, there are two types of circuits: simple unidirectional gate cascades (NOR, NAND) and cyclic (sequential) Flip/flops circuits.

Combinatorial circuits are simulated simply by repeating the operation of the gates. No gimmicks.

The following approach is applied to sequential circuits (FF's):
- The input stage uses the stored FF value (`ff.get`)
- The output stage updates the current FF value (`ff.set`)
- This makes no difference between which elements the FF is based on. It can be 2 closed inverters, 2 closed NOR or any other cyclic closure
- The "storage" location of FF on the cyclic circuit is chosen arbitrarily, but usually closer to the FF output

It should be noted that the 6502 has quite a few hidden and quite twisted loops, for example:

![t1_ff](/BreakingNESWiki/imgstore/6502/t1_ff.jpg)

## Buses

Modules that are connected to internal buses require a special approach.

Although in a real processor all commands are "executed" at the same time, it is still possible to outline some priority that the developers have laid down.

The commands on the bottom of the 6502, in order of execution:

- Bus load from DL: DL_DB (WR = 0), DL_ADL, DL_ADH
- Registers to the SB bus: Y_SB, X_SB, S_SB
- Saving flags on DB bus: P_DB
- Loading ALU operands: NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD
- ALU operation and ADD saving on SB/ADL: ANDS, EORS, ORS, SRS, SUMS, n_ACIN, n_DAA, n_DSA, ADD_SB7, ADD_SB06, ADD_ADL
- Bus multiplexing: SB_DB, SB_ADH
- BCD correction via SB bus: SB_AC
- Saving AC: AC_SB, AC_DB
- Load flags: DB_P, DBZ_Z, DB_N, IR5_C, DB_C, IR5_D, IR5_I, DB_V, Z_V, ACR_C, AVR_V
- Load registers: SB_X, SB_Y, SB_S / S_S
- Stack pointer saving on ADL bus: S_ADL
- Constant generator: Z_ADL0, Z_ADL1, Z_ADL2, Z_ADH0, Z_ADH17
- PC loading from buses: ADH_PCH, ADL_PCL
- Increment PC: n_1PC, PCL_PCL, PCH_PCH
- Saving PC to buses: PCL_ADL, PCH_ADH, PCL_DB, PCH_DB (considering constant generator)
- Saving DB to DOR: DL_DB (WR = 1)
- Set external address bus: ADH_ABH, ADL_ABL

You should also consider the case when several sources (e.g. registers) put their values on the same bus at the same time.
To solve such situations ("bus conflicts") it is necessary to use the rule "Ground wins".

This takes into account the 6502 feature where buses are "precharged" during PHI2. This is required to form constants (stack address, interrupt address). Charging is done at the very beginning of the simulation.
