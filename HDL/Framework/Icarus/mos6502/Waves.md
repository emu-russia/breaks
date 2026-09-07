# Module test waveforms (MOS6502 Core, issue #1337)

Screenshots of GTKWave itself (v3.3.128, window capture) for every module
testbench: the matching `waves/<test>.gtkw` save file is opened in GTKWave
with a zoomed time window so the waveforms are readable, and the window is
captured to `<test>.png`. Each `waves/<test>.gtkw` can also be opened in
GTKWave directly against the `<test>.vcd` dump.

Regenerate after a change (needs Windows GTKWave + PowerShell):

```
iverilog -D ICARUS -o <test>.run ../../../Common/*.v ../../../Core6502/*.v <test>.v
vvp <test>.run
Scripts/gtkw_capture_all.sh
```

| Test | Result | Waveform |
|---|---|---|
| clock_test | TEST PASS | ![waves/clock_test.png](waves/clock_test.png) |
| addr_bus_test | TEST PASS | ![waves/addr_bus_test.png](waves/addr_bus_test.png) |
| data_bus_test | TEST PASS | ![waves/data_bus_test.png](waves/data_bus_test.png) |
| busmux_test | TEST PASS (8 checks) | ![waves/busmux_test.png](waves/busmux_test.png) |
| alu_test | TEST PASS (24 checks) | ![waves/alu_test.png](waves/alu_test.png) |
| flags_test | TEST PASS (6 checks) | ![waves/flags_test.png](waves/flags_test.png) |
| pads_test | TEST PASS (12 checks) | ![waves/pads_test.png](waves/pads_test.png) |
| ir_test | TEST PASS (7 checks) | ![waves/ir_test.png](waves/ir_test.png) |
| predecode_test | TEST PASS (257 checks) | ![waves/predecode_test.png](waves/predecode_test.png) |
| decoder_test | waveform (CSV dump) | ![waves/decoder_test.png](waves/decoder_test.png) |
| extra_counter_test | TEST PASS (26 checks) | ![waves/extra_counter_test.png](waves/extra_counter_test.png) |
| branch_logic_test | TEST PASS (128 checks) | ![waves/branch_logic_test.png](waves/branch_logic_test.png) |
| brk_test | waveform | ![waves/brk_test.png](waves/brk_test.png) |
| dispatch_test | waveform | ![waves/dispatch_test.png](waves/dispatch_test.png) |
| alu_control_test | waveform | ![waves/alu_control_test.png](waves/alu_control_test.png) |
| bus_control_test | waveform | ![waves/bus_control_test.png](waves/bus_control_test.png) |
| flags_control_test | waveform | ![waves/flags_control_test.png](waves/flags_control_test.png) |
| pc_control_test | waveform | ![waves/pc_control_test.png](waves/pc_control_test.png) |
| regs_control_test | waveform | ![waves/regs_control_test.png](waves/regs_control_test.png) |
| pc_test | waveform | ![waves/pc_test.png](waves/pc_test.png) |
| regs_test | TEST PASS (9 checks) | ![waves/regs_test.png](waves/regs_test.png) |
