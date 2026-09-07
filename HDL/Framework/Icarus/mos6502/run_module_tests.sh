#!/bin/bash
# Run every 6502 module testbench (self-checking ones print TEST PASS/FAIL,
# brk/dispatch/pc print waveform-only runs). Klaus/instr full-core tests are
# intentionally not run here (see VERIFICATION.md).
set -u
IV=/mnt/c/iverilog/bin
cd "$(dirname "$0")"
fail=0
for t in *_test.v; do
  case "$t" in klaus_test.v|instr_test.v) continue ;; esac
  base=${t%.v}
  if $IV/iverilog.exe -D ICARUS -o "$base.run" ../../../Common/*.v ../../../Core6502/*.v "$t" >/dev/null 2>&1; then
    out=$($IV/vvp.exe "$base.run" 2>/dev/null | grep -E "TEST PASS|TEST FAIL")
    if [ -n "$out" ]; then
      echo "$base: $out"
      echo "$out" | grep -q "TEST FAIL" && fail=1
    else
      echo "$base: ran (waveform)"
    fi
  else
    echo "$base: COMPILE ERROR"
    fail=1
  fi
done
exit $fail
