#!/usr/bin/env python3
"""Render a VCD dump of a 6502 module testbench into a PNG waveform image.

Usage: vcd2png.py <in.vcd> <out.png> [--max-ns N] [--label TEXT]

Draws the top-level signals of the testbench (scalars as digital rows,
small buses as one row per bit). Unknown/high-impedance values are drawn
as a grey band. Pure stdlib + Pillow.
"""
import sys, re
from PIL import Image, ImageDraw

def parse_vcd(path):
    """Return (vars, changes): vars = {fullname: (id, width)},
    changes = {id: [(time, value), ...]}, tmax."""
    vars_ = {}
    changes = {}
    stack = []
    tmax = 0
    t = 0
    with open(path, 'r', errors='replace') as f:
        for raw in f:
            ln = raw.strip()
            if not ln:
                continue
            if ln.startswith('$scope'):
                m = re.match(r'\$scope\s+\w+\s+(\S+)', ln)
                if m:
                    stack.append(m.group(1))
                continue
            if ln == '$upscope':
                if stack:
                    stack.pop()
                continue
            if ln.startswith('$var'):
                m = re.match(r'\$var\s+(\w+)\s+(\d+)\s+(\S+)\s+(\S+)\s*(\[\d+:\d+\])?\s*\$end', ln)
                if m:
                    full = '.'.join(stack + [m.group(4)])
                    vars_[full] = (m.group(3), int(m.group(2)))
                continue
            if ln.startswith('$enddefinitions'):
                break
        # body
        cur = None
        for raw in f:
            ln = raw.strip()
            if not ln:
                continue
            if ln.startswith('#'):
                t = int(ln[1:])
                tmax = max(tmax, t)
                continue
            c = ln[0]
            if c in '01xzXZ':
                # scalar: value char immediately followed by id (may be multi-char)
                val = c
                ident = ln[1:]
                if val in 'xX':
                    val = 'x'
                elif val in 'zZ':
                    val = 'z'
                changes.setdefault(ident, []).append((t, val))
            elif c == 'b':
                parts = ln.split()
                if len(parts) >= 2:
                    val = parts[0][1:]
                    ident = parts[1]
                    # normalize to per-bit string; keep x/z chars
                    changes.setdefault(ident, []).append((t, val))
    return vars_, changes, tmax

def select_signals(vars_):
    """Top-level nets of the root testbench module."""
    out = []
    for full, (ident, width) in vars_.items():
        parts = full.split('.')
        if len(parts) == 2:          # root_module.var only
            if width <= 8:
                out.append((full, ident, width))
    out.sort(key=lambda x: x[0])
    return out

def interp_val(v, width):
    """Return a list of per-bit states (0/1/x) with bit0 first."""
    if width == 1:
        if v in ('1',):
            return ['1']
        if v in ('0',):
            return ['0']
        return ['x']
    bits = list(v)          # vcd stores msb first, e.g. '1010'
    if len(bits) < width:
        bits = ['0'] * (width - len(bits)) + bits
    bits = bits[::-1]       # bit0 first
    for i, b in enumerate(bits):
        if b not in ('0', '1'):
            bits[i] = 'x'
    return bits

def value_at(trans, t, width):
    """Last value at or before t."""
    val = '0' if width > 1 else '0'
    for tt, v in trans:
        if tt <= t:
            val = v
        else:
            break
    return val

def render(vcd, png, label, max_ns):
    vars_, changes, tmax = parse_vcd(vcd)
    sigs = select_signals(vars_)
    id_to_name = {}
    for full, (ident, width) in vars_.items():
        id_to_name.setdefault(ident, (full, width))
    t1 = min(tmax, max_ns) if max_ns else tmax
    t0 = 0
    # layout
    pad_l = 270
    wpp = 2.0               # pixels per ns
    margin = 12
    header = 46
    row_h = 13
    busy = []
    for full, ident, width in sigs:
        n_rows = 1 if width == 1 else width
        busy.append(n_rows)
    total_rows = sum(busy)
    W = int(pad_l + (t1 - t0) * wpp) + 2 * margin
    H = header + total_rows * row_h + 2 * margin
    img = Image.new('RGB', (W, H), 'white')
    dr = ImageDraw.Draw(img)
    # caption
    dr.text((margin, 6), f"{label or vcd}   (0..{t1} ns, {len(sigs)} signals)", fill='black')
    y = header
    for full, ident, width in sigs:
        trans = changes.get(ident, [])
        short = full.split('.', 1)[1] if '.' in full else full
        if width == 1:
            label_txt = short
            dr.text((margin, y + 2), label_txt, fill='black')
            draw_row(dr, trans, 1, t0, t1, pad_l, y, row_h, wpp)
            y += row_h
        else:
            dr.text((margin, y + 2), f"{short}[{width-1}:0]", fill='black')
            for b in range(width):
                draw_row(dr, trans, width, t0, t1, pad_l, y, row_h, wpp, bit=b)
                y += row_h
    img.save(png)
    return tmax

def draw_row(dr, trans, width, t0, t1, x0, y, h, wpp, bit=None):
    """Draw one bit row as GTKWave-like digital trace."""
    # build segments by sampling value every ns is expensive; use step from transitions
    # alternate band background
    if (y // h) % 2 == 0:
        dr.rectangle([x0, y, x0 + (t1 - t0) * wpp, y + h], fill=(245, 247, 250))
    # seed initial value at t0
    seg = []
    val = '0'
    # include transitions from t<=t0 handled below
    prev = t0
    cur = '0'
    for tt, v in trans:
        if tt < t0:
            cur = v
            continue
        if tt > t1:
            break
        seg.append((prev, cur, tt))
        prev = tt
        cur = v
    seg.append((prev, cur, t1 + 1))
    for a, v, b in seg:
        bits = interp_val(v, width)
        bv = bits[bit] if bit is not None else bits[0]
        xa = x0 + (a - t0) * wpp
        xb = x0 + (b - t0) * wpp
        if bv == '1':
            dr.rectangle([xa, y, xb, y + h], fill=(66, 133, 244))
        elif bv == '0':
            pass  # white / light
        else:
            dr.rectangle([xa, y + 1, xb, y + h - 1], fill=(200, 200, 200))
        # transition edge
        if b <= t1:
            dr.line([xa, y, xa, y + h], fill=(0, 0, 0))
    # baseline grid line
    dr.line([x0, y + h // 2, x0 + (t1 - t0) * wpp, y + h // 2], fill=(180, 180, 180))
    # time ruler ticks
    for t in range(t0, t1 + 1, max(1, (t1 - t0) // 10)):
        x = x0 + (t - t0) * wpp
        dr.line([x, y + h - 3, x, y + h - 1], fill='black')
    # left edge
    dr.line([x0 - 1, y, x0 - 1, y + h], fill='black')

if __name__ == '__main__':
    args = sys.argv[1:]
    vcd = args[0]
    png = args[1]
    label = None
    max_ns = None
    if '--label' in args:
        label = args[args.index('--label') + 1]
    if '--max-ns' in args:
        max_ns = int(args[args.index('--max-ns') + 1])
    tmax = render(vcd, png, label, max_ns)
    print(f"{png}: rendered (tmax {tmax} ns)")
