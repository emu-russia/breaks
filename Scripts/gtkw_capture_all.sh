#!/bin/bash
# Capture GTKWave screenshots for every module testbench (6502 Core, issue #1337).
# Requires: Windows GTKWave (C:\iverilog), PowerShell, and .vcd dumps produced
# by `vvp <test>.run` in HDL/Framework/Icarus/mos6502.
# Outputs: waves/<test>.gtkw + waves/<test>.png
set -u
PS=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
GW=/mnt/c/iverilog/bin/gtkwave.exe
DIR=/mnt/c/Work/breaks/HDL/Framework/Icarus/mos6502
W="C:/Work/breaks/HDL/Framework/Icarus/mos6502/waves"
cd "$DIR"
python3 - "$DIR" <<'PYEOF'
import os, re, sys
d = sys.argv[1]
def tmax(p):
    t = 0
    data = open(p, 'rb').read()
    for m in re.finditer(rb'#(\d+)', data):
        v = int(m.group(1))
        if v > t: t = v
    return t
tests = [f[:-4] for f in sorted(os.listdir(d)) if f.endswith('_test.vcd')]
zoom = {}
for t in tests:
    tm = tmax(os.path.join(d, t + '.vcd'))
    win = min(tm, 1500) if t != 'decoder_test' else min(tm, 600)
    if win < 10: win = 10
    zoom[t] = int(win)
    with open(os.path.join(d, '..', '..', '..', '..', '..', 'Scripts', '_zoom_%s.tcl' % t), 'w') as f:
        f.write('::gtkwave::/Time/Zoom/Zoom_Best_Fit\n')
        f.write('gtkwave::setZoomRangeTimes 0 %d\n' % win)
        f.write('::gtkwave::/Time/Move_To_Time 0\n')
print('tests:', len(tests))
PYEOF
for t in addr_bus_test alu_control_test alu_test branch_logic_test brk_test bus_control_test busmux_test clock_test data_bus_test decoder_test dispatch_test extra_counter_test flags_control_test flags_test ir_test pads_test pc_control_test pc_test predecode_test regs_control_test regs_test; do
  [ -f "$t.vcd" ] || continue
  /mnt/c/Windows/System32/taskkill.exe /IM gtkwave.exe /F >/dev/null 2>&1
  python3 /mnt/c/Work/breaks/Scripts/mk_gtkw.py "$DIR/$t.vcd" "$DIR/waves/$t.gtkw" >/dev/null
  ( cd "$DIR" && "$GW" -a "waves/$t.gtkw" -S "C:/Work/breaks/Scripts/_zoom_$t.tcl" >/dev/null 2>&1 & )
  sleep 8
  "$PS" -NoProfile -ExecutionPolicy Bypass -File C:/Work/breaks/Scripts/gtkw_shot.ps1 -TestName "$t" -WaveDir "$W" 2>&1 | tail -1
done
/mnt/c/Windows/System32/taskkill.exe /IM gtkwave.exe /F >/dev/null 2>&1
rm -f /mnt/c/Work/breaks/Scripts/_zoom_*.tcl /mnt/c/Work/breaks/Scripts/_zoom.tcl /mnt/c/Work/breaks/Scripts/_zoomprobe.tcl /mnt/c/Work/breaks/Scripts/_zprobe2.tcl
