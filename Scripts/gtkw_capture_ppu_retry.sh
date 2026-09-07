#!/bin/bash
# Robust serial GTKWave screenshot capture for PPU tests (issue #1388).
# Usage: gtkw_capture_ppu_retry.sh [dir]
set -u
PS=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
GW=/mnt/c/iverilog/bin/gtkwave.exe
DIR=${1:-/mnt/c/Work/breaks/HDL/Framework/Icarus/ppu}
SCRIPTS=/mnt/c/Work/breaks/Scripts
cd "$DIR" || exit 1
mkdir -p waves
export SCRIPTS
# window per vcd
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
tests = sorted(f[:-4] for f in os.listdir(d) if f.endswith('.vcd'))
for t in tests:
    tm = tmax(os.path.join(d, t + '.vcd'))
    win = min(tm, 2000)
    if win < 10: win = 10
    with open(os.path.join(os.environ['SCRIPTS'], '_zoom_%s.tcl' % t), 'w') as f:
        f.write('::gtkwave::/Time/Zoom/Zoom_Best_Fit\n')
        f.write('gtkwave::setZoomRangeTimes 0 %d\n' % win)
        f.write('::gtkwave::/Time/Move_To_Time 0\n')
print('tests:', len(tests))
PYEOF
fail=0
for vcd in *_test*.vcd; do
  [ -f "$vcd" ] || continue
  t=${vcd%.vcd}
  /mnt/c/Windows/System32/taskkill.exe /IM gtkwave.exe /F >/dev/null 2>&1
  python3 "$SCRIPTS/mk_gtkw.py" "$DIR/$vcd" "$DIR/waves/$t.gtkw" >/dev/null
  for attempt in 1 2 3; do
    ( cd "$DIR" && "$GW" -a "waves/$t.gtkw" -S "C:/Work/breaks/Scripts/_zoom_$t.tcl" >/dev/null 2>&1 & )
    sleep 10
    res=$("$PS" -NoProfile -ExecutionPolicy Bypass -File "$SCRIPTS/gtkw_shot.ps1" -TestName "$t" -WaveDir "C:/Work/breaks/HDL/Framework/Icarus/ppu/waves" 2>&1 | tail -1)
    echo "$t: $res"
    case "$res" in ok*) break ;; esac
    [ "$attempt" = 3 ] && fail=1
  done
  /mnt/c/Windows/System32/taskkill.exe /IM gtkwave.exe /F >/dev/null 2>&1
done
rm -f "$SCRIPTS"/_zoom_*.tcl
exit $fail
