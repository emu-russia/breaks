# Dispatcher

![6502_locator_dispatch](/BreakingNESWiki/imgstore/6502/6502_locator_dispatch.jpg)

The execution logic (dispatcher or sequencer) is the key mechanism of the processor that "directs" the execution of instructions.

![DispatchUnit](/BreakingNESWiki/imgstore/6502/DispatchUnit.jpg)

The execution logic consists of the following circuits:
- Intermediate signals
- Processor readiness control and R/W Mode
- Short instruction cycle counter (T0-T1)
- Cycle counter for very long instructions (RMW T6-T7)
- Instruction completion circuit
- ACR latch
- Program counter (PC) increment circuit
- Opcode fetch circuit (Fetch)

[Long instruction cycle counter](extra_counter.md) (T2-T5) is discussed in the corresponding section.

:warning: This processor module is very messy and contains many cycles. Signals come in from practically everywhere and also go out to practically every place. The transistor circuits are "spread out" in an even layer in between the rest of the Random Logic.

## Intermediate Signals

Intermediate signals are obtained from the decoder outputs without any regularity. It was very difficult to separate them from the intermediate signals of the other control circuits, because of the chaotic connections.

|BR2|BR3, D91_92|/MemOP|STORE, STOR|/SHIFT|
|---|---|---|---|---|
|![dispatch_br2_tran](/BreakingNESWiki/imgstore/6502/dispatch_br2_tran.jpg)|![dispatch_br3_tran](/BreakingNESWiki/imgstore/6502/dispatch_br3_tran.jpg)|![dispatch_memop_tran](/BreakingNESWiki/imgstore/6502/dispatch_memop_tran.jpg)|![dispatch_store_tran](/BreakingNESWiki/imgstore/6502/dispatch_store_tran.jpg)|![dispatch_shift_tran](/BreakingNESWiki/imgstore/6502/dispatch_shift_tran.jpg)|

## Processor Readiness and R/W Mode

![dispatch_ready_tran](/BreakingNESWiki/imgstore/6502/dispatch_ready_tran.jpg)

![dispatch_rw_tran](/BreakingNESWiki/imgstore/6502/dispatch_rw_tran.jpg)

![DispReadyRW](/BreakingNESWiki/imgstore/6502/DispReadyRW.jpg)

- /ready: global ready signal of the processor, derived from the `RDY` input signal which comes from the corresponding terminal.
- REST: Reset cycle counters
- WR: The processor is in write mode

## Short Cycle Counter

![dispatch_short_cycle_tran](/BreakingNESWiki/imgstore/6502/dispatch_short_cycle_tran.jpg)

![DispShortCycle](/BreakingNESWiki/imgstore/6502/DispShortCycle.jpg)

- T0: Internal signal (processor in T0 cycle)
- /T0, /T1X: Coming to [decoder](decoder.md) input

## Very Long Cycle Counter

![dispatch_long_cycle_tran](/BreakingNESWiki/imgstore/6502/dispatch_long_cycle_tran.jpg)

![DispRMWCycle](/BreakingNESWiki/imgstore/6502/DispRMWCycle.jpg)

- T6, T7: The processor is in the RMW cycle T6/T7

## Instruction Completion

![dispatch_ends_tran](/BreakingNESWiki/imgstore/6502/dispatch_ends_tran.jpg)

- ENDS: Complete the short instructions

![dispatch_endx_tran](/BreakingNESWiki/imgstore/6502/dispatch_endx_tran.jpg)

- ENDX: Complete long instructions

![dispatch_tresx_tran](/BreakingNESWiki/imgstore/6502/dispatch_tresx_tran.jpg)

- #TRESX: Reset Cycle Counters

![dispatch_tres2_tran](/BreakingNESWiki/imgstore/6502/dispatch_tres2_tran.jpg)

- TRES2: Reset [extra instruction counter](extra_counter.md)

![DispCompletionUnit](/BreakingNESWiki/imgstore/6502/DispCompletionUnit.jpg)

## ACR Latch

![dispatch_acr_latch_tran](/BreakingNESWiki/imgstore/6502/dispatch_acr_latch_tran.jpg)

![DispACRLatch](/BreakingNESWiki/imgstore/6502/DispACRLatch.jpg)

Outputs 2 internal intermediate signals: ACRL1 and ACRL2.

## Increment PC

![dispatch_pc_tran](/BreakingNESWiki/imgstore/6502/dispatch_pc_tran.jpg)

![DispIncrementPC](/BreakingNESWiki/imgstore/6502/DispIncrementPC.jpg)

The circuit contains 3 "branches" of combinatorial logic, which finally form the [control command](context_control.md) to increment PC (`#1/PC`).

There is also a circuit nearby to generate the following signals:
- T1: Processor in cycle T1
- TRES1: Reset short instruction cycle counter

## Opcode Fetch

![dispatch_fetch_tran](/BreakingNESWiki/imgstore/6502/dispatch_fetch_tran.jpg)

![DispFetch](/BreakingNESWiki/imgstore/6502/DispFetch.jpg)

- FETCH: Fetch opcode to [instruction register](ir.md)
- 0/IR: Inject `BRK` operation code, for [interrupt handling](interrupts.md)

## Logic (old all-in-one version)

![dispatcher_logisim](/BreakingNESWiki/imgstore/logisim/dispatcher_logisim.jpg)

## Optimized Schematics

![13_dispatcher_logisim](/BreakingNESWiki/imgstore/6502/ttlworks/13_dispatcher_logisim.png)
