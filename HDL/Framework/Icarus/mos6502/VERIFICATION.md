# MOS6502 Core verification status (issue #1337)

Everything here is *module-level*: each HDL/Core6502 block has a testbench in
this folder that compiles with

```
iverilog -D ICARUS -o <test>.run ../../../Common/*.v ../../../Core6502/*.v <test>.v
vvp <test>.run
```

or by running `run_module_tests.sh` (WSL). Waveform screenshots of every test are
in `waves/` (see `Waves.md`).

## Self-checking tests (assert outputs, print TEST PASS/FAIL)

| Test | Checks | Covers |
|---|---|---|
| clock_test | phases | PHI1/PHI2 vs PHI0 (whatwhen.md) |
| addr_bus_test | load/hold | AB register, behavioral AddrBusFF model |
| data_bus_test | read/write | external <-> ADL/ADH/DB transfer, WRLatch |
| busmux_test | 8 | PHI2 precharge, Z_ADL/Z_ADH, SB-DB/SB-ADH |
| alu_test | 24 | AND/OR/EOR/SUM/SRS + ACR/AVR (full-range sweep) |
| flags_test | 6 | P register round-trip via data bus |
| pads_test | 12 | interrupt/reset pads, RnW, SYNC, RDY |
| ir_test | 7 | IR capture / hold, IR01 |
| predecode_test | 257 | PD capture, Z_IR clear, implied/twocycle (all opcodes) |
| regs_test | 14 | X/Y/S load, hold, store to SB/ADL |
| branch_logic_test | 128 | taken decision for all 8 branch conditions |
| decoder_test | 16384 | all 130 decode lines over all IR x cycle inputs |
| bus_control_test | 195 | ZTST/PGX equations, latched outputs x-free |
| alu_control_test | 384 | AND/SR/INC_SB equations, registered outputs x-free |
| flags_control_test | 1056 | all 11 flag commands vs decode equations |
| regs_control_test | 880 | all register commands vs decode equations |
| pc_control_test | 200 | PC command set: defined and deterministic |
| extra_counter_test | 26 | T2..T5 shift sequence, n_ready freeze, TRES2 reset |

## Waveform-only tests

`brk_test`, `dispatch_test`, `pc_test` drive the BRK sequencer, the dispatch
state machine and the dynamic PC register. Their behaviour is only meaningful
in the CPU's command/timing context (PHI1/PHI2 plus the decode/cycle signals
produced by the dispatcher), so they are kept as waveform checks for now.

## Bugs found and fixed while verifying

- ALU (`alu.v`, commit e7a49898): `ands`/`ors` were driven on one parity
  each, breaking the SUM carry chain past bit 1; `xnors[1,3,5,7]` were
  undriven, breaking EOR on odd bits. Full 256x256 truth-table sweeps now
  pass for all five operations.
- ALU input latches (`alu.v`, commit 473e3a30): the AI/BI registers are
  command-muxed dynamic latches (`dlatch` with the load command gating the
  data mux, `en` tied high). At the PHI1->PHI2 boundary the bus precharge
  (all-ones) and the load-command deassertion race in the zero-delay model,
  so BI (and AI) re-captured the precharge value FF instead of the driven
  PHI1 value. Every ALU "sum" latched by the adder hold then was FF: the
  reset-vector low byte and the JMP/JSR operand low byte never reached the
  PCL shadow, so the core booted at $04FF and re-fetched it forever. Fixed
  with the same `#2` mux-output delay idiom already used by `pc.v` for the
  PC shadow inputs; `core_boot_test` now boots at the reset vector ($0400).
- Various translation defects (net declaration order, missing Bus_Control
  ports BR2/BR3/T2, brk6_latch2 net clash, dynamic AddrBusFF simulation) -
  see the commit history and HDL/Core6502/Readme.md.

## Full-core diagnostics

`core_boot_test.v` is a bounded full-core run (3000 cycles) that logs every
opcode fetch. It boots now and must stay green for any further fix.

## Remaining known issue (accumulator/ALU data path)

The PC/boot path is fixed, but load/ALU instructions still do not update the
accumulator correctly (`LDA #` leaves A=FF). Root-cause analysis so far:

- At the load-completion window (the PHI1 that sets the address for the next
  opcode fetch) the design fires `SB_AC` + `SB_DB` + `DB_ADD` + `SB_ADD`, but
  NOT `DL_DB`, so the operand that the DL latch is holding is never put on
  the DB/SB bus and the accumulator samples the precharged FF. The reference
  die command list (BreakingNESWiki A9/LDA walkthrough) fires `DL_DB`
  (+ `DBZ_Z`, `DB_N`) in the same window.
- The `DL_DB` decode in `bus_control.v` (and the Logisim BUS_CONTROL, whose
  dl_db NOR inputs were re-verified gate-for-gate) enables `DL_DB` only from
  `BR2 | (ABS2|T0)&~IMPLIED | INC_SB|X45|BRK6E|X46|X47|JSR2 | X101 | T6`.
  For LDA # (0xA9) the decode row X128 ("IMPL", =~|{d12,d13}) is high, so
  IMPLIED = X128 & ~pp disables the (ABS2|T0) term in every window, and the
  other terms are off -> DL_DB never fires for 0xA9. (Row 128 also fires for
  NOP/ASL-A/INX, and is off for JSR/BRK/JMP/LDA-zpg; jotego's equivalent
  "op-implied" PLA row has an ir0 term that excludes immediate loads like
  0xA9 - compare jotego decode_rom.v pla[128].)
- Empirical test (not committed): OR-ing `~sb_ac_latch_q` (i.e. firing
  DL_DB whenever an SB_AC load request is active) makes `LDA #`/`LDX #`/
  `LDY #` load correctly, but corrupts ALU ops (ORA/AND/EOR/ASL produce
  garbage), because at ALU-op completion the adder result is driven onto SB
  via ADD_SB7/ADD_SB06 and the extra DL_DB + SB_DB pass corrupts it.
- Next step: inspect the ALU-op (e.g. ORA #imm) completion window in the sim
  (which of ADD_SB7/06, SB_DB, SB_AC, adder-hold contents line up) and gate
  the added DL_DB term so it fires only for plain loads (LDA-family, no
  ADD_SB7/06 in the window) - or fix decode row X128 to exclude immediate
  loads. `DBZ_Z`/`DB_N` (flags sampled from DB) are expected to be missing in
  the same windows and must be added with the same discriminator.
  Debug probes: zz_instr.v (opcode-fetch stream + A/X/Y/S), zz_dbg.v.
