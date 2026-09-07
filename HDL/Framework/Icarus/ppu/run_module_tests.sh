#!/bin/bash
# Run every PPU module testbench (self-checking ones print TEST PASS/FAIL).
# Mirrors the 6502 module runner (mos6502/run_module_tests.sh); issue #1388.
# Long whole-PPU/full-frame runs (fsm_test, vidout_test, ppu_top_test) are
# intentionally excluded here — run their *_ntsc/*_pal .bat wrappers directly.
set -u
IV=/mnt/c/iverilog/bin
cd "$(dirname "$0")"
fail=0
for t in *_test.v; do
  case "$t" in
    fsm_test.v|vidout_test.v|ppu_top_test.v) continue ;;
  esac
  base=${t%.v}
  if $IV/iverilog.exe -g2012 -D RP2C02 -D ICARUS -o "$base.run" ../../../Common/*.v ../../../PPU/*.v "$t" >/dev/null 2>&1; then
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
