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
- Various translation defects (net declaration order, missing Bus_Control
  ports BR2/BR3/T2, brk6_latch2 net clash, dynamic AddrBusFF simulation) -
  see the commit history and HDL/Core6502/Readme.md.

## Remaining known issue (blocks full-core runs)

The core reads the reset/BRK vector correctly but the vector low byte never
reaches PCL (DL->ADL->PCL transfer timing), so the first fetch starts at
$04FF instead of the reset vector. This also breaks JMP abs. See
HDL/Core6502/Readme.md. Klaus runs and instruction-level programs depend on
it and are therefore not run here.
