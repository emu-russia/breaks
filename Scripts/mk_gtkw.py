#!/usr/bin/env python3
"""Generate a GTKWave 3.3.128 .gtkw save file from a VCD.

Only the top-level signals of the root testbench module are listed
(scalars + buses up to 32 bits), which is what the module test drives and
observes. Formats follow the v3.3.128 layout (see the hdl-sim-icarus-gtkwave
skill notes: plain @28 scalar / @22 vector lines, @201+[-Name] headers).
"""
import re, sys

def parse_header(path):
    vars_ = {}
    stack = []
    with open(path, 'r', errors='replace') as f:
        for raw in f:
            ln = raw.strip()
            if ln.startswith('$scope'):
                m = re.match(r'\$scope\s+\w+\s+(\S+)', ln)
                if m:
                    stack.append(m.group(1))
            elif ln == '$upscope':
                if stack:
                    stack.pop()
            elif ln.startswith('$var'):
                m = re.match(r'\$var\s+(\w+)\s+(\d+)\s+(\S+)\s+(\S+)\s*(\[\d+:\d+\])?\s*\$end', ln)
                if m:
                    full = '.'.join(stack + [m.group(4)])
                    width = int(m.group(2))
                    suffix = ('[%d:0]' % (width - 1)) if width > 1 else ''
                    vars_[full + suffix] = (m.group(3), width)
            elif ln.startswith('$enddefinitions'):
                break
    return vars_

def main():
    vcd, out = sys.argv[1], sys.argv[2]
    dump = vcd.replace('\\', '/')
    if dump.startswith('/mnt/c/'):
        dump = 'C:/' + dump[len('/mnt/c/'):]
    vars_ = parse_header(vcd)
    # top-level nets of the root module: exactly one dot and width<=32
    sigs = []
    for name, (ident, width) in vars_.items():
        base = name.split('[')[0]
        if base.count('.') == 1 and width <= 32:
            sigs.append((name, width))
    # order: clocks/phis first, then the rest
    def key(s):
        n = s[0].split('.')[1]
        return (0 if n.startswith(('CLK', 'PHI', 'clk', 'phi')) else 1, n)
    sigs.sort(key=key)
    lines = []
    lines.append('GTKWave Analyzer v3.3.128')
    lines.append('(C)1999-2026 BSI')
    lines.append('')
    lines.append('[dumpfile] "%s"' % dump)
    lines.append('[timestart] 0')
    lines.append('[size] 1800 1000')
    lines.append('[pos] -1 -1')
    lines.append('*-0.000000 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1')
    for name, width in sigs:
        lines.append('[treeopen] %s.' % name.split('.')[0])
        break
    lines.append('[sst_width] 120')
    lines.append('[signals_width] 90')
    lines.append('[signals_height] 24')
    lines.append('[pattern_trace] 1')
    lines.append('[pattern_trace] 0')
    lines.append('@201 -Name')
    lines.append('signals')
    for name, width in sigs:
        flag = '@22' if width > 1 else '@28'
        lines.append('%s' % flag)
        lines.append('%s' % name)
    with open(out, 'w') as f:
        f.write('\n'.join(lines) + '\n')
    print('%s: %d signals -> %s' % (vcd, len(sigs), out))

if __name__ == '__main__':
    main()
