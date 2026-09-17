#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""LogisimTopoRouter - topological sorter / router for Logisim & Logisim-evolution schematics.

The script reads a Logisim (``.circ``) project, rebuilds its netlist, topologically
sorts every schematic it contains, draws a new, planar-ish "topologically routed"
version of each sheet and writes it back as a ``.circ`` file (an *atlas* when the
source project holds more than one circuit).  Along the way it prints statistics
about the sorted schematics and emits a declarative Verilog view of the netlist.

Why this exists
---------------
The original Logisim schematics of the chips in this repository (6502, 2C02, 2A03)
were drawn by hand as transistor-level networks; their "logic" order is therefore
very hard to read.  This tool re-plans a schematic topologically: primary inputs
are pushed to the left edge, primary outputs to the right edge, logic cells fill
the columns in between, and every net is routed through dedicated vertical lanes
and horizontal tracks (like a FPGA/ASIC channel router, hence the Xilinx PlanAhead
flavour of the generated sheets).

File format notes (verified against the Logisim 2.7.1 and logisim-evolution 3.8.0
sources):

* both write ``<project version="1.0" source="...">`` - the *dialect* is
  discriminated by ``source=``, not by ``version=``;
* ``<comp lib="N" loc="(x,y)" name="AND Gate"><a name="..." val="..."/></comp>``;
  a ``lib`` attribute is omitted for sub-circuit instances;
* wires are ``<wire from="(x,y)" to="(x,y)"/>`` and connect *only* where a wire
  endpoint coincides exactly with another wire endpoint or with a component pin;
* there is no ``mirror`` attribute - orientation is the single ``facing``
  attribute (``east``/``west``/``north``/``south``);
* drawing shapes (sheet frames) live in ``<circuit><appear><rect .../></appear>``.

Usage
-----
    python3 LogisimTopoRouter.py 6502.circ                    # -> 6502_topo.circ + 6502.v
    python3 LogisimTopoRouter.py 6502.circ -o out/ --atlas
    python3 LogisimTopoRouter.py *.circ --no-route --json     # analysis only

The graphical style is read from ``LogisimTopoRouter.style.json`` next to this
script; pass ``--style`` to use a different file.

Author: emu-russia/breaks, issue #1391.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import sys
import xml.etree.ElementTree as ET
from collections import Counter, defaultdict
from dataclasses import dataclass, field

__version__ = "1.0"

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_STYLE_FILE = os.path.join(HERE, "LogisimTopoRouter.style.json")

# --------------------------------------------------------------------------------------
# Logisim geometry constants (from the Logisim 2.7.1 / logisim-evolution sources)
# --------------------------------------------------------------------------------------

GRID = 10                      # Logisim's coordinate grid, in pixels
DIRECTIONS = ("east", "west", "north", "south")
FACING_DEFAULT = "east"

# Logisim's Location.translate(Direction, dist, right):
#   EAST (x+dist, y+right)   WEST (x-dist, y-right)
#   SOUTH (x-right, y+dist)  NORTH (x+right, y-dist)
_FACING_VEC = {
    "east": (1, 0),
    "west": (-1, 0),
    "north": (0, -1),
    "south": (0, 1),
}


def translate_facing(dx: int, dy: int, facing: str, dist: int, right: int = 0) -> tuple:
    """Compose an east-facing offset with a facing, the way Logisim does.

    `translate(Location.create(dx, dy), facing, dist)` first rotates the component
    geometry and then moves it `dist` along `facing`; the rotation part is what the
    per-component formulas below already encode, so this helper only implements the
    "move along facing" half:
    """
    vx, vy = _FACING_VEC[facing]
    # rotate (dx,dy) with the same convention Logisim uses for port offsets
    rx, ry = rotate_offset(dx, dy, facing)
    return (rx + vx * dist - vy * right, ry + vy * dist + vx * right)


def rotate_offset(dx: int, dy: int, facing: str) -> tuple:
    """Rotate an east-facing offset into `facing`, Logisim style.

    Logisim's components rotate their geometry with ``Bounds.rotate(EAST, facing)``
    and derive pin offsets accordingly; for the pin offsets used throughout the
    standard library this is the mapping encoded here (east is the identity, west
    flips x only, north swaps the axes, south swaps and negates).
    """
    if facing == "west":
        return (-dx, dy)
    if facing == "north":
        return (dy, dx)
    if facing == "south":
        return (dy, -dx)
    return (dx, dy)


def rotate_point(dx: int, dy: int, facing: str) -> tuple:
    """True rotation of a point about the anchor (used for sub-circuit appearances).

    This is the point form of ``Bounds.rotate(EAST, facing, 0, 0)``: east is the
    identity, north maps (x, y) -> (y, -x), west -> (-x, -y), south -> (-y, x).
    """
    if facing == "north":
        return (dy, -dx)
    if facing == "west":
        return (-dx, -dy)
    if facing == "south":
        return (-dy, dx)
    return (dx, dy)


def bounds_rotate_east(x: int, y: int, w: int, h: int, facing: str) -> tuple:
    """Bounds.rotate(EAST, facing, 0, 0) as documented in the geometry reference."""
    if facing == "north":
        return (y, -x - w, h, w)
    if facing == "west":
        return (-x - w, -y - h, w, h)
    if facing == "south":
        return (-y - h, x, h, w)
    return (x, y, w, h)


# --------------------------------------------------------------------------------------
# Default style ("PlanAhead"-like).  The full, documented copy lives in the JSON file
# shipped next to this script; this dict is only a fallback for a missing/broken file.
# --------------------------------------------------------------------------------------

DEFAULT_STYLE = {
    "format": 1,
    "name": "plan-ahead",
    "description": "Xilinx PlanAhead flavoured schematic style",
    "sheet": {
        "frame": True,
        "frame_color": "#7a0000",
        "frame_width": 2,
        "frame_margin": 40,
        "inner_frame": True,
        "title_block": True,
    },
    "layout": {
        "column_pitch": 30,
        "row_pitch": 20,
        "track_pitch": 10,
        "lane_pitch": 10,
        "channel": 10,
        "max_columns": 0,
        "io_columns": True,
        "label_offset": 10,
    },
    "text": {
        "font": "SansSerif plain 12",
        "color": "#000000",
        "sheet_title_font": "SansSerif bold 20",
        "sheet_title_color": "#7a0000",
        "block_font": "SansSerif bold 11",
        "block_color": "#00007a",
        "signal_font": "SansSerif plain 11",
        "signal_color": "#004000",
        "input_color": "#00007a",
        "output_color": "#7a0000",
        "clock_color": "#006000",
        "warning_color": "#a00000",
    },
    "cells": {
        "show_gate_labels": True,
        "show_pin_labels": True,
        "show_net_labels": True,
        "show_level_headers": True,
    },
    "appearance": {
        "gate_style": "classic",
        "pin_style": "classic",
        "circuit_style": "classic",
    },
    "verilog": {
        "primitives": True,
        "indent": "  ",
        "module_prefix": "",
    },
}


def _deep_merge(base: dict, extra: dict) -> dict:
    out = dict(base)
    for key, val in (extra or {}).items():
        if isinstance(val, dict) and isinstance(out.get(key), dict):
            out[key] = _deep_merge(out[key], val)
        else:
            out[key] = val
    return out


def load_style(path: str = None) -> dict:
    """Load the style JSON, falling back to the built-in PlanAhead-ish style."""
    candidates = []
    if path:
        candidates.append(path)
    candidates.append(DEFAULT_STYLE_FILE)
    for cand in candidates:
        try:
            with open(cand, "r", encoding="utf-8") as fh:
                return _deep_merge(DEFAULT_STYLE, json.load(fh))
        except FileNotFoundError:
            continue
        except (OSError, ValueError) as exc:
            print("warning: cannot read style %s (%s); using built-in style" % (cand, exc),
                  file=sys.stderr)
            break
    return json.loads(json.dumps(DEFAULT_STYLE))


# --------------------------------------------------------------------------------------
# Data model
# --------------------------------------------------------------------------------------

@dataclass(eq=False)
class Pin:
    """One connection point of a component, relative to the component's `loc`."""
    dx: int
    dy: int
    kind: str = "in"          # 'in' | 'out' | 'bidir' | 'none'
    name: str = ""
    width: int = 1

    @property
    def offset(self) -> tuple:
        return (self.dx, self.dy)


@dataclass(eq=False)
class Comp:
    """A component instance (a "cell" of the netlist)."""
    idx: int
    name: str                 # factory name, e.g. "AND Gate"
    lib: str                  # library description ("#Gates"), "" for a sub-circuit
    loc: tuple
    attrs: dict
    elem: object = None       # original XML element (None for generated cells)
    orig_facing: str = FACING_DEFAULT
    facing: str = FACING_DEFAULT
    ports: list = field(default_factory=list)
    modelled: bool = False    # ports came from the geometry model, not from inference
    label: str = ""           # user label / tunnel label / pin name
    subcircuit: str = ""      # name of the referenced circuit for sub-circuit cells
    dialect: str = "classic"  # 'classic' (Logisim 2.x) or 'evolution'
    # -- layout results -----------------------------------------------------------
    new_loc: tuple = None
    col: int = 0
    row: int = 0
    bbox: tuple = (0, 0, 0, 0)   # offset bounds (dx, dy, w, h)
    pin_hull: tuple = (0, 0, 0, 0)   # hull of the ports, used for wire-end attribution
    infer_ports: bool = False    # ports inferred from the original wires
    exact: bool = False          # geometry is authoritative (custom sub-circuit appearance)

    @property
    def key(self) -> str:
        return "%s/%s" % (self.lib or "circuit", self.name)

    def attr(self, name, default=None):
        return self.attrs.get(name, default)

    def attr_int(self, name, default=0):
        raw = self.attrs.get(name)
        if raw is None:
            return default
        try:
            return int(str(raw), 0)
        except ValueError:
            return default

    def attr_bool(self, name, default=False):
        raw = self.attrs.get(name)
        if raw is None:
            return default
        return str(raw).lower() == "true"

    def is_pin(self) -> bool:
        return self.name == "Pin" and self.lib.endswith("Wiring")

    def is_tunnel(self) -> bool:
        return self.name == "Tunnel"

    def is_splitter(self) -> bool:
        return self.name == "Splitter"

    def is_text(self) -> bool:
        return self.name == "Text"

    def pin_is_output(self) -> bool:
        """A Pin marked `output` is an output *of the circuit*: inside it is a sink."""
        return self.attr_bool("output", False)


@dataclass(eq=False)
class Net:
    """A physically connected group of pins (one Logisim wire bundle)."""
    idx: int
    members: list = field(default_factory=list)   # list of (Comp, pin index)
    label: str = ""
    width: int = 0
    logical: int = -1
    drivers: list = field(default_factory=list)
    sinks: list = field(default_factory=list)
    bidir: list = field(default_factory=list)
    external_in: list = field(default_factory=list)
    external_out: list = field(default_factory=list)
    warnings: list = field(default_factory=list)
    # routing results
    lane_x: dict = field(default_factory=dict)    # gap index -> x
    track_y: int = None

    def comps(self):
        seen = []
        for comp, _ in self.members:
            if comp not in seen:
                seen.append(comp)
        return seen


@dataclass(eq=False)
class Circuit:
    name: str
    comps: list = field(default_factory=list)
    wires: list = field(default_factory=list)     # list of ((x,y),(x,y))
    attrs: dict = field(default_factory=dict)
    elem: object = None
    nets: list = field(default_factory=list)
    logical_nets: list = field(default_factory=list)
    levels: dict = field(default_factory=dict)    # comp idx -> level
    cycles: list = field(default_factory=list)    # list of SCCs (each a list of comp idx)
    warnings: list = field(default_factory=list)
    stats: dict = field(default_factory=dict)


LOC_RE = re.compile(r"\(?\s*(-?\d+)\s*[, ]\s*(-?\d+)\s*\)?")


def parse_loc(text) -> tuple:
    if text is None:
        return None
    if isinstance(text, tuple):
        return text
    m = LOC_RE.match(str(text).strip())
    if not m:
        return None
    return (int(m.group(1)), int(m.group(2)))


def fmt_loc(pt: tuple) -> str:
    return "(%d,%d)" % (int(pt[0]), int(pt[1]))


def snap(value: int, grid: int = GRID) -> int:
    if grid <= 1:
        return int(value)
    return int(math.floor(value / grid + 0.5)) * grid


def _translate(dir_: str, dist: int, right: int = 0) -> tuple:
    """Location.translate(Direction, dist, right) from Logisim."""
    if dir_ == "east":
        return (dist, right)
    if dir_ == "west":
        return (-dist, -right)
    if dir_ == "north":
        return (right, -dist)
    return (-right, dist)          # south


def _reverse(facing: str) -> str:
    return {"east": "west", "west": "east", "north": "south", "south": "north"}[facing]


def font_size(font: str, default: int = 12) -> int:
    m = re.search(r"(\d+)\s*$", font or "")
    return int(m.group(1)) if m else default


# ======================================================================================
# Geometry model: pin offsets and offset bounds per component family
# ======================================================================================
#
# Every builder below returns the component's ports in Logisim's *end index order*
# (`Port[]` array order), which is how the original wires address them.  `kind` is the
# electrical role used by the net analyser:
#
#   'out'   drives the net              'in'    is driven by the net
#   'bidir' may do either (transistors, pull resistors)
#   'link'  neither - it merely joins nets (splitter ends)
#   'none'  decorative end (never driven, never drives)
#
# A Pin component deserves a word: Logisim declares `output=true` pins as END INPUTS,
# i.e. a pin that *outputs the circuit* is a sink inside the circuit, and vice versa.

WIRING = "#Wiring"
GATES = "#Gates"
PLEXERS = "#Plexers"
ARITH = "#Arithmetic"
MEMORY = "#Memory"
IO = "#I/O"
BASE = "#Base"


def _gate_input_dy(inputs: int, size: int, index: int) -> int:
    """AbstractGate.getInputOffset()'s dy term (verbatim port of the formula)."""
    if inputs <= 3:
        if size < 40:
            skip_start, skip_dist, skip_even = -5, 10, 10
        elif size < 60 or inputs <= 2:
            skip_start, skip_dist, skip_even = -10, 20, 20
        else:
            skip_start, skip_dist, skip_even = -15, 30, 30
    elif inputs == 4 and size >= 60:
        skip_start, skip_dist, skip_even = -5, 20, 0
    else:
        skip_start, skip_dist, skip_even = -5, 10, 10
    if inputs % 2 == 1:
        return skip_start * (inputs - 1) + skip_dist * index
    dy = skip_start * inputs + skip_dist * index
    if index >= inputs // 2:
        dy += skip_even
    return dy


def _gate_geometry(comp, facing, xor_like=False, negate_out=False):
    size = comp.attr_int("size", 50)
    inputs = max(2, comp.attr_int("inputs", 5))
    width = comp.attr_int("width", 1)
    negated = 0
    for i in range(inputs):
        if comp.attr_bool("negate%d" % i, False):
            negated |= (1 << i)
    bonus = 10 if xor_like else 0
    neg_out = 10 if negate_out else 0
    axis = size + bonus + neg_out
    ax = 1 if comp.attr_bool("out_negated", False) or negate_out else 0
    ports = [Pin(0, 0, "out", "Y", width)]
    for i in range(inputs):
        d = axis + (10 if (negated >> i) & 1 else 0)
        dy = _gate_input_dy(inputs, size, i)
        if facing == "east":
            off = (-d, dy)
        elif facing == "west":
            off = (d, dy)
        elif facing == "north":
            off = (dy, d)
        else:
            off = (dy, -d)
        ports.append(Pin(off[0], off[1], "in", "I%d" % (i + 1), width))
    box_w = size + bonus + neg_out + (10 if negated else 0)
    box_i = inputs + 1 if inputs % 2 == 0 else inputs
    box_h = max(10 * box_i, size)
    return ports, bounds_rotate_east(-box_w, -box_h // 2, box_w, box_h, facing)


def _ports_gate(comp, facing):
    return _gate_geometry(comp, facing)[0]


def _bounds_gate(comp, facing):
    return _gate_geometry(comp, facing)[1]


def _ports_xor(comp, facing):
    return _gate_geometry(comp, facing, xor_like=True)[0]


def _bounds_xor(comp, facing):
    return _gate_geometry(comp, facing, xor_like=True)[1]


def _ports_nand(comp, facing):
    return _gate_geometry(comp, facing, negate_out=True)[0]


def _bounds_nand(comp, facing):
    return _gate_geometry(comp, facing, negate_out=True)[1]


def _ports_xnor(comp, facing):
    return _gate_geometry(comp, facing, xor_like=True, negate_out=True)[0]


def _bounds_xnor(comp, facing):
    return _gate_geometry(comp, facing, xor_like=True, negate_out=True)[1]


def _ports_not(comp, facing):
    width = comp.attr_int("width", 1)
    narrow = comp.attr_int("size", 30) == 20
    dist = -20 if narrow else -30
    off = _translate(facing, dist)
    return [Pin(0, 0, "out", "Y", width), Pin(off[0], off[1], "in", "A", width)]


def _bounds_not(comp, facing):
    wide = 20 if comp.attr_int("size", 30) == 20 else 30
    return bounds_rotate_east(-wide, -9, wide, 18, facing)


def _ports_buffer(comp, facing):
    width = comp.attr_int("width", 1)
    off = _translate(facing, -20)
    return [Pin(0, 0, "out", "Y", width), Pin(off[0], off[1], "in", "A", width)]


def _bounds_buffer(comp, facing):
    return bounds_rotate_east(-20, -9, 20, 18, facing)


def _controlled_geometry(comp, facing, inverter):
    width = comp.attr_int("width", 1)
    w = 30 if (inverter and comp.attr_int("size", 30) != 20) else 20
    d = 10 if w == 30 else 0
    loc1 = _translate(_reverse(facing), 20 + d)
    left_handed = comp.attr("control", "right") == "left"
    loc2 = _translate(_reverse(facing), 10 + d, 10 if left_handed else -10)
    ports = [Pin(0, 0, "out", "Y", width),
             Pin(loc1[0], loc1[1], "in", "A", width),
             Pin(loc2[0], loc2[1], "in", "nCTRL", 1)]
    if facing == "north":
        box = (-10, 0, 20, w)
    elif facing == "south":
        box = (-10, -w, 20, w)
    elif facing == "west":
        box = (0, -10, w, 20)
    else:
        box = (-w, -10, w, 20)
    return ports, box


def _ports_controlled_buffer(comp, facing):
    return _controlled_geometry(comp, facing, False)[0]


def _bounds_controlled_buffer(comp, facing):
    return _controlled_geometry(comp, facing, False)[1]


def _ports_controlled_inverter(comp, facing):
    return _controlled_geometry(comp, facing, True)[0]


def _bounds_controlled_inverter(comp, facing):
    return _controlled_geometry(comp, facing, True)[1]


# -- wiring library --------------------------------------------------------------------

def _ports_pin(comp, facing):
    width = comp.attr_int("width", 1)
    # an `output` pin is a *sink* inside the circuit, an input pin is a driver
    kind = "in" if comp.pin_is_output() else "out"
    return [Pin(0, 0, kind, comp.attr("label", "") or "PIN", width)]


def _probe_box(facing, bits):
    ln = 1 if bits <= 1 else bits + (bits - 1) // 4
    if ln <= 2:
        x, y, w, h = -20, -10, 20, 20
    elif ln <= 8:
        x, y, w, h = -10 * ln, -10, 10 * ln, 20
    elif ln <= 16:
        x, y, w, h = -80, -20, 80, 40
    elif ln <= 24:
        x, y, w, h = -80, -30, 80, 60
    else:
        x, y, w, h = -80, -40, 80, 80
    if facing == "east":
        return (x, y, w, h)
    if facing == "west":
        return (0, y, w, h)
    if facing == "north":
        return (y, x, h, w)
    return (y, -x - w, h, w)


def _bounds_pin(comp, facing):
    return _probe_box(facing, comp.attr_int("width", 1))


def _ports_probe(comp, facing):
    return [Pin(0, 0, "in", "P", comp.attr_int("width", 1))]


def _bounds_probe(comp, facing):
    return _probe_box(facing, comp.attr_int("width", 16))


def _ports_tunnel(comp, facing):
    return [Pin(0, 0, "link", comp.attr("label", "") or "T", comp.attr_int("width", 1))]


def _bounds_tunnel(comp, facing):
    label = comp.attr("label", "") or ""
    size = font_size(comp.attr("font", "SansSerif plain 12"))
    w = max(10, size * len(label) // 2) + 6
    h = max(10, size) + 6
    return (-w // 2, -h // 2, w, h)


def _constant_box(comp, facing):
    bits = comp.attr_int("width", 1)
    chars = (bits + 3) // 4
    if facing in ("east", "west"):
        if chars <= 2:
            w, h = 16, 16
        else:
            w, h = 6 + 10 * chars, 16
        return (-w, -8, w, h) if facing == "east" else (0, -8, w, h)
    if chars <= 2:
        w, h = 16, 16
    else:
        w, h = 6 + 10 * chars, 16
    return (-8, 0, w, h) if facing == "north" else (-8, -h, w, h)


def _ports_constant(comp, facing):
    return [Pin(0, 0, "out", "C", comp.attr_int("width", 1))]


def _bounds_constant(comp, facing):
    return _constant_box(comp, facing)


def _ports_clock(comp, facing):
    return [Pin(0, 0, "out", comp.attr("label", "") or "CLK", 1)]


def _bounds_clock(comp, facing):
    return _probe_box(facing, 1)


def _ports_ground(comp, facing):
    return [Pin(0, 0, "out", "GND", comp.attr_int("width", 1))]


def _bounds_ground(comp, facing):
    return bounds_rotate_east(0, -8, 14, 16, facing)


def _ports_power(comp, facing):
    return [Pin(0, 0, "out", "VCC", comp.attr_int("width", 1))]


def _bounds_power(comp, facing):
    return bounds_rotate_east(0, -8, 15, 16, facing)


def _ports_pull(comp, facing):
    return [Pin(0, 0, "bidir", "PULL", 1)]


def _bounds_pull(comp, facing):
    if facing == "east":
        return (-42, -6, 42, 12)
    if facing == "west":
        return (0, -6, 42, 12)
    if facing == "north":
        return (-6, 0, 12, 42)
    return (-6, -42, 12, 42)


def _transistor_offsets(comp, facing):
    dx = {"north": 0, "east": -1, "south": 0, "west": 1}[facing]
    dy = {"north": 1, "east": 0, "south": -1, "west": 0}[facing]
    if comp.dialect == "evolution":
        # logisim-evolution: StdAttr.SELECT_LOC (`selloc`, default "tr")
        top_right = comp.attr("selloc", "tr") == "tr"
        flip = (facing in ("north", "west")) == top_right
    else:
        # classic Logisim 2.7.1: Wiring.ATTR_GATE (`gate`, default "tl")
        top_left = comp.attr("gate", "tl") == "tl"
        flip = (facing in ("south", "west")) == top_left
    if flip:
        gx, gy = (20 * (dx + dy), 20 * (-dx + dy))
    else:
        gx, gy = (20 * (dx - dy), 20 * (dx + dy))
    return dx, dy, (gx, gy)


def _ports_transistor(comp, facing):
    width = comp.attr_int("width", 1)
    dx, dy, gate = _transistor_offsets(comp, facing)
    return [Pin(0, 0, "bidir", "S", width),
            Pin(40 * dx, 40 * dy, "bidir", "D", width),
            Pin(gate[0], gate[1], "in", "G", 1)]


def _bounds_transistor(comp, facing):
    if comp.dialect == "evolution":
        delta = 20 if comp.attr("selloc", "tr") == "tr" else 0
        if facing == "north":
            return (-20 + delta, 0, 20, 40)
        if facing == "south":
            return (-20 + delta, -40, 20, 40)
        if facing == "west":
            return (0, -delta, 40, 20)
        return (-40, -delta, 40, 20)
    delta = -20 if comp.attr("gate", "tl") == "tl" else 0
    if facing == "north":
        return (delta, 0, 20, 40)
    if facing == "south":
        return (delta, -40, 20, 40)
    if facing == "west":
        return (0, delta, 40, 20)
    return (-40, delta, 40, 20)


def _ports_transgate(comp, facing):
    width = comp.attr_int("width", 1)
    dx, dy, gate = _transistor_offsets(comp, facing)
    flip = (facing in ("south", "west")) == (comp.attr("gate", "tl") == "tl")
    g1 = (20 * (dx - dy), 20 * (dx + dy))
    g0 = (20 * (dx + dy), 20 * (-dx + dy))
    if flip:
        g0, g1 = g1, g0
    return [Pin(0, 0, "bidir", "S", width),
            Pin(40 * dx, 40 * dy, "bidir", "D", width),
            Pin(g0[0], g0[1], "in", "G0", 1),
            Pin(g1[0], g1[1], "in", "G1", 1)]


def _bounds_transgate(comp, facing):
    base = bounds_rotate_east(0, -20, 40, 40, "west")
    return bounds_rotate_east(base[0], base[1], base[2], base[3], facing)


def _ports_bitextender(comp, facing):
    in_w = comp.attr_int("in_width", 8)
    out_w = comp.attr_int("out_width", 16)
    ports = [Pin(0, 0, "out", "Y", out_w), Pin(-40, 0, "in", "A", in_w)]
    if comp.attr("type", "zero") == "input":
        ports.append(Pin(-20, -20, "in", "CTRL", 1))
    return ports


def _bounds_bitextender(comp, facing):
    return (-40, -20, 40, 40)


def _splitter_ends(comp, facing):
    """SplitterParameters: the split ends, encoded verbatim from the source."""
    fanout = max(1, comp.attr_int("fanout", 2))
    appear = comp.attr("appear", "left")
    justify = 0 if appear in ("center", "legacy") else (1 if appear == "right" else -1)
    width, offs = 20, 6
    if facing in ("north", "south"):
        m = 1 if facing == "north" else -1
        if justify == 0:
            dx_end0 = 10 * ((fanout + 1) // 2 - 1)
        else:
            dx_end0 = -10 if m * justify < 0 else 10 * fanout
        dy_end0 = -m * width
        ddx, ddy = -10, 0
    else:
        m = -1 if facing == "west" else 1
        dx_end0 = m * width
        if justify == 0:
            dy_end0 = -10 * (fanout // 2)
        else:
            dy_end0 = 10 if m * justify > 0 else -10 * fanout
        ddx, ddy = 0, 10
    return fanout, [(dx_end0 + i * ddx, dy_end0 + i * ddy) for i in range(fanout)]


def _splitter_widths(comp):
    incoming = comp.attr_int("incoming", 2)
    fanout = max(1, comp.attr_int("fanout", 2))
    ends = [0] * (fanout + 1)
    ends[0] = incoming
    for i in range(incoming):
        raw = comp.attr("bit%d" % i, None)
        if raw is None or raw == "none":
            continue
        try:
            target = int(raw) + 1
        except ValueError:
            continue
        if 1 <= target <= fanout:
            ends[target] += 1
    return ends


def _ports_splitter(comp, facing):
    fanout, ends = _splitter_ends(comp, facing)
    widths = _splitter_widths(comp)
    incoming = widths[0]
    ports = [Pin(0, 0, "link", "B", incoming)]
    for i, (dx, dy) in enumerate(ends):
        w = widths[i + 1] if i + 1 < len(widths) else 1
        ports.append(Pin(dx, dy, "link", "B%d" % i, max(1, w)))
    return ports


def _bounds_splitter(comp, facing):
    fanout, ends = _splitter_ends(comp, facing)
    pts = [(0, 0)] + ends
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    return (min(xs), min(ys), max(xs) - min(xs) + 1, max(ys) - min(ys) + 1)


def _ports_text(comp, facing):
    return []


def _bounds_text(comp, facing):
    text = comp.attr("text", "") or ""
    size = font_size(comp.attr("font", "SansSerif plain 12"))
    w = max(size, size * len(text) // 2)
    h = max(size, size)
    halign = comp.attr("halign", "center")
    valign = comp.attr("valign", "base")
    if halign == "left":
        x = 0
    elif halign == "right":
        x = -w
    else:
        x = -w // 2
    if valign == "top":
        y = 0
    elif valign == "bottom":
        y = -h
    else:
        y = -h // 2
    return (x, y, w, h)


def _ports_none(comp, facing):
    return []


def _bounds_none(comp, facing):
    return (0, 0, 0, 0)


# -- plexers ---------------------------------------------------------------------------

def _mux_select_m(comp):
    return 1 if comp.attr("selloc", "bl") == "bl" else -1


def _mux_ports(comp, facing):
    sel_w = max(1, comp.attr_int("select", 1))
    n = 1 << sel_w
    width = comp.attr_int("width", 1)
    enable = comp.attr_bool("enable", True)
    m = _mux_select_m(comp)
    if n == 2:
        table = {
            "east": [(-30, -10), (-30, 10), (-20, 20 * m), (-10, 20 * m)],
            "west": [(30, -10), (30, 10), (20, 20 * m), (10, 20 * m)],
            "north": [(-10, 30), (10, 30), (-20 * m, 20), (-20 * m, 10)],
            "south": [(-10, -30), (10, -30), (-20 * m, -20), (-20 * m, -10)],
        }[facing]
        ins, sel, en = table[:2], table[2], table[3]
    else:
        k = n // 2
        if facing == "east":
            ins = [(-40, -10 * k + 10 * i) for i in range(n)]
            sel = (-20, m * 10 * k)
            en = (-10, sel[1])
        elif facing == "west":
            ins = [(40, -10 * k + 10 * i) for i in range(n)]
            sel = (20, m * 10 * k)
            en = (10, sel[1])
        elif facing == "north":
            ins = [(-10 * k + 10 * i, 40) for i in range(n)]
            sel = (m * (-10 * k), 20)
            en = (sel[0], 10)
        else:
            ins = [(-10 * k + 10 * i, -40) for i in range(n)]
            sel = (m * (-10 * k), -20)
            en = (sel[0], -10)
    ports = [Pin(p[0], p[1], "in", "D%d" % i, width) for i, p in enumerate(ins)]
    ports.append(Pin(sel[0], sel[1], "in", "SEL", sel_w))
    if enable:
        ports.append(Pin(en[0], en[1], "in", "EN", 1))
    ports.append(Pin(0, 0, "out", "Y", width))
    return ports


def _mux_bounds(comp, facing):
    sel_w = max(1, comp.attr_int("select", 1))
    n = 1 << sel_w
    if n == 2:
        return bounds_rotate_east(-30, -20, 30, 40, facing)
    offs = -(n // 2) * 10 - 10
    ln = n * 10 + 20
    return bounds_rotate_east(-40, offs, 40, ln, facing)


def _dmx_ports(comp, facing):
    sel_w = max(1, comp.attr_int("select", 1))
    n = 1 << sel_w
    width = comp.attr_int("width", 1)
    enable = comp.attr_bool("enable", True)
    m = _mux_select_m(comp)
    if n == 2:
        table = {
            "east": [(30, -10), (30, 10), (20, 20 * m), (30, 20 * m)],
            "west": [(-30, -10), (-30, 10), (-20, 20 * m), (-30, 20 * m)],
            "north": [(-10, -30), (10, -30), (-20 * m, -20), (-20 * m, -30)],
            "south": [(-10, 30), (10, 30), (-20 * m, 20), (-20 * m, 30)],
        }[facing]
        outs, sel, en = table[:2], table[2], table[3]
    else:
        k = n // 2
        if facing == "east":
            outs = [(40, -10 * k + 10 * i) for i in range(n)]
            sel = (20, m * 10 * k)
            en = (30, sel[1])
        elif facing == "west":
            outs = [(-40, -10 * k + 10 * i) for i in range(n)]
            sel = (-20, m * 10 * k)
            en = (-30, sel[1])
        elif facing == "north":
            outs = [(-10 * k + 10 * i, -40) for i in range(n)]
            sel = (m * (-10 * k), -20)
            en = (sel[0], -30)
        else:
            outs = [(-10 * k + 10 * i, 40) for i in range(n)]
            sel = (m * (-10 * k), 20)
            en = (sel[0], 30)
    ports = [Pin(p[0], p[1], "out", "Y%d" % i, width) for i, p in enumerate(outs)]
    ports.append(Pin(sel[0], sel[1], "in", "SEL", sel_w))
    if enable:
        ports.append(Pin(en[0], en[1], "in", "EN", 1))
    ports.append(Pin(0, 0, "in", "D", width))
    return ports


def _dmx_bounds(comp, facing):
    sel_w = max(1, comp.attr_int("select", 1))
    n = 1 << sel_w
    if n == 2:
        return bounds_rotate_east(0, -20, 30, 40, facing)
    offs = -(n // 2) * 10 - 10
    ln = n * 10 + 20
    return bounds_rotate_east(0, offs, 40, ln, facing)


def _decoder_ports(comp, facing):
    sel_w = max(1, comp.attr_int("select", 1))
    n = 1 << sel_w
    enable = comp.attr_bool("enable", True)
    tr = comp.attr("selloc", "bl") == "tr"
    flipped = (facing in ("west", "north")) != tr
    if n == 2:
        table = {
            ("east", False): [(10, -30), (10, -10)],
            ("east", True): [(10, 10), (10, 30)],
            ("west", False): [(-10, -30), (-10, -10)],
            ("west", True): [(-10, 10), (-10, 30)],
            ("north", False): [(10, -10), (30, -10)],
            ("north", True): [(-30, -10), (-10, -10)],
            ("south", False): [(10, 10), (30, 10)],
            ("south", True): [(-30, 10), (-10, 10)],
        }[(facing, tr)]
        outs = table
    else:
        outs = []
        for i in range(n):
            if facing in ("east", "west"):
                x = 20 if facing == "east" else -20
                y = (0 if tr else -10 * n) + 10 * i
            else:
                y = -20 if facing == "north" else 20
                x = (-10 * n if tr else 0) + 10 * i
            outs.append((x, y))
    ports = [Pin(p[0], p[1], "out", "Y%d" % i, 1) for i, p in enumerate(outs)]
    ports.append(Pin(0, 0, "in", "SEL", sel_w))
    if enable:
        en = _translate(facing, -10)
        ports.append(Pin(en[0], en[1], "in", "EN", 1))
    return ports


def _decoder_bounds(comp, facing):
    sel_w = max(1, comp.attr_int("select", 1))
    n = 1 << sel_w
    tr = comp.attr("selloc", "bl") == "tr"
    flipped = (facing in ("west", "north")) != tr
    if n == 2:
        return bounds_rotate_east(-20, 0 if flipped else -40, 30, 40, facing)
    return bounds_rotate_east(-20, -10 if flipped else -(n * 10 + 10), 40, n * 10 + 20, facing)


def _prio_encoder_ports(comp, facing):
    sel_w = max(1, comp.attr_int("select", 3))
    n = 1 << sel_w
    ports = []
    if facing in ("north", "south"):
        x = -5 * n + 10
        y = 40 if facing == "north" else -40
        for i in range(n):
            ports.append(Pin(x + 10 * i, y, "in", "I%d" % i, 1))
        ports.append(Pin(0, 0, "out", "A", sel_w))
        ports.append(Pin(x + 10 * n, y // 2, "in", "EI", 1))
        ports.append(Pin(x - 10, y // 2, "out", "EO", 1))
        ports.append(Pin(10, 0, "out", "GS", 1))
    else:
        x = -40 if facing == "east" else 40
        y = -5 * n + 10
        for i in range(n):
            ports.append(Pin(x, y + 10 * i, "in", "I%d" % i, 1))
        ports.append(Pin(0, 0, "out", "A", sel_w))
        ports.append(Pin(x // 2, y + 10 * n, "in", "EI", 1))
        ports.append(Pin(x // 2, y - 10, "out", "EO", 1))
        ports.append(Pin(0, 10, "out", "GS", 1))
    return ports


def _prio_encoder_bounds(comp, facing):
    sel_w = max(1, comp.attr_int("select", 3))
    n = 1 << sel_w
    offs = -5 * n
    ln = 10 * n + 10
    if facing == "east":
        return (-40, offs, 40, ln)
    if facing == "west":
        return (0, offs, 40, ln)
    if facing == "north":
        return (offs, 0, ln, 40)
    return (offs, -40, ln, 40)


def _bit_selector_ports(comp, facing):
    width = comp.attr_int("width", 8)
    group = comp.attr_int("group", 1)
    groups = (width + group - 1) // group - 1
    sel_bits = 1
    g = groups
    while g > 1:
        g >>= 1
        sel_bits += 1
    table = {
        "east": ((-30, 0), (-10, 10)),
        "west": ((30, 0), (10, 10)),
        "north": ((0, 30), (-10, 10)),
        "south": ((0, -30), (-10, -10)),
    }[facing]
    return [Pin(0, 0, "out", "Y", group),
            Pin(table[0][0], table[0][1], "in", "D", width),
            Pin(table[1][0], table[1][1], "in", "SEL", sel_bits)]


def _bit_selector_bounds(comp, facing):
    return bounds_rotate_east(-30, -15, 30, 30, facing)


# -- arithmetic ------------------------------------------------------------------------

def _arith_box(comp, facing):
    return (-40, -20, 40, 40)


def _ports_adder(comp, facing):
    w = comp.attr_int("width", 8)
    return [Pin(-40, -10, "in", "A", w), Pin(-40, 10, "in", "B", w),
            Pin(0, 0, "out", "S", w), Pin(-20, -20, "in", "C_IN", 1),
            # note: 2.7.1 declares C_OUT as an INPUT end; electrically it is an output
            Pin(-20, 20, "out", "C_OUT", 1)]


def _ports_subtractor(comp, facing):
    w = comp.attr_int("width", 8)
    return [Pin(-40, -10, "in", "A", w), Pin(-40, 10, "in", "B", w),
            Pin(0, 0, "out", "S", w), Pin(-20, -20, "in", "B_IN", 1),
            Pin(-20, 20, "out", "B_OUT", 1)]


def _ports_multiplier(comp, facing):
    w = comp.attr_int("width", 8)
    return [Pin(-40, -10, "in", "A", w), Pin(-40, 10, "in", "B", w),
            Pin(0, 0, "out", "Y", w), Pin(-20, -20, "in", "C_IN", w),
            Pin(-20, 20, "out", "C_OUT", w)]


def _ports_divider(comp, facing):
    w = comp.attr_int("width", 8)
    return [Pin(-40, -10, "in", "A", w), Pin(-40, 10, "in", "B", w),
            Pin(0, 0, "out", "Q", w), Pin(-20, -20, "in", "UPPER", w),
            Pin(-20, 20, "out", "REM", w)]


def _ports_negator(comp, facing):
    w = comp.attr_int("width", 8)
    return [Pin(-40, 0, "in", "A", w), Pin(0, 0, "out", "Y", w)]


def _ports_comparator(comp, facing):
    w = comp.attr_int("width", 8)
    return [Pin(-40, -10, "in", "A", w), Pin(-40, 10, "in", "B", w),
            Pin(0, -10, "out", "GT", 1), Pin(0, 0, "out", "EQ", 1),
            Pin(0, 10, "out", "LT", 1)]


def _shift_bits(width):
    bits = 1
    while (1 << bits) < width:
        bits += 1
    return bits


def _ports_shifter(comp, facing):
    w = comp.attr_int("width", 8)
    return [Pin(-40, -10, "in", "D", w), Pin(-40, 10, "in", "S", _shift_bits(w)),
            Pin(0, 0, "out", "Y", w)]


def _ports_bit_adder(comp, facing):
    w = comp.attr_int("width", 8)
    inputs = max(1, comp.attr_int("inputs", 1))
    k = 1
    while (1 << k) <= w * inputs:
        k += 1
    if inputs == 1:
        y0, dy = 0, 10
    elif inputs == 2:
        y0, dy = -10, 20
    elif inputs == 3:
        y0, dy = -10, 10
    else:
        y0 = ((inputs - 1) // 2) * -10
        dy = 10
    ports = [Pin(0, 0, "out", "S", k)]
    for i in range(inputs):
        ports.append(Pin(-40, y0 + i * dy, "in", "I%d" % i, w))
    return ports


def _bounds_bit_adder(comp, facing):
    inputs = max(1, comp.attr_int("inputs", 1))
    if inputs < 4:
        y0 = 20
    else:
        y0 = ((inputs - 1) // 2) * 10 + 5
    h = max(40, 10 * inputs)
    return (-40, -y0, 40, h)


def _ports_bit_finder(comp, facing):
    w = comp.attr_int("width", 8)
    k = 1
    while (1 << k) <= w - 1:
        k += 1
    return [Pin(-20, 20, "out", "FOUND", 1), Pin(0, 0, "out", "INDEX", k),
            Pin(-40, 0, "in", "D", w)]


# -- memory ----------------------------------------------------------------------------

def _ff_ports(comp, facing, data_inputs):
    """AbstractFlipFlop ports; `data_inputs` is 1 for D/T and 2 for J-K/S-R."""
    n = data_inputs
    if n == 1:
        ports = [Pin(-40, 20, "in", "D", 1), Pin(-40, 0, "in", "CLK", 1)]
    else:
        ports = [Pin(-40, 0, "in", "X0", 1), Pin(-40, 20, "in", "X1", 1),
                 Pin(-40, 10, "in", "CLK", 1)]
    ports.append(Pin(0, 0, "out", "Q", 1))
    ports.append(Pin(0, 20, "out", "NQ", 1))
    ports.append(Pin(-10, 30, "in", "CLR", 1))
    ports.append(Pin(-30, 30, "in", "PRE", 1))
    ports.append(Pin(-20, 30, "in", "EN", 1))
    return ports


def _ports_dff(comp, facing):
    return _ff_ports(comp, facing, 1)


def _ports_tff(comp, facing):
    return _ff_ports(comp, facing, 1)


def _ports_jkff(comp, facing):
    return _ff_ports(comp, facing, 2)


def _ports_srff(comp, facing):
    return _ff_ports(comp, facing, 2)


def _bounds_ff(comp, facing):
    return (-40, -10, 40, 40)


def _ports_register(comp, facing):
    w = comp.attr_int("width", 8)
    return [Pin(0, 0, "out", "Q", w), Pin(-30, 0, "in", "D", w),
            Pin(-20, 20, "in", "CLK", 1), Pin(-10, 20, "in", "CLR", 1),
            Pin(-30, 10, "in", "EN", 1)]


def _bounds_register(comp, facing):
    return (-30, -20, 30, 40)


def _ports_counter(comp, facing):
    w = comp.attr_int("width", 8)
    return [Pin(0, 0, "out", "Q", w), Pin(-30, 0, "in", "D", w),
            Pin(-20, 20, "in", "CLK", 1), Pin(-10, 20, "in", "CLR", 1),
            Pin(-30, -10, "in", "LD", 1), Pin(-30, 10, "in", "EN", 1),
            Pin(0, 10, "out", "CARRY", 1)]


def _bounds_counter(comp, facing):
    return (-30, -20, 30, 40)


def _ports_shift_register(comp, facing):
    w = comp.attr_int("width", 1)
    length = max(1, comp.attr_int("length", 8))
    parallel = comp.attr_bool("parallel", True)
    box_w = 20 + 10 * length if parallel else 30
    ports = [Pin(0, 0, "in", "IN", w), Pin(0, -10, "in", "SH", 1),
             Pin(0, 10, "in", "CK", 1), Pin(10, 20, "in", "CLR", 1),
             Pin(box_w, 0, "out", "OUT", w)]
    if parallel:
        ports.append(Pin(10, -20, "in", "LD", 1))
        for i in range(length):
            ports.append(Pin(20 + 10 * i, -20, "in", "TAP%d" % i, w))
            ports.append(Pin(20 + 10 * i, 20, "out", "TAPO%d" % i, w))
    return ports


def _bounds_shift_register(comp, facing):
    length = max(1, comp.attr_int("length", 8))
    if comp.attr_bool("parallel", True):
        return (0, -20, 20 + 10 * length, 40)
    return (0, -20, 30, 40)


def _mem_ports(comp, facing):
    aw = comp.attr_int("addrWidth", 8)
    dw = comp.attr_int("dataWidth", 8)
    ports = [Pin(0, 0, "bidir", "DATA", dw), Pin(-140, 0, "in", "ADDR", aw),
             Pin(-90, 40, "in", "CS", 1)]
    if comp.name == "RAM":
        bus = comp.attr("bus", "combined")
        if bus == "combined":
            ports += [Pin(-50, 40, "in", "OE", 1), Pin(-30, 40, "in", "CLR", 1),
                      Pin(-70, 40, "in", "CLK", 1)]
        elif bus == "asynch":
            ports += [Pin(-50, 40, "in", "OE", 1), Pin(-30, 40, "in", "CLR", 1)]
        else:
            ports += [Pin(-50, 40, "in", "OE", 1), Pin(-30, 40, "in", "CLR", 1),
                      Pin(-70, 40, "in", "CLK", 1), Pin(-110, 40, "in", "WE", 1),
                      Pin(-140, 20, "in", "DIN", dw)]
    return ports


def _bounds_mem(comp, facing):
    return (-140, -40, 140, 80)


def _ports_random(comp, facing):
    w = comp.attr_int("width", 8)
    return [Pin(0, 0, "out", "Q", w), Pin(-20, 20, "in", "CLK", 1),
            Pin(-10, 20, "in", "CLR", 1), Pin(-30, 20, "in", "EN", 1),
            Pin(-30, 0, "in", "SEED", w)]


# -- I/O -------------------------------------------------------------------------------

def _ports_button(comp, facing):
    return [Pin(0, 0, "out", comp.attr("label", "") or "BTN", 1)]


def _bounds_button(comp, facing):
    return bounds_rotate_east(-20, -10, 20, 20, facing)


def _ports_led(comp, facing):
    return [Pin(0, 0, "in", comp.attr("label", "") or "LED", 1)]


def _bounds_led(comp, facing):
    base = bounds_rotate_east(0, -10, 20, 20, "west")
    return bounds_rotate_east(base[0], base[1], base[2], base[3], facing)


def _ports_hex_digit(comp, facing):
    return [Pin(0, 0, "in", "D", 4), Pin(10, 0, "in", "DP", 1)]


def _bounds_hex_digit(comp, facing):
    return (-15, -60, 40, 60)


def _ports_seven_segment(comp, facing):
    coords = [(20, 0), (30, 0), (20, 60), (10, 60), (0, 60), (10, 0), (0, 0), (30, 60)]
    return [Pin(x, y, "in", "S%d" % i, 1) for i, (x, y) in enumerate(coords)]


def _bounds_seven_segment(comp, facing):
    return (-5, 0, 40, 60)


def _ports_dot_matrix(comp, facing):
    cols = max(1, comp.attr_int("matrixcols", 5))
    rows = max(1, comp.attr_int("matrixrows", 7))
    mode = comp.attr("inputtype", "column")
    if mode == "column":
        return [Pin(10 * i, 0, "in", "C%d" % i, rows) for i in range(cols)]
    if mode == "row":
        return [Pin(0, 10 * i, "in", "R%d" % i, cols) for i in range(rows)]
    ports = [Pin(0, 0, "in", "SEL", cols)]
    if rows > 1:
        ports.append(Pin(0, 10, "in", "SEL2", rows))
    return ports


def _bounds_dot_matrix(comp, facing):
    cols = max(1, comp.attr_int("matrixcols", 5))
    rows = max(1, comp.attr_int("matrixrows", 7))
    mode = comp.attr("inputtype", "column")
    if mode == "column":
        return (-5, -10 * rows, 10 * cols, 10 * rows)
    if mode == "row":
        return (0, -5, 10 * cols, 10 * rows)
    if rows == 1:
        return (0, -5, 10 * cols, 10)
    return (0, -5 * rows + 5, 10 * cols, 10 * rows)


def _ports_noconnect(comp, facing):
    return []


# -- geometry registry -----------------------------------------------------------------

_PORT_BUILDERS = {
    "NOT Gate": _ports_not,
    "Buffer": _ports_buffer,
    "AND Gate": _ports_gate,
    "OR Gate": _ports_gate,
    "NAND Gate": _ports_nand,
    "NOR Gate": _ports_nand,
    "XOR Gate": _ports_xor,
    "XNOR Gate": _ports_xnor,
    "Odd Parity": _ports_gate,
    "Even Parity": _ports_gate,
    "Controlled Buffer": _ports_controlled_buffer,
    "Controlled Inverter": _ports_controlled_inverter,
    "Pin": _ports_pin,
    "Probe": _ports_probe,
    "Tunnel": _ports_tunnel,
    "Constant": _ports_constant,
    "Clock": _ports_clock,
    "Ground": _ports_ground,
    "Power": _ports_power,
    "Pull Resistor": _ports_pull,
    "Transistor": _ports_transistor,
    "Transmission Gate": _ports_transgate,
    "Bit Extender": _ports_bitextender,
    "Splitter": _ports_splitter,
    "Text": _ports_text,
    "Multiplexer": _mux_ports,
    "Demultiplexer": _dmx_ports,
    "Decoder": _decoder_ports,
    "Priority Encoder": _prio_encoder_ports,
    "BitSelector": _bit_selector_ports,
    "Adder": _ports_adder,
    "Subtractor": _ports_subtractor,
    "Multiplier": _ports_multiplier,
    "Divider": _ports_divider,
    "Negator": _ports_negator,
    "Comparator": _ports_comparator,
    "Shifter": _ports_shifter,
    "BitAdder": _ports_bit_adder,
    "BitFinder": _ports_bit_finder,
    "D Flip-Flop": _ports_dff,
    "T Flip-Flop": _ports_tff,
    "J-K Flip-Flop": _ports_jkff,
    "S-R Flip-Flop": _ports_srff,
    "Register": _ports_register,
    "Counter": _ports_counter,
    "Shift Register": _ports_shift_register,
    "RAM": _mem_ports,
    "ROM": _mem_ports,
    "Random": _ports_random,
    "Button": _ports_button,
    "LED": _ports_led,
    "Hex Digit Display": _ports_hex_digit,
    "7-Segment Display": _ports_seven_segment,
    "DotMatrix": _ports_dot_matrix,
    "NoConnect": _ports_noconnect,
}

_BOUNDS_BUILDERS = {
    "NOT Gate": _bounds_not,
    "Buffer": _bounds_buffer,
    "AND Gate": _bounds_gate,
    "OR Gate": _bounds_gate,
    "NAND Gate": _bounds_nand,
    "NOR Gate": _bounds_nand,
    "XOR Gate": _bounds_xor,
    "XNOR Gate": _bounds_xnor,
    "Odd Parity": _bounds_gate,
    "Even Parity": _bounds_gate,
    "Controlled Buffer": _bounds_controlled_buffer,
    "Controlled Inverter": _bounds_controlled_inverter,
    "Pin": _bounds_pin,
    "Probe": _bounds_probe,
    "Tunnel": _bounds_tunnel,
    "Constant": _bounds_constant,
    "Clock": _bounds_clock,
    "Ground": _bounds_ground,
    "Power": _bounds_power,
    "Pull Resistor": _bounds_pull,
    "Transistor": _bounds_transistor,
    "Transmission Gate": _bounds_transgate,
    "Bit Extender": _bounds_bitextender,
    "Splitter": _bounds_splitter,
    "Text": _bounds_text,
    "Multiplexer": _mux_bounds,
    "Demultiplexer": _dmx_bounds,
    "Decoder": _decoder_bounds,
    "Priority Encoder": _prio_encoder_bounds,
    "BitSelector": _bit_selector_bounds,
    "Adder": _arith_box,
    "Subtractor": _arith_box,
    "Multiplier": _arith_box,
    "Divider": _arith_box,
    "Negator": _arith_box,
    "Comparator": _arith_box,
    "Shifter": _arith_box,
    "BitAdder": _bounds_bit_adder,
    "BitFinder": _arith_box,
    "D Flip-Flop": _bounds_ff,
    "T Flip-Flop": _bounds_ff,
    "J-K Flip-Flop": _bounds_ff,
    "S-R Flip-Flop": _bounds_ff,
    "Register": _bounds_register,
    "Counter": _bounds_counter,
    "Shift Register": _bounds_shift_register,
    "RAM": _bounds_mem,
    "ROM": _bounds_mem,
    "Random": _bounds_register,
    "Button": _bounds_button,
    "LED": _bounds_led,
    "Hex Digit Display": _bounds_hex_digit,
    "7-Segment Display": _bounds_seven_segment,
    "DotMatrix": _bounds_dot_matrix,
    "NoConnect": _bounds_none,
}


def default_facing(name: str) -> str:
    """Default `facing` per component (Logisim omits attributes equal to the default)."""
    if name in ("Ground", "Pull Resistor", "Tunnel"):
        return "south" if name == "Ground" else ("south" if name == "Pull Resistor" else "west")
    if name == "Power":
        return "north"
    if name == "LED":
        return "west"
    return "east"


def model_ports(comp: Comp, facing: str = None):
    """Return (ports, bbox) for a component, or None when the model does not know it."""
    facing = facing or comp.facing or comp.orig_facing or "east"
    builder = _PORT_BUILDERS.get(comp.name)
    if builder is None or comp.lib == "":
        return None
    try:
        ports = builder(comp, facing)
    except Exception:                     # a model bug must never kill a run
        return None
    bbox_builder = _BOUNDS_BUILDERS.get(comp.name, _bounds_none)
    try:
        bbox = bbox_builder(comp, facing)
    except Exception:
        bbox = _bounds_none(comp, facing)
    return ports, bbox


# ======================================================================================
# .circ parsing
# ======================================================================================

LIB_DESC_RE = re.compile(r"^#")


@dataclass
class Project:
    path: str
    root: object
    tree: object
    source: str
    libs: dict = field(default_factory=dict)
    main: str = ""
    circuits: list = field(default_factory=list)

    @property
    def circuit_names(self):
        return [c.name for c in self.circuits]

    def dialect(self) -> str:
        """'classic' (Logisim 2.x) or 'evolution' (logisim-evolution 3.x/4.x/5.x)."""
        src = (self.source or "").lower()
        if not src:
            return "evolution"
        m = re.match(r"(\d+)\.(\d+)", src)
        if m:
            major, minor = int(m.group(1)), int(m.group(2))
            if major >= 3 or (major == 2 and minor >= 7 and "evo" in src):
                return "evolution"
        return "classic" if src.startswith("2.") else "evolution"


def _elem_attrs(elem) -> dict:
    out = {}
    for a in elem.findall("a"):
        name = a.get("name")
        if name is None:
            continue
        val = a.get("val")
        if val is None:
            val = (a.text or "").strip("\n")
        out[name] = val
    return out


def parse_project(path: str) -> Project:
    tree = ET.parse(path)
    root = tree.getroot()
    libs = {}
    for lib in root.findall("lib"):
        libs[lib.get("name")] = lib.get("desc", "")
    main_el = root.find("main")
    proj = Project(path=path, root=root, tree=tree,
                   source=root.get("source", ""), libs=libs,
                   main=main_el.get("name") if main_el is not None else "")
    dialect = proj.dialect()
    for ce in root.findall("circuit"):
        proj.circuits.append(_parse_circuit(ce, libs, dialect))
    return proj


def _parse_circuit(ce, libs, dialect="classic") -> Circuit:
    circ = Circuit(name=ce.get("name", "?"), elem=ce, attrs=_elem_attrs(ce))
    idx = 0
    for el in ce:
        if el.tag == "wire":
            a, b = parse_loc(el.get("from")), parse_loc(el.get("to"))
            if a is not None and b is not None:
                circ.wires.append((a, b))
        elif el.tag == "comp":
            name = el.get("name", "?")
            lib_key = el.get("lib")
            lib = libs.get(lib_key, "") if lib_key is not None else ""
            loc = parse_loc(el.get("loc")) or (0, 0)
            attrs = _elem_attrs(el)
            comp = Comp(idx=idx, name=name, lib=lib, loc=loc, attrs=attrs, elem=el)
            comp.dialect = dialect
            comp.orig_facing = comp.facing = attrs.get("facing") or default_facing(name)
            comp.label = attrs.get("label", "") or attrs.get("text", "") or ""
            circ.comps.append(comp)
            idx += 1
    return circ


# ======================================================================================
# Netlist extraction
# ======================================================================================

class UnionFind:
    def __init__(self):
        self.parent = {}

    def add(self, item):
        self.parent.setdefault(item, item)

    def find(self, item):
        self.add(item)
        root = item
        while self.parent[root] != root:
            root = self.parent[root]
        while self.parent[item] != root:      # path compression
            self.parent[item], item = root, self.parent[item]
        return root

    def union(self, a, b):
        ra, rb = self.find(a), self.find(b)
        if ra != rb:
            self.parent[ra] = rb

    def groups(self):
        out = defaultdict(list)
        for item in list(self.parent):
            out[self.find(item)].append(item)
        return out


def _bbox_distance(point, box, loc):
    """Distance from `point` to an absolute bounds rectangle (0 when inside)."""
    x, y, w, h = box
    x0, y0 = loc[0] + x, loc[1] + y
    x1, y1 = x0 + w, y0 + h
    px, py = point
    dx = 0 if x0 <= px <= x1 else min(abs(px - x0), abs(px - x1))
    dy = 0 if y0 <= py <= y1 else min(abs(py - y0), abs(py - y1))
    return math.hypot(dx, dy)


def _outline_distance(point, box, loc):
    """Distance from `point` to the *outline* of an absolute rectangle."""
    x, y, w, h = box
    x0, y0 = loc[0] + x, loc[1] + y
    x1, y1 = x0 + w, y0 + h
    px, py = point
    dx = min(abs(px - x0), abs(px - x1))
    dy = min(abs(py - y0), abs(py - y1))
    inside = x0 <= px <= x1 and y0 <= py <= y1
    if inside:
        return min(dx, dy)
    return math.hypot(0 if x0 <= px <= x1 else dx, 0 if y0 <= py <= y1 else dy)


# -- sub-circuits (their box is described by the referenced circuit's appearance) -------

def _shape_bounds(el):
    """Rough bounding box of one `<appear>` shape (enough to plan a layout)."""
    try:
        if el.tag == "rect":
            x, y = int(el.get("x")), int(el.get("y"))
            return (x, y, int(el.get("width")), int(el.get("height")))
        if el.tag == "ellipse":
            cx, cy = float(el.get("cx")), float(el.get("cy"))
            rx, ry = float(el.get("rx")), float(el.get("ry"))
            return (int(cx - rx), int(cy - ry), int(2 * rx), int(2 * ry))
        if el.tag == "line":
            x1, y1 = int(el.get("x1")), int(el.get("y1"))
            x2, y2 = int(el.get("x2")), int(el.get("y2"))
            return (min(x1, x2), min(y1, y2), abs(x2 - x1), abs(y2 - y1))
        if el.tag in ("polygon", "polyline"):
            nums = [float(v) for v in re.split(r"[ ,]+", el.get("points", "").strip()) if v]
            xs, ys = nums[0::2], nums[1::2]
            return (int(min(xs)), int(min(ys)), int(max(xs) - min(xs)), int(max(ys) - min(ys)))
        if el.tag == "path":
            nums = [float(v) for v in re.split(r"[ ,]+", el.get("d", "").strip()) if v]
            xs, ys = nums[1::2], nums[2::2]
            return (int(min(xs)), int(min(ys)), int(max(xs) - min(xs)), int(max(ys) - min(ys)))
        if el.tag == "text":
            x, y = int(el.get("x")), int(el.get("y"))
            size = int(float(el.get("font-size", "12")))
            width = int(size * 0.6 * len(el.text or ""))
            return (x, y - size, width, size + 4)
    except (TypeError, ValueError):
        return None
    return None


def _modal_dx(points) -> int:
    """The x offset shared by most candidate points - the width of an unknown box."""
    hist = Counter(dx for dx, _ in points if dx > 5)
    if not hist:
        return 0
    return hist.most_common(1)[0][0]


def _snap5(value) -> int:
    """Logisim snaps appearance/port coordinates to the nearest multiple of 5."""
    return int(math.floor(float(value) / 5.0 + 0.5)) * 5


def appearance_geometry(ref_elem):
    """Return (anchor, ports, bbox) of a circuit's custom appearance, or None."""
    if ref_elem is None:
        return None
    appear = ref_elem.find("appear")
    if appear is None:
        return None
    anchor = (100, 100)
    ports = []
    boxes = []
    for el in appear:
        if el.tag in ("circ-anchor", "circ-origin"):
            anchor = (_snap5(el.get("x", 100)), _snap5(el.get("y", 100)))
        elif el.tag == "circ-port":
            try:
                ports.append((_snap5(el.get("x", 0)), _snap5(el.get("y", 0)),
                              el.get("pin", ""), el.get("dir", "")))
            except (TypeError, ValueError):
                continue
        else:
            b = _shape_bounds(el)
            if b:
                boxes.append(b)
    if not ports:
        return None
    for x, y, _, _ in ports:
        boxes.append((x, y, 0, 0))
    x0 = min(b[0] for b in boxes)
    y0 = min(b[1] for b in boxes)
    x1 = max(b[0] + b[2] for b in boxes)
    y1 = max(b[1] + b[3] for b in boxes)
    bbox = (x0 - anchor[0], y0 - anchor[1], max(1, x1 - x0), max(1, y1 - y0))
    return anchor, ports, bbox


def default_subcircuit_geometry(ref):
    """Default appearance geometry (DefaultClassicAppearance / DefaultEvolutionAppearance)."""
    edges = {"north": [], "south": [], "east": [], "west": []}
    for pin in ref.comps:
        if not pin.is_pin():
            continue
        facing = pin.attrs.get("facing", "east")
        edge = {"east": "west", "west": "east", "north": "south", "south": "north"}[facing]
        edges[edge].append(pin)
    for key in edges:
        edges[key].sort(key=lambda p: (p.loc[1], p.loc[0]))
    n_n, n_s, n_e, n_w = (len(edges[k]) for k in ("north", "south", "east", "west"))
    max_vert, max_horz = max(n_n, n_s), max(n_e, n_w)

    def dim(this, others):
        if this < 3:
            return 30
        return 10 * this if others == 0 else 10 * this + 10

    def offs(nf, no, mo):
        mt = max(nf, no)
        if mt <= 1:
            base = 15 if mo == 0 else 10
        elif mt == 2:
            base = 10
        else:
            base = 5 if mo == 0 else 10
        return base + 10 * ((mt - nf) // 2)

    width, height = dim(max_vert, max_horz), dim(max_horz, max_vert)
    o_e, o_w = offs(n_e, n_w, max_vert), offs(n_w, n_e, max_vert)
    o_n, o_s = offs(n_n, n_s, max_horz), offs(n_s, n_n, max_horz)
    if n_e > 0:
        ax, ay = width, o_e
    elif n_n > 0:
        ax, ay = o_n, 0
    elif n_w > 0:
        ax, ay = 0, o_w
    elif n_s > 0:
        ax, ay = o_s, height
    else:
        ax = ay = 0
    ports = []
    for i, pin in enumerate(edges["west"]):
        ports.append((pin, (-ax, o_w - ay + 10 * i)))
    for i, pin in enumerate(edges["east"]):
        ports.append((pin, (width - ax, o_e - ay + 10 * i)))
    for i, pin in enumerate(edges["north"]):
        ports.append((pin, (o_n - ax + 10 * i, -ay)))
    for i, pin in enumerate(edges["south"]):
        ports.append((pin, (o_s - ax + 10 * i, height - ay)))
    return ports, (-ax, -ay, width, height)


def subcircuit_ports(comp: Comp, project: Project, facing=None):
    """Exact ports and box of a sub-circuit instance, or None when we cannot tell."""
    ref = next((c for c in project.circuits if c.name == comp.subcircuit), None)
    if ref is None:
        return None
    facing = facing or comp.facing or "east"
    geo = appearance_geometry(ref.elem)
    pin_by_loc = {}
    for pin in ref.comps:
        if pin.is_pin():
            pin_by_loc[pin.loc] = pin
    ports, bbox = [], (0, 0, 0, 0)
    if geo is not None:
        anchor, raw, bbox = geo
        for x, y, pinloc, direction in raw:
            pin = pin_by_loc.get(parse_loc(pinloc))
            off = (x - anchor[0], y - anchor[1])
            kind = "in" if (direction == "in" or (pin is not None and
                                                  not pin.pin_is_output())) else "out"
            width = pin.attr_int("width", 1) if pin is not None else 1
            name = (pin.label if pin is not None and pin.label else "P%d" % len(ports))
            ports.append((rotate_point(off[0], off[1], facing), kind, name, width))
        bbox = bounds_rotate_east(bbox[0], bbox[1], bbox[2], bbox[3], facing)
    else:
        raw, bbox = default_subcircuit_geometry(ref)
        for pin, off in raw:
            kind = "out" if pin.pin_is_output() else "in"
            ports.append((rotate_point(off[0], off[1], facing), kind,
                          pin.label or ("P%d" % len(ports)), pin.attr_int("width", 1)))
        bbox = bounds_rotate_east(bbox[0], bbox[1], bbox[2], bbox[3], facing)
    out = []
    for off, kind, name, width in ports:
        out.append(Pin(off[0], off[1], kind, name, width))
    return out, bbox, (geo is not None)


def _looks_like_subcircuit(comp: Comp, project: Project) -> bool:
    if comp.lib and LIB_DESC_RE.match(comp.lib):
        return False
    return comp.name in project.circuit_names


def build_netlist(circ: Circuit, project: Project):
    """Attach ports to every component and extract the physical/logical nets."""
    for comp in circ.comps:
        comp.subcircuit = comp.name if _looks_like_subcircuit(comp, project) else ""
        res = model_ports(comp)
        if res is None and comp.subcircuit:
            sub = subcircuit_ports(comp, project)
            if sub is not None:
                res = (sub[0], sub[1])
                comp.exact = sub[2]
        if res is not None:
            comp.ports, comp.bbox = res
            comp.modelled = True
        else:
            comp.ports, comp.bbox = [], (0, 0, 0, 0)
            comp.modelled = False
        # the footprint used to decide "does this wire end touch that cell" is the pin
        # hull, not the full drawing box (labels stick out of the box and would steal
        # wire ends that belong to the neighbours)
        if comp.ports:
            xs = [p.dx for p in comp.ports]
            ys = [p.dy for p in comp.ports]
            comp.pin_hull = (min(xs) - 5, min(ys) - 5,
                             max(xs) - min(xs) + 10, max(ys) - min(ys) + 10)
        else:
            comp.pin_hull = comp.bbox

    uf = UnionFind()
    for a, b in circ.wires:
        uf.union(a, b)
    wire_points = set()
    for a, b in circ.wires:
        wire_points.add(a)
        wire_points.add(b)

    claims = defaultdict(list)          # absolute point -> [(comp, port index)]
    for comp in circ.comps:
        for i, port in enumerate(comp.ports):
            point = (comp.loc[0] + port.dx, comp.loc[1] + port.dy)
            uf.add(point)
            claims[point].append((comp, i))

    # -- inference for connections the geometry model does not know about -------------
    # Only *dangling* wire ends can be component pins: a point shared by two wires is
    # an ordinary wire vertex (Logisim connects wires only at shared endpoints).
    degree = Counter()
    for a, b in circ.wires:
        degree[a] += 1
        degree[b] += 1

    inferred = defaultdict(list)
    stray = []
    pending = [p for p in wire_points if p not in claims and degree[p] == 1]

    def _add_inferred(comp, point):
        off = (point[0] - comp.loc[0], point[1] - comp.loc[1])
        kind, name, width = "unknown", "?", 0
        if comp.is_pin():
            kind = "in" if comp.attr_bool("output", False) else "out"
            name = comp.attr("label", "") or "PIN"
            width = comp.attr_int("width", 1)
        elif comp.is_tunnel():
            kind, name, width = "link", comp.attr("label", "") or "T", comp.attr_int("width", 1)
        else:
            near = None
            for port in comp.ports:
                d = abs(port.dx - off[0]) + abs(port.dy - off[1])
                if near is None or d < near[0]:
                    near = (d, port)
            if near is not None and near[0] <= 20:
                kind, name, width = near[1].kind, near[1].name, near[1].width
        pin = Pin(off[0], off[1], kind, name, width)
        if pin.offset in {(p.dx, p.dy) for p in comp.ports}:
            return
        comp.ports.append(pin)
        uf.add(point)
        claims.setdefault(point, []).append((comp, len(comp.ports) - 1))

    # pass 1: cells whose geometry model we trust - the pin must sit on their box.
    # A coarse spatial hash keeps this linear-ish for the big circuits.
    rest = []
    mismatch_types = Counter()
    cell = 100
    grid = defaultdict(list)
    candidates = [c for c in circ.comps if c.modelled and c.ports and not c.exact]
    for comp in candidates:
        x, y, w, h = comp.pin_hull
        gx0 = int(math.floor((comp.loc[0] + x - 25) / cell))
        gx1 = int(math.floor((comp.loc[0] + x + w + 25) / cell))
        gy0 = int(math.floor((comp.loc[1] + y - 25) / cell))
        gy1 = int(math.floor((comp.loc[1] + y + h + 25) / cell))
        for gx in range(gx0, gx1 + 1):
            for gy in range(gy0, gy1 + 1):
                grid[(gx, gy)].append(comp)
    for point in pending:
        local = grid.get((int(math.floor(point[0] / cell)),
                          int(math.floor(point[1] / cell))), ())
        best, best_d, best_origin = None, 1e9, 1e9
        for comp in local:
            # a wire end belongs to a modelled cell only if it lands on one of that
            # cell's pins (at most half a grid step off) - anything else stays stray
            near = min(max(abs(point[0] - (comp.loc[0] + p.dx)),
                           abs(point[1] - (comp.loc[1] + p.dy))) for p in comp.ports)
            if near > 5:
                continue
            d = float(near)
            dloc = math.hypot(point[0] - comp.loc[0], point[1] - comp.loc[1])
            if (d, dloc) < (best_d, best_origin):
                best, best_d, best_origin = comp, d, dloc
        if best is None:
            rest.append(point)
        else:
            before = len(best.ports)
            _add_inferred(best, point)
            if len(best.ports) != before:
                best.infer_ports = True
                mismatch_types[best.name] += 1

    # pass 2: sub-circuit instances - Logisim anchors their box at `loc`; inputs sit on
    # the west edge (dx == 0), outputs on the east edge (dx == box width).  A dangling
    # wire is a pin of the instance only if it lies on one of those two lines, and no
    # instance may receive more pins per side than the referenced circuit declares.
    sub_cells = [c for c in circ.comps if not c.modelled]
    if sub_cells:
        boxes, expected = {}, {}
        for comp in sub_cells:
            cand = [(p[0] - comp.loc[0], p[1] - comp.loc[1]) for p in rest
                    if -15 <= p[0] - comp.loc[0] <= 2000 and -15 <= p[1] - comp.loc[1] <= 2000]
            boxes[comp] = (_modal_dx(cand), max([c[1] for c in cand] or [0]))
            ref = next((c for c in project.circuits if c.name == comp.subcircuit), None)
            if ref is None:
                expected[comp] = (None, None)
            else:
                pins = [p for p in ref.comps if p.is_pin()]
                expected[comp] = (sum(1 for p in pins if not p.pin_is_output()),
                                  sum(1 for p in pins if p.pin_is_output()))
        counts = defaultdict(int)
        for _ in range(3):
            assignment = defaultdict(list)
            counts = defaultdict(int)
            for point in sorted(rest, key=lambda p: (p[1], p[0])):
                best, best_key, best_side = None, None, None
                for comp in sub_cells:
                    dx, dy = point[0] - comp.loc[0], point[1] - comp.loc[1]
                    w, h = boxes[comp]
                    if dy < -15 or dy > h + 20:
                        continue
                    if abs(dx) <= 5:
                        side = "w"
                    elif w > 5 and abs(dx - w) <= 5:
                        side = "e"
                    else:
                        continue
                    limit = expected[comp][0 if side == "w" else 1]
                    if limit is not None and counts[(comp, side)] >= limit:
                        continue
                    key = (max(1, w) * max(1, h + 10), dx + dy)
                    if best_key is None or key < best_key:
                        best, best_key, best_side = comp, key, side
                if best is None:
                    continue
                assignment[best].append(point)
                counts[(best, best_side)] += 1
            changed = False
            for comp in sub_cells:
                pts = [(p[0] - comp.loc[0], p[1] - comp.loc[1])
                       for p in assignment.get(comp, ())]
                if not pts:
                    continue
                new_box = (_modal_dx(pts), max(p[1] for p in pts))
                if new_box != boxes[comp]:
                    boxes[comp] = new_box
                    changed = True
            if not changed:
                break
        for comp in sub_cells:
            for point in assignment.get(comp, ()):
                _add_inferred(comp, point)
        assigned_points = {p for pts in assignment.values() for p in pts}
        stray.extend([p for p in rest if p not in assigned_points])

    # direction of sub-circuit pins: west edge = input, east edge = output
    for comp in sub_cells:
        if not comp.ports:
            continue
        max_dx = max(p.dx for p in comp.ports)
        ref = next((c for c in project.circuits if c.name == comp.subcircuit), None)
        ref_in, ref_out = [], []
        if ref is not None:
            for pin in ref.comps:
                if pin.is_pin():
                    (ref_out if pin.pin_is_output() else ref_in).append(pin)
            ref_in.sort(key=lambda p: (p.loc[1], p.loc[0]))
            ref_out.sort(key=lambda p: (p.loc[1], p.loc[0]))
        west = sorted([p for p in comp.ports if p.dx <= 5], key=lambda p: p.dy)
        east = sorted([p for p in comp.ports if max_dx > 5 and p.dx >= max_dx - 5],
                      key=lambda p: p.dy)
        for i, port in enumerate(west):
            port.kind = "in"
            if i < len(ref_in):
                port.width = ref_in[i].attr_int("width", 1)
                port.name = ref_in[i].label or ("I%d" % i)
        for i, port in enumerate(east):
            port.kind = "out"
            if i < len(ref_out):
                port.width = ref_out[i].attr_int("width", 1)
                port.name = ref_out[i].label or ("O%d" % i)

    if mismatch_types:
        circ.warnings.append(
            "geometry model fallback used for: %s"
            % ", ".join("%s x%d" % (k, v) for k, v in sorted(mismatch_types.items())))
    if stray:
        circ.warnings.append("%d dangling wire end(s) do not touch any cell and were dropped"
                             % len(stray))

    # -- sub-circuit boxes: keep a sensible footprint --------------------------------
    for comp in circ.comps:
        if comp.ports and (not comp.modelled or comp.bbox == (0, 0, 0, 0)):
            xs = [p.dx for p in comp.ports] + [0]
            ys = [p.dy for p in comp.ports] + [0]
            pad = 10
            comp.bbox = (min(xs) - (pad if min(xs) < 0 else 0),
                         min(ys) - (pad if min(ys) < 0 else 0),
                         max(xs) - min(xs) + pad, max(ys) - min(ys) + pad)

    # -- nets -----------------------------------------------------------------------
    nets = []
    net_of_root = {}
    for root, points in sorted(uf.groups().items(), key=lambda kv: str(kv[0])):
        members = []
        for p in points:
            members.extend(claims.get(p, ()))
        if not members:
            continue
        net = Net(idx=len(nets), members=members)
        nets.append(net)
        net_of_root[root] = net
    circ.nets = nets

    for net in nets:
        for comp, i in net.members:
            port = comp.ports[i]
            if port.kind == "out":
                net.drivers.append((comp, i))
            elif port.kind == "in":
                net.sinks.append((comp, i))
            elif port.kind in ("bidir", "link", "unknown"):
                net.bidir.append((comp, i))
            if comp.is_pin():
                if comp.pin_is_output():
                    net.external_out.append((comp, i))
                else:
                    net.external_in.append((comp, i))
        widths = [comp.ports[i].width for comp, i in net.members if comp.ports[i].width > 0]
        net.width = max(widths) if widths else 0
        for comp, i in net.members:
            if comp.ports[i].width <= 0:
                comp.ports[i].width = net.width or 1
        if net.width == 0:
            net.width = 1

    _merge_logical_nets(circ)
    _name_nets(circ)
    return circ


def _merge_logical_nets(circ: Circuit):
    """Tunnels join nets by label; that is a *logical* union, not a physical one."""
    uf = UnionFind()
    by_label = defaultdict(list)
    for net in circ.nets:
        uf.add(net.idx)
        for comp, _ in net.members:
            if comp.is_tunnel() and comp.label.strip():
                by_label[comp.label.strip()].append(net.idx)
    for label, ids in by_label.items():
        for other in ids[1:]:
            uf.union(ids[0], other)
    groups = defaultdict(list)
    for net in circ.nets:
        groups[uf.find(net.idx)].append(net)
    circ.logical_nets = []
    for gid, group in enumerate(sorted(groups.values(), key=lambda g: g[0].idx)):
        names = sorted({c.label.strip() for net in group for c, _ in net.members
                        if c.is_tunnel() and c.label.strip()})
        logical = {"idx": gid, "nets": [n.idx for n in group],
                   "name": names[0] if names else "",
                   "label": "/".join(names)}
        for net in group:
            net.logical = gid
        circ.logical_nets.append(logical)


def _name_nets(circ: Circuit):
    """Give every net a human-readable name (tunnel label, pin label, or n<idx>)."""
    for net in circ.nets:
        name = ""
        for comp, _ in net.members:
            if comp.is_tunnel() and comp.label.strip():
                name = comp.label.strip()
                break
        if not name:
            for comp, _ in net.members:
                if comp.is_pin() and comp.label:
                    name = comp.label
                    break
        net.label = name or ("n%d" % net.idx)


# ======================================================================================
# Analysis: dependency graph, topological order, cycles, statistics
# ======================================================================================

GATE_NAMES = ("NOT Gate", "Buffer", "AND Gate", "OR Gate", "NAND Gate", "NOR Gate",
              "XOR Gate", "XNOR Gate", "Odd Parity", "Even Parity",
              "Controlled Buffer", "Controlled Inverter")


def _tarjan_scc(nodes, succ):
    """Iterative Tarjan - the big circuits (1700+ cells) would blow a recursive version."""
    index = {}
    low = {}
    on_stack = set()
    stack = []
    result = []
    counter = [0]

    for start in sorted(nodes):
        if start in index:
            continue
        work = [(start, iter(sorted(succ.get(start, ()))))]
        index[start] = low[start] = counter[0]
        counter[0] += 1
        stack.append(start)
        on_stack.add(start)
        while work:
            node, it = work[-1]
            advanced = False
            for nxt in it:
                if nxt not in index:
                    index[nxt] = low[nxt] = counter[0]
                    counter[0] += 1
                    stack.append(nxt)
                    on_stack.add(nxt)
                    work.append((nxt, iter(sorted(succ.get(nxt, ())))))
                    advanced = True
                    break
                if nxt in on_stack:
                    low[node] = min(low[node], index[nxt])
            if advanced:
                continue
            work.pop()
            if work:
                parent = work[-1][0]
                low[parent] = min(low[parent], low[node])
            if low[node] == index[node]:
                comp = []
                while True:
                    w = stack.pop()
                    on_stack.discard(w)
                    comp.append(w)
                    if w == node:
                        break
                result.append(sorted(comp))
    return result


def analyze_circuit(circ: Circuit):
    """Topologically sort the circuit and collect the statistics we report."""
    succ = defaultdict(set)
    pred = defaultdict(set)
    for net in circ.nets:
        drivers = [c.idx for c, _ in net.drivers]
        sinks = [c.idx for c, _ in net.sinks]
        for d in drivers:
            for s in sinks:
                if d != s:
                    succ[d].add(s)
                    pred[s].add(d)

    nodes = [c.idx for c in circ.comps]
    by_idx = {c.idx: c for c in circ.comps}
    sccs = _tarjan_scc(nodes, succ)
    comp_scc = {}
    for i, scc in enumerate(sccs):
        for n in scc:
            comp_scc[n] = i

    # condensation in topological order
    scc_succ = defaultdict(set)
    scc_pred = defaultdict(set)
    for a, targets in succ.items():
        for b in targets:
            if comp_scc[a] != comp_scc[b]:
                scc_succ[comp_scc[a]].add(comp_scc[b])
                scc_pred[comp_scc[b]].add(comp_scc[a])
    order = []
    pending = {i: len(scc_pred[i]) for i in range(len(sccs))}
    ready = sorted([i for i, d in pending.items() if d == 0])
    while ready:
        cur = ready.pop(0)
        order.append(cur)
        for nxt in sorted(scc_succ[cur]):
            pending[nxt] -= 1
            if pending[nxt] == 0:
                ready.append(nxt)
        ready.sort()
    if len(order) != len(sccs):                       # defensive: keep every SCC
        order += [i for i in range(len(sccs)) if i not in order]

    level = {}
    for scc_i in order:
        base = 0
        for p in scc_pred[scc_i]:
            base = max(base, level.get(p, 0) + 1)
        level[scc_i] = base
    for comp in circ.comps:
        comp.level = level.get(comp_scc.get(comp.idx, 0), 0)

    # components that carry no direction (tunnels, splitters, transistors, ...) inherit
    # the level of their neighbours so that they are not all piled up in column 0
    for _ in range(3):
        changed = False
        for net in circ.nets:
            members = [c for c, _ in net.members]
            if len(members) < 2:
                continue
            for comp in members:
                if comp.idx in succ or comp.idx in pred:
                    continue
                best = min((m.level for m in members if m is not comp), default=None)
                if best is not None and best != comp.level:
                    comp.level = best
                    changed = True
        if not changed:
            break

    cycles = []
    for scc in sccs:
        self_loop = any(n in succ.get(n, ()) for n in scc)
        if len(scc) > 1 or self_loop:
            cycles.append(scc)
    circ.cycles = cycles
    circ.levels = {c.idx: c.level for c in circ.comps}
    circ.stats = _circuit_stats(circ, by_idx)
    return circ


def _circuit_stats(circ: Circuit, by_idx: dict) -> dict:
    cell_counts = Counter()
    gate_counts = Counter()
    for comp in circ.comps:
        cell_counts[(comp.lib or "circuit", comp.name)] += 1
        if comp.name in GATE_NAMES:
            gate_counts[comp.name] += 1
        elif comp.name == "Transistor":
            gate_counts["Pass Transistor"] += 1
    buses = [n for n in circ.nets if n.width > 1]
    unnamed = [n for n in circ.nets if n.label.startswith("n") and len(n.members) > 1]
    conflicting = [n for n in circ.nets if len(n.drivers) > 1]
    unconnected = [c for c in circ.comps if not c.ports]
    inputs = [c for c in circ.comps if c.is_pin() and not c.pin_is_output()]
    outputs = [c for c in circ.comps if c.is_pin() and c.pin_is_output()]
    return {
        "cells": cell_counts,
        "gates": gate_counts,
        "n_cells": len(circ.comps),
        "n_wires": len(circ.wires),
        "n_nets": len(circ.nets),
        "n_buses": len(buses),
        "n_cycles": len(circ.cycles),
        "n_inputs": len(inputs),
        "n_outputs": len(outputs),
        "n_conflicting": len(conflicting),
        "n_unnamed": len(unnamed),
        "max_level": max((c.level for c in circ.comps), default=0),
        "unconnected": unconnected,
        "inputs": inputs,
        "outputs": outputs,
        "conflicting": conflicting,
    }


def net_terminals(circ: Circuit, net: Net):
    """Absolute pin positions of a net's members (after layout when available)."""
    out = []
    for comp, i in net.members:
        port = comp.ports[i]
        base = comp.new_loc or comp.loc
        out.append(((base[0] + port.dx, base[1] + port.dy), comp, i))
    return out


def pin_side(comp: Comp, port: Pin):
    """Which edge of the component's box the pin sits on."""
    x, y, w, h = comp.bbox
    if w <= 0 and h <= 0:
        return "east"
    dl = abs(port.dx - x)
    dr = abs(port.dx - (x + w))
    dt = abs(port.dy - y)
    db = abs(port.dy - (y + h))
    best = min(dl, dr, dt, db)
    if best == dr:
        return "east"
    if best == dl:
        return "west"
    if best == dt:
        return "north"
    return "south"


# ======================================================================================
# Layout: topological columns, crossing-reduced rows, then channel routing
# ======================================================================================

@dataclass(eq=False)
class Sheet:
    """The geometric plan of one routed schematic."""
    circ: object
    ncols: int = 0
    nrows: int = 0
    col_width: list = field(default_factory=list)
    row_height: list = field(default_factory=list)
    gap_width: list = field(default_factory=list)
    chan_height: list = field(default_factory=list)
    col_x: list = field(default_factory=list)
    row_y: list = field(default_factory=list)
    gap_x0: list = field(default_factory=list)
    chan_y: list = field(default_factory=list)
    width: int = 0
    height: int = 0
    margin: int = 40
    wires: list = field(default_factory=list)
    shorts: list = field(default_factory=list)
    opens: list = field(default_factory=list)
    level_of_col: list = field(default_factory=list)


def _adjacency(circ: Circuit):
    preds = defaultdict(set)
    succs = defaultdict(set)
    for net in circ.nets:
        drivers = [c.idx for c, _ in net.drivers]
        sinks = [c.idx for c, _ in net.sinks]
        for d in drivers:
            for s in sinks:
                if d != s:
                    succs[d].add(s)
                    preds[s].add(d)
    return preds, succs


def _ordered_columns(circ: Circuit, style: dict):
    """Group cells into topological columns and order them to reduce crossings."""
    comps = [c for c in circ.comps]
    for comp in comps:
        if comp.is_pin():
            comp.col = 0 if not comp.pin_is_output() else -1
        else:
            comp.col = comp.level

    max_level = max((c.col for c in comps), default=0)
    out_col = max_level + 1 if style["layout"].get("io_columns", True) else max_level
    for comp in comps:
        if comp.col < 0:
            comp.col = out_col
    min_col = min((c.col for c in comps), default=0)
    for comp in comps:
        comp.col -= min_col

    ncols = max((c.col for c in comps), default=0) + 1
    cols = defaultdict(list)
    for comp in comps:
        cols[comp.col].append(comp)
    for col in cols.values():
        col.sort(key=lambda c: (c.loc[1], c.loc[0], c.idx))

    preds, succs = _adjacency(circ)

    def barycenter(comp, side, row_of):
        neigh = [row_of[n] for n in side.get(comp.idx, ()) if n in row_of]
        return sum(neigh) / len(neigh) if neigh else None

    row_of = {}
    for col in range(ncols):
        for i, comp in enumerate(cols[col]):
            row_of[comp.idx] = i
    for sweep in range(4):
        if sweep % 2 == 0:
            order = range(1, ncols)
            side = preds
        else:
            order = range(ncols - 2, -1, -1)
            side = succs
        for col in order:
            entries = []
            for i, comp in enumerate(cols[col]):
                bc = barycenter(comp, side, row_of)
                entries.append((bc if bc is not None else i, i, comp))
            entries.sort(key=lambda e: (e[0], e[1]))
            cols[col] = [e[2] for e in entries]
            for i, comp in enumerate(cols[col]):
                row_of[comp.idx] = i

    nrows = max((len(cols[c]) for c in range(ncols)), default=1)
    for col in range(ncols):
        for i, comp in enumerate(cols[col]):
            comp.row = i

    # -- fold very long columns so that the sheet keeps a usable aspect ratio ---------
    max_rows = int(style["layout"].get("max_rows", 0) or 0)
    if max_rows <= 0:
        max_rows = max(6, min(48, int(math.sqrt(max(1, len(comps)) * 1.2)) + 1))
    if nrows > max_rows:
        folded = defaultdict(list)
        new_index = 0
        for col in range(ncols):
            items = cols[col]
            for start in range(0, len(items), max_rows):
                folded[new_index] = items[start:start + max_rows]
                new_index += 1
        cols = folded
        ncols = new_index
        nrows = max((len(cols[c]) for c in range(ncols)), default=1)
        for col in range(ncols):
            for i, comp in enumerate(cols[col]):
                comp.col = col
                comp.row = i
    return cols, ncols, nrows


def _terminal_escape(comp: Comp, port: Pin, ncols: int):
    """Where a pin leaves its cell: (gap index, 'L' or 'R')."""
    side = pin_side(comp, port)
    col = comp.col
    if side == "east":
        return min(col + 1, ncols), "L"
    if side == "west":
        return max(col, 0), "R"
    # north/south pins escape to the nearer vertical channel
    cx = comp.bbox[0] + comp.bbox[2] / 2.0
    if port.dx <= cx:
        return max(col, 0), "R"
    return min(col + 1, ncols), "L"


def layout_circuit(circ: Circuit, style: dict, track_pitch=None, lane_pitch=None,
                   channel=None, margin=None) -> Sheet:
    """Plan a new, topologically routed drawing of `circ`."""
    lay = style["layout"]
    lane_pitch = lane_pitch or lay.get("lane_pitch", 10)
    track_pitch = track_pitch or lay.get("track_pitch", 10)
    base_channel = channel or lay.get("channel", 10)
    margin = margin or style["sheet"].get("frame_margin", 40)
    margin = max(margin, 40)

    sheet = Sheet(circ=circ, margin=margin)
    cols, ncols, nrows = _ordered_columns(circ, style)
    sheet.ncols, sheet.nrows = ncols, nrows
    sheet.level_of_col = [min((c.level for c in cols[i]), default=i) for i in range(ncols)]

    # -- escape gaps per net ---------------------------------------------------------
    escapes = {}          # net idx -> list of (comp, i, gap, dir)
    for net in circ.nets:
        items = []
        for comp, i in net.members:
            gap, dirn = _terminal_escape(comp, comp.ports[i], ncols)
            items.append((comp, i, gap, dirn))
        escapes[net.idx] = items

    # -- horizontal tracks: interval colouring inside the chosen channel ---------------
    tracks_by_chan = defaultdict(list)          # chan -> list of [ (gmin,gmax), net_idx ]
    net_track = {}
    net_gspan = {}
    for net in circ.nets:
        items = escapes[net.idx]
        if len(items) < 2:
            continue
        gaps = [g for _, _, g, _ in items]
        gmin, gmax = min(gaps), max(gaps)
        rows = sorted(c.row for c, _, _, _ in items)
        chan = max(0, min(nrows - 1, rows[len(rows) // 2]))
        slot = None
        for si, entry in enumerate(tracks_by_chan[chan]):
            if all(gmax < a or gmin > b for a, b in entry):
                entry.append((gmin, gmax))
                slot = si
                break
        if slot is None:
            tracks_by_chan[chan].append([(gmin, gmax)])
            slot = len(tracks_by_chan[chan]) - 1
        net_track[net.idx] = (chan, slot)
        net_gspan[net.idx] = (gmin, gmax)

    # -- vertical lanes: colour (gap, direction) intervals -----------------------------
    lanes_by_gap = defaultdict(lambda: {"L": [], "R": []})   # gap -> dir -> [ [intervals] ]
    net_lane = {}                                            # (net,gap,dir) -> (dir,slot)
    for net in circ.nets:
        items = escapes[net.idx]
        if len(items) < 2 or net.idx not in net_track:
            continue
        chan, _ = net_track[net.idx]
        by_group = defaultdict(list)
        for comp, i, gap, dirn in items:
            by_group[(gap, dirn)].append(comp.row)
        for (gap, dirn), rows in by_group.items():
            lo = min(rows + [chan])
            hi = max(rows + [chan])
            interval = (2 * lo, 2 * hi + 1)
            slots = lanes_by_gap[gap][dirn]
            placed = None
            for si, entry in enumerate(slots):
                if all(hi2 < interval[0] or lo2 > interval[1] for lo2, hi2 in entry):
                    entry.append(interval)
                    placed = si
                    break
            if placed is None:
                slots.append([interval])
                placed = len(slots) - 1
            net_lane[(net.idx, gap, dirn)] = placed

    # -- band sizes -------------------------------------------------------------------
    sheet.gap_width = []
    for g in range(ncols + 1):
        count = len(lanes_by_gap[g]["L"]) + len(lanes_by_gap[g]["R"])
        sheet.gap_width.append(20 + lane_pitch * count)
    sheet.chan_height = [base_channel + track_pitch * len(tracks_by_chan[r]) for r in range(nrows)]

    col_width, row_height = [], []
    for c in range(ncols):
        bw = max([comp.bbox[2] for comp in cols[c]] or [0])
        col_width.append(snap(bw + lay.get("column_pitch", 30), 10))
    for r in range(nrows):
        bh = 0
        for c in range(ncols):
            for comp in cols[c]:
                if comp.row == r:
                    bh = max(bh, comp.bbox[3])
        row_height.append(snap(bh + lay.get("row_pitch", 20), 10))
    sheet.col_width, sheet.row_height = col_width, row_height

    # -- absolute coordinates ---------------------------------------------------------
    cursor = margin
    sheet.gap_x0 = []
    sheet.col_x = []
    for c in range(ncols):
        sheet.gap_x0.append(cursor)
        cursor += sheet.gap_width[c]
        sheet.col_x.append(cursor)
        cursor += col_width[c]
    sheet.gap_x0.append(cursor)
    cursor += sheet.gap_width[ncols]
    sheet.width = cursor + margin

    cursor = margin
    sheet.row_y = []
    sheet.chan_y = []
    for r in range(nrows):
        sheet.row_y.append(cursor)
        cursor += row_height[r]
        sheet.chan_y.append(cursor)
        cursor += sheet.chan_height[r]
    sheet.height = cursor + margin

    # -- place the cells --------------------------------------------------------------
    for c in range(ncols):
        for comp in cols[c]:
            bx, by, bw, bh = comp.bbox
            px = sheet.col_x[c] + max(0, (col_width[c] - bw) // 2)
            py = sheet.row_y[comp.row] + max(0, (row_height[comp.row] - bh) // 2)
            lx = snap(px - bx, 10)
            ly = snap(py - by, 10)
            slack_x = max(0, (col_width[c] - bw) // 2 // 10) * 10
            slack_y = max(0, (row_height[comp.row] - bh) // 2 // 10) * 10
            lx = min(max(lx, sheet.col_x[c] - bx), sheet.col_x[c] - bx + slack_x)
            ly = min(max(ly, sheet.row_y[comp.row] - by),
                     sheet.row_y[comp.row] - by + slack_y)
            comp.new_loc = (int(lx), int(ly))

    # -- exact track / lane positions --------------------------------------------------
    track_y = {}
    for chan, slots in tracks_by_chan.items():
        y0 = sheet.chan_y[chan] + 10 if sheet.chan_height[chan] > 10 else sheet.chan_y[chan] + 5
        for si in range(len(slots)):
            track_y[(chan, si)] = y0 + si * track_pitch
    lane_x = {}
    for gap, dirs in lanes_by_gap.items():
        base = sheet.gap_x0[gap] + 10
        for dirn, slots in dirs.items():
            offset = 0 if dirn == "L" else len(dirs["L"]) * lane_pitch
            for si in range(len(slots)):
                lane_x[(gap, dirn, si)] = base + offset + si * lane_pitch

    # -- wire generation ---------------------------------------------------------------
    wires = []
    for net in circ.nets:
        items = escapes[net.idx]
        if len(items) < 2 or net.idx not in net_track:
            continue
        chan, slot = net_track[net.idx]
        ty = track_y.get((chan, slot))
        if ty is None:
            continue
        net.track_y = ty
        used_lanes = set()
        for comp, i, gap, dirn in items:
            port = comp.ports[i]
            px = comp.new_loc[0] + port.dx
            py = comp.new_loc[1] + port.dy
            lx = lane_x.get((gap, dirn, net_lane[(net.idx, gap, dirn)]))
            if lx is None:
                continue
            used_lanes.add(lx)
            net.lane_x.setdefault(gap, lx)
            if px != lx:
                wires.append(((px, py), (lx, py)))
            if py != ty:
                wires.append(((lx, py), (lx, ty)))
        xs = sorted(used_lanes)
        for a, b in zip(xs, xs[1:]):
            wires.append(((a, ty), (b, ty)))
    sheet.wires = _dedup_wires(wires)

    sheet.opens, sheet.shorts = verify_routing(circ, sheet.wires)
    return sheet


def _dedup_wires(wires):
    seen = set()
    out = []
    for a, b in wires:
        if a == b:
            continue
        key = (a, b) if a <= b else (b, a)
        if key in seen:
            continue
        seen.add(key)
        out.append(key)
    return out


def verify_routing(circ: Circuit, wires):
    """Re-read the generated wires and check that the net partition is preserved."""
    uf = UnionFind()
    for a, b in wires:
        uf.union(a, b)
    groups = defaultdict(list)
    for net in circ.nets:
        if len(net.members) < 2:
            continue
        for comp, i in net.members:
            port = comp.ports[i]
            base = comp.new_loc or comp.loc
            groups[net.idx].append((base[0] + port.dx, base[1] + port.dy))
    root_owner = {}
    shorts = []
    opens = []
    for net_idx, points in groups.items():
        roots = set()
        for p in points:
            if p not in uf.parent:
                continue
            root = uf.find(p)
            roots.add(root)
            if root in root_owner and root_owner[root] != net_idx:
                shorts.append((root_owner[root], net_idx, p))
            root_owner.setdefault(root, net_idx)
        if len(roots) > 1:
            opens.append(net_idx)
    return sorted(set(opens)), sorted(set(shorts))


# ======================================================================================
# .circ writer
# ======================================================================================

class CircWriter:
    """Writes a routed project back out in the same dialect it was read in.

    The original elements are cloned, so every attribute the source file carried (and
    that we do not deliberately change) survives the round trip - including attributes
    this tool does not understand.  Only `loc` is rewritten for cells, `facing` is
    rewritten for cells we re-oriented, all wires are regenerated, and title texts are
    added.
    """

    def __init__(self, project: Project, style: dict):
        self.project = project
        self.style = style
        self.dialect = project.dialect()

    def _lib_index(self, desc):
        for name, d in self.project.libs.items():
            if d == desc:
                return name
        return None

    def _text_elem(self, text, loc, font, color=None):
        el = ET.Element("comp")
        lib = self._lib_index("#Base")
        if lib is not None:
            el.set("lib", lib)
        el.set("loc", fmt_loc(loc))
        el.set("name", "Text")
        for key, val in (("text", text), ("font", font)):
            a = ET.SubElement(el, "a")
            a.set("name", key)
            a.set("val", val)
        if color and self.dialect == "evolution":
            a = ET.SubElement(el, "a")
            a.set("name", "color")
            a.set("val", color)
        a = ET.SubElement(el, "a")
        a.set("name", "halign")
        a.set("val", "left")
        return el

    def _set_attr(self, elem, name, value):
        for a in elem.findall("a"):
            if a.get("name") == name:
                a.set("val", value)
                if a.text is not None:
                    a.text = None
                return
        a = ET.SubElement(elem, "a")
        a.set("name", name)
        a.set("val", value)

    def write(self, out_path: str, sheets, titles=None, stats=None):
        root = ET.Element("project")
        root.set("version", self.project.root.get("version", "1.0"))
        if self.project.source:
            root.set("source", self.project.source)
        root.text = ("\nThis file was re-planned by LogisimTopoRouter (issue #1391).\n  ")

        for tag in ("lib", "main", "options", "mappings", "toolbar"):
            for el in self.project.root.findall(tag):
                root.append(_deepcopy_elem(el))

        by_name = {sheet.circ.name: sheet for sheet in sheets}
        for sheet in sheets:
            root.append(self._circuit_elem(sheet, titles or {}, stats or {}))

        _indent(root)
        tree = ET.ElementTree(root)
        with open(out_path, "wb") as fh:
            fh.write(b'<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n')
            tree.write(fh, encoding="utf-8", xml_declaration=False)
        return out_path

    def _circuit_elem(self, sheet: Sheet, titles, stats):
        circ = sheet.circ
        ce = ET.Element("circuit")
        ce.set("name", circ.name)
        for child in (circ.elem if circ.elem is not None else []):
            if child.tag in ("comp", "wire"):
                continue
            ce.append(_deepcopy_elem(child))       # <a> attributes and <appear> shapes
        if circ.elem is None or not circ.elem.findall("a"):
            a = ET.SubElement(ce, "a")
            a.set("name", "circuit")
            a.set("val", circ.name)

        for comp in sorted(circ.comps, key=lambda c: (c.col, c.row, c.idx)):
            if comp.elem is None:
                continue
            el = _deepcopy_elem(comp.elem)
            el.set("loc", fmt_loc(comp.new_loc or comp.loc))
            if comp.facing != comp.orig_facing:
                self._set_attr(el, "facing", comp.facing)
            ce.append(el)

        title = titles.get(circ.name, {})
        if title.get("title"):
            font = self.style["text"].get("sheet_title_font", "SansSerif bold 20")
            color = self.style["text"].get("sheet_title_color", "#7a0000")
            ce.append(self._text_elem(title["title"], (sheet.margin - 30, sheet.margin - 30),
                                      font, color))
        if title.get("subtitle"):
            font = self.style["text"].get("block_font", "SansSerif bold 11")
            color = self.style["text"].get("block_color", "#00007a")
            ce.append(self._text_elem(title["subtitle"],
                                      (sheet.margin - 30, sheet.margin - 10), font, color))

        for a, b in sorted(sheet.wires):
            w = ET.SubElement(ce, "wire")
            w.set("from", fmt_loc(a))
            w.set("to", fmt_loc(b))
        return ce


def _deepcopy_elem(elem):
    new = ET.Element(elem.tag, dict(elem.attrib))
    new.text = elem.text
    for child in elem:
        new.append(_deepcopy_elem(child))
    return new


def _indent(elem, level=0):
    pad = "\n" + "  " * level
    if len(elem):
        if not (elem.text or "").strip():
            elem.text = pad + "  "
        for child in elem:
            _indent(child, level + 1)
            if not (child.tail or "").strip():
                child.tail = pad + "  "
        if not (elem[-1].tail or "").strip():
            elem[-1].tail = pad
    if level and not (elem.tail or "").strip():
        elem.tail = pad


# ======================================================================================
# Verilog primitive models used by the generated netlists
# ======================================================================================

PRIMITIVES_VERILOG = """// ---------------------------------------------------------------------------
// LogisimTopoRouter primitive models
// ---------------------------------------------------------------------------
module LTR_CLOCK (output reg clk);
  initial clk = 1'b0;
  always #5 clk = ~clk;
endmodule

module LTR_D_Flip_Flop #(parameter W = 1) (
  input D, CLK, CLR, PRE, EN, output reg Q, output NQ);
  always @(posedge CLK or posedge CLR or posedge PRE) begin
    if (CLR) Q <= 1'b0;
    else if (PRE) Q <= 1'b1;
    else if (EN) Q <= D;
  end
  assign NQ = ~Q;
endmodule

module LTR_T_Flip_Flop #(parameter W = 1) (
  input D, CLK, CLR, PRE, EN, output reg Q, output NQ);
  always @(posedge CLK or posedge CLR or posedge PRE) begin
    if (CLR) Q <= 1'b0;
    else if (PRE) Q <= 1'b1;
    else if (EN) Q <= ~Q;
  end
  assign NQ = ~Q;
endmodule

module LTR_J_K_Flip_Flop #(parameter W = 1) (
  input X0, X1, CLK, CLR, PRE, EN, output reg Q, output NQ);
  always @(posedge CLK or posedge CLR or posedge PRE) begin
    if (CLR) Q <= 1'b0;
    else if (PRE) Q <= 1'b1;
    else if (EN) begin
      case ({X0, X1})
        2'b00: Q <= Q;
        2'b01: Q <= 1'b0;
        2'b10: Q <= 1'b1;
        default: Q <= ~Q;
      endcase
    end
  end
  assign NQ = ~Q;
endmodule

module LTR_S_R_Flip_Flop #(parameter W = 1) (
  input X0, X1, CLK, CLR, PRE, EN, output reg Q, output NQ);
  always @(posedge CLK or posedge CLR or posedge PRE) begin
    if (CLR) Q <= 1'b0;
    else if (PRE) Q <= 1'b1;
    else if (EN) begin
      if (X0) Q <= 1'b1;
      else if (X1) Q <= 1'b0;
    end
  end
  assign NQ = ~Q;
endmodule

module LTR_Register #(parameter W = 8) (
  input [W-1:0] D, input CLK, CLR, EN, output reg [W-1:0] Q);
  always @(posedge CLK or posedge CLR)
    if (CLR) Q <= {W{1'b0}};
    else if (EN) Q <= D;
endmodule

module LTR_Counter #(parameter W = 8, parameter MAX = 255) (
  input [W-1:0] D, input CLK, CLR, LD, EN,
  output reg [W-1:0] Q, output CARRY);
  assign CARRY = (Q == MAX);
  always @(posedge CLK or posedge CLR)
    if (CLR) Q <= {W{1'b0}};
    else if (LD) Q <= D;
    else if (EN) Q <= (Q == MAX) ? {W{1'b0}} : Q + 1'b1;
endmodule

module LTR_Shift_Register #(parameter W = 1, parameter LEN = 8) (
  input IN, SH, CK, CLR, LD, output reg OUT);
  reg [LEN-1:0] sr;
  always @(posedge CK or posedge CLR)
    if (CLR) sr <= {LEN{1'b0}};
    else if (LD) sr <= {LEN{IN}};
    else if (SH) sr <= {sr[LEN-2:0], IN};
  always @* OUT = sr[LEN-1];
endmodule

module LTR_Adder #(parameter W = 8) (
  input [W-1:0] A, B, input C_IN, output [W-1:0] S, output C_OUT);
  assign {C_OUT, S} = A + B + C_IN;
endmodule

module LTR_Subtractor #(parameter W = 8) (
  input [W-1:0] A, B, input B_IN, output [W-1:0] S, output B_OUT);
  assign {B_OUT, S} = A - B - B_IN;
endmodule

module LTR_Multiplier #(parameter W = 8) (
  input [W-1:0] A, B, C_IN, output [W-1:0] Y, output [W-1:0] C_OUT);
  assign {C_OUT, Y} = A * B + C_IN;
endmodule

module LTR_Divider #(parameter W = 8) (
  input [W-1:0] A, B, UPPER, output [W-1:0] Q, output [W-1:0] REM);
  assign Q = A / B;
  assign REM = A % B;
endmodule

module LTR_Negator #(parameter W = 8) (input [W-1:0] A, output [W-1:0] Y);
  assign Y = -A;
endmodule

module LTR_Comparator #(parameter W = 8) (
  input [W-1:0] A, B, output GT, EQ, LT);
  assign GT = (A > B), EQ = (A == B), LT = (A < B);
endmodule

module LTR_Shifter #(parameter W = 8, parameter S = 3) (
  input [W-1:0] D, input [S-1:0] S, output [W-1:0] Y);
  assign Y = D << S;
endmodule

module LTR_RAM #(parameter AW = 8, parameter DW = 8) (
  input [AW-1:0] ADDR, input CS, OE, WE, CLK, CLR, input [DW-1:0] DIN,
  inout [DW-1:0] DATA);
  reg [DW-1:0] mem [0:(1<<AW)-1];
  assign DATA = (CS & OE) ? mem[ADDR] : {DW{1'bz}};
  always @(posedge CLK) if (CS & WE) mem[ADDR] <= DIN;
endmodule

module LTR_ROM #(parameter AW = 8, parameter DW = 8) (
  input [AW-1:0] ADDR, input CS, output [DW-1:0] DATA);
  reg [DW-1:0] mem [0:(1<<AW)-1];
  assign DATA = CS ? mem[ADDR] : {DW{1'bz}};
endmodule

module LTR_Random #(parameter W = 8) (
  input [W-1:0] SEED, input CLK, CLR, EN, output reg [W-1:0] Q);
  always @(posedge CLK or posedge CLR)
    if (CLR) Q <= SEED;
    else if (EN) Q <= {$random} % (1 << W);
endmodule

module LTR_LED (input X); endmodule
module LTR_Button (output X); assign X = 1'b0; endmodule
module LTR_Hex_Digit_Display (input [3:0] D, input DP); endmodule
module LTR_Priority_Encoder #(parameter W = 8) (
  input [W-1:0] I, input EI, output reg [3:0] A, output reg EO, GS);
  integer i;
  always @* begin
    A = 0; EO = 1; GS = 0;
    for (i = 0; i < W; i = i + 1) if (I[i]) begin A = i; EO = 0; GS = 1; end
  end
endmodule
"""


# ======================================================================================
# PNG rendering (a small, dependency-free rasteriser)
# ======================================================================================

FONT_5X7 = {
    "A": "0E11111F111111", "B": "1E11111E11111E", "C": "0E11101010110E",
    "D": "1E11111111111E", "E": "1F10101E10101F", "F": "1F10101E101010",
    "G": "0E11101711110F", "H": "1111111F111111", "I": "0E04040404 040E".replace(" ", ""),
    "J": "070202020212 0C".replace(" ", ""), "K": "1112141814 1211".replace(" ", ""),
    "L": "10101010101 01F".replace(" ", ""), "M": "111B1515111111",
    "N": "11191513111111", "O": "0E11111111110E", "P": "1E11111E101010",
    "Q": "0E1111111512 0D".replace(" ", ""), "R": "1E11111E141211",
    "S": "0F10100E01011E", "T": "1F040404040404", "U": "1111111111110E",
    "V": "11111111110A04", "W": "11111115151B11", "X": "11110A040A1111",
    "Y": "11110A04040404", "Z": "1F0102040810 1F".replace(" ", ""),
    "0": "0E1113151911 0E".replace(" ", ""), "1": "040C040404040E",
    "2": "0E1101020408 1F".replace(" ", ""), "3": "1F02040201110E",
    "4": "02060A121F0202", "5": "1F101E0101110E", "6": "0608101E111 10E".replace(" ", ""),
    "7": "1F010204080808", "8": "0E11110E11110E", "9": "0E11110F01020C",
    " ": "00000000000000", "-": "00001F0000 0000".replace(" ", ""),
    "_": "0000000000001F", ".": "0000000000 0404".replace(" ", ""),
    ",": "00000000000408", ":": "0004040004 0400".replace(" ", ""),
    ";": "00040000040408", "/": "01020204080810", "\\": "10080804020201",
    "(": "02040808080402", ")": "08040202020408", "[": "0E0808080808 0E".replace(" ", ""),
    "]": "0E0202020202 0E".replace(" ", ""), "+": "0004041F040400",
    "=": "00001F001F0000", "*": "000A041F040A00", "<": "0204081008 0402".replace(" ", ""),
    ">": "08040201020408", "?": "0E110102040004", "#": "0A0A1F0A1F0A0A",
    "!": "04040404040004", "%": "1102020408 0811".replace(" ", ""),
    "&": "0C1214081512 0D".replace(" ", ""), "'": "04040000000000",
    '"': "0A0A0000000000", "|": "0404040404 0404".replace(" ", ""),
    "~": "0000081502 0000".replace(" ", ""), "^": "040A1100000000",
    "$": "040F140E051E04", "@": "0E1117151710 0E".replace(" ", ""),
    "`": "0804000000 0000".replace(" ", ""),
}


def _hex_to_rgb(text, default=(0, 0, 0)):
    text = (text or "").lstrip("#")
    if len(text) not in (6, 8):
        return default
    try:
        return (int(text[0:2], 16), int(text[2:4], 16), int(text[4:6], 16))
    except ValueError:
        return default


class Image:
    """Tiny RGB rasteriser: lines, rectangles and 5x7 bitmap text."""

    def __init__(self, width, height, background=(255, 255, 255)):
        self.w = max(1, int(width))
        self.h = max(1, int(height))
        self.bg = background
        self.buf = bytearray(bytes(background) * (self.w * self.h))

    def _blend(self, x, y, color):
        if 0 <= x < self.w and 0 <= y < self.h:
            i = (y * self.w + x) * 3
            self.buf[i:i + 3] = bytes(color)

    def pixel(self, x, y, color):
        self._blend(int(x), int(y), color)

    def fill(self, rect, color):
        x, y, w, h = [int(v) for v in rect]
        x0, y0 = max(0, x), max(0, y)
        x1, y1 = min(self.w, x + w), min(self.h, y + h)
        if x1 <= x0 or y1 <= y0:
            return
        row = bytes(color) * (x1 - x0)
        for yy in range(y0, y1):
            i = (yy * self.w + x0) * 3
            self.buf[i:i + len(row)] = row

    def rect(self, rect, color, width=1):
        x, y, w, h = [int(v) for v in rect]
        for t in range(max(1, width)):
            self.hline(x, x + w - 1, y + t, color)
            self.hline(x, x + w - 1, y + h - 1 - t, color)
            self.vline(x + t, y, y + h - 1, color)
            self.vline(x + w - 1 - t, y, y + h - 1, color)

    def hline(self, x0, x1, y, color, width=1):
        if x1 < x0:
            x0, x1 = x1, x0
        for t in range(max(1, width)):
            for x in range(x0, x1 + 1):
                self._blend(x, y + t, color)

    def vline(self, x, y0, y1, color, width=1):
        if y1 < y0:
            y0, y1 = y1, y0
        for t in range(max(1, width)):
            for y in range(y0, y1 + 1):
                self._blend(x + t, y, color)

    def line(self, a, b, color, width=1):
        (x0, y0), (x1, y1) = a, b
        if x0 == x1:
            return self.vline(x0, y0, y1, color, width)
        if y0 == y1:
            return self.hline(x0, x1, y0, color, width)
        steps = max(abs(x1 - x0), abs(y1 - y0))
        for i in range(steps + 1):
            self._blend(x0 + (x1 - x0) * i / steps, y0 + (y1 - y0) * i / steps, color)

    def glyph(self, ch, x, y, scale, color):
        rows = FONT_5X7.get(ch.upper()) or FONT_5X7.get("?")
        for ry in range(7):
            val = int(rows[ry * 2:ry * 2 + 2], 16)
            for rx in range(5):
                if val & (1 << (4 - rx)):
                    self.fill((x + rx * scale, y + ry * scale, scale, scale), color)

    def text(self, x, y, string, color, scale=2, spacing=1):
        cx = int(x)
        for ch in str(string):
            self.glyph(ch, cx, int(y), scale, color)
            cx += (5 + spacing) * scale
        return cx

    def text_width(self, string, scale=2, spacing=1):
        return len(str(string)) * (5 + spacing) * scale


def write_png(path: str, img: Image, scale_down=1):
    """Write a PNG (RGB, no external dependencies)."""
    import struct
    import zlib

    data = img.buf
    width, height = img.w, img.h
    if scale_down > 1:
        width = max(1, width // scale_down)
        height = max(1, height // scale_down)
        out = bytearray()
        for y in range(height):
            row = bytearray()
            for x in range(width):
                r = g = b = 0
                n = 0
                for dy in range(scale_down):
                    sy = y * scale_down + dy
                    if sy >= img.h:
                        break
                    base = sy * img.w
                    for dx in range(scale_down):
                        sx = x * scale_down + dx
                        if sx >= img.w:
                            break
                        i = (base + sx) * 3
                        r += img.buf[i]
                        g += img.buf[i + 1]
                        b += img.buf[i + 2]
                        n += 1
                n = n or 1
                row += bytes((r // n, g // n, b // n))
            out += b"\x00" + row
        data = bytes(out)
    else:
        raw = bytearray()
        stride = width * 3
        for y in range(height):
            raw += b"\x00" + data[y * stride:(y + 1) * stride]
        data = bytes(raw)

    def chunk(tag, payload):
        return (struct.pack(">I", len(payload)) + tag + payload
                + struct.pack(">I", zlib.crc32(tag + payload) & 0xFFFFFFFF))

    png = (b"\x89PNG\r\n\x1a\n"
           + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(data, 6))
           + chunk(b"IEND", b""))
    with open(path, "wb") as fh:
        fh.write(png)
    return width, height

# ======================================================================================
# Verilog export
# ======================================================================================

VERILOG_KEYWORDS = {
    "module", "endmodule", "input", "output", "inout", "wire", "reg", "assign",
    "always", "begin", "end", "if", "else", "case", "endcase", "posedge", "negedge",
    "initial", "parameter", "localparam", "integer", "genvar", "generate", "endgenerate",
    "default", "signed", "supply0", "supply1", "tri", "wand", "wor", "not", "and", "or",
    "nand", "nor", "xor", "xnor", "buf", "tran", "nmos", "pmos", "time", "real", "event",
}

GATE_EXPR = {
    "AND Gate": ("&", False, False),
    "OR Gate": ("|", False, False),
    "NAND Gate": ("&", True, False),
    "NOR Gate": ("|", True, False),
    "XOR Gate": ("^", False, False),
    "XNOR Gate": ("^", True, False),
    "Odd Parity": ("^", False, False),
    "Even Parity": ("^", True, False),
    "NOT Gate": (None, True, False),
    "Buffer": (None, False, False),
    "Controlled Buffer": ("&", False, True),
    "Controlled Inverter": ("&", True, True),
}

MEMORY_CELLS = ("D Flip-Flop", "T Flip-Flop", "J-K Flip-Flop", "S-R Flip-Flop",
                "Register", "Counter", "Shift Register", "RAM", "ROM", "Random")


def _vid(name: str, used=None) -> str:
    """Turn an arbitrary Logisim label into a legal Verilog identifier."""
    out = re.sub(r"\W", "_", (name or "").strip())
    if not out or not re.match(r"[A-Za-z_]", out[0]):
        out = "n_" + out
    if out in VERILOG_KEYWORDS:
        out += "_"
    if used is not None:
        base = out
        i = 1
        while out in used:
            out = "%s_%d" % (base, i)
            i += 1
        used.add(out)
    return out


class VerilogWriter:
    def __init__(self, project: Project, style: dict):
        self.project = project
        self.style = style
        self.opts = style.get("verilog", {})
        self.used_subcircuit_ports = {}

    # -- ports -------------------------------------------------------------------------
    def _circuit_ports(self, circ: Circuit):
        """Module ports (Logisim pins) with the Bidir split applied."""
        inputs, outputs = [], []
        for comp in circ.comps:
            if not comp.is_pin():
                continue
            name = comp.label or ("pin_%d" % comp.idx)
            width = comp.attr_int("width", 1)
            entry = (name, width, comp)
            if comp.pin_is_output():
                outputs.append(entry)
            else:
                inputs.append(entry)
        in_names = {n for n, _, _ in inputs}
        out_names = {n for n, _, _ in outputs}
        dup = in_names & out_names
        ports = []
        used = set()
        for name, width, comp in inputs:
            vname = _vid(name + ("_i" if name in dup else ""), used)
            ports.append({"name": vname, "dir": "input", "width": width, "comp": comp,
                          "label": name})
        for name, width, comp in outputs:
            vname = _vid(name + ("_o" if name in dup else ""), used)
            ports.append({"name": vname, "dir": "output", "width": width, "comp": comp,
                          "label": name})
        return ports

    def _net_names(self, circ: Circuit, ports, used):
        """Name every net of a circuit; return {net idx: (verilog name, width)}."""
        port_net = {}
        for p in ports:
            for net in circ.nets:
                if (p["comp"], None) in [(c, None) for c, _ in net.members]:
                    comps = [c for c, _ in net.members]
                    if p["comp"] in comps:
                        port_net[net.idx] = p["name"]
                        break
        names = {}
        for net in circ.nets:
            if len(net.members) < 2:
                continue
            if net.idx in port_net:
                names[net.idx] = port_net[net.idx]
                continue
            base = net.label if net.label and not net.label.startswith("n") else (
                "w%d" % net.idx)
            names[net.idx] = _vid(base, used)
        return names

    # -- module ------------------------------------------------------------------------
    def module(self, circ: Circuit) -> str:
        ind = self.opts.get("indent", "  ")
        self._lookup = {}
        for net in circ.nets:
            for comp, index in net.members:
                self._lookup[(comp.idx, index)] = net
        lines = []
        ports = self._circuit_ports(circ)
        used = set(p["name"] for p in ports)
        net_names = self._net_names(circ, ports, used)
        prefix = self.opts.get("module_prefix", "")

        if ports:
            lines.append("module %s%s (" % (prefix, _vid(circ.name)))
            decls = []
            for p in ports:
                rng = "" if p["width"] <= 1 else "[%d:0] " % (p["width"] - 1)
                decls.append("%s%s %s" % (ind, p["dir"], rng + p["name"]))
            lines.append(",\n".join(decls))
            lines.append(");")
        else:
            lines.append("module %s%s ();" % (prefix, _vid(circ.name)))

        # net declarations
        declared = set()
        decl = []
        for net in circ.nets:
            if net.idx not in net_names:
                continue
            name = net_names[net.idx]
            if name in declared:
                continue
            declared.add(name)
            width = max([comp.ports[i].width for comp, i in net.members] + [net.width, 1])
            rng = "" if width <= 1 else "[%d:0] " % (width - 1)
            decl.append("%swire %s%s;" % (ind, rng, name))
        if decl:
            lines.append("")
            lines.extend(decl)

        body = []
        for comp in circ.comps:
            stmt = self._component_stmt(circ, comp, net_names, prefix)
            if stmt:
                body.append(ind + "// " + self._describe(comp))
                body.extend(ind + s for s in stmt)
        if body:
            lines.append("")
            lines.extend(body)
        lines.append("")
        lines.append("endmodule")
        return "\n".join(lines)

    def _describe(self, comp: Comp) -> str:
        bits = [comp.name]
        if comp.label:
            bits.append("%r" % comp.label)
        bits.append("@%s" % fmt_loc(comp.loc))
        if comp.subcircuit:
            bits.append("-> %s" % comp.subcircuit)
        return " ".join(bits)

    def _net_of(self, circ, comp, index, net_names):
        net = getattr(self, "_lookup", {}).get((comp.idx, index))
        if net is None:
            return None
        return net_names.get(net.idx, "1'b0")

    def _port_expr(self, circ, comp, index, net_names):
        name = self._net_of(circ, comp, index, net_names)
        return name

    def _component_stmt(self, circ: Circuit, comp: Comp, net_names, prefix):
        name = comp.name
        exprs = [self._port_expr(circ, comp, i, net_names) for i in range(len(comp.ports))]

        def E(index):
            return exprs[index] if 0 <= index < len(exprs) else None

        out = E(0)
        if name == "Transistor":
            if E(2) is None or E(1) is None:
                return ["// transistor with fewer than 3 connected terminals"]
            kind = "nmos" if comp.attr("type", "n") == "n" else "pmos"
            return ["%s u_tr_%d (%s, %s, %s);" % (kind, comp.idx, E(0) or "1'bz",
                                                  E(1) or "1'bz", E(2))]
        if name == "Transmission Gate":
            if E(2) is None or E(1) is None:
                return ["// transmission gate with fewer than 3 connected terminals"]
            return ["tranif1 u_tg_%d (%s, %s, %s);" % (comp.idx, E(0) or "1'bz",
                                                       E(1) or "1'bz", E(2)),
                    "// gate0=%s gate1=%s" % (E(2), E(3))]

        if name in GATE_EXPR:
            op, invert, controlled = GATE_EXPR[name]
            ins = [e for e in exprs[1:] if e]
            if name in ("NOT Gate", "Buffer"):
                if not ins:
                    return ["// %s: input not connected" % name]
                expr = ins[0] if not invert else "~%s" % ins[0]
                return (["assign %s = %s;" % (out, expr)] if out else
                        ["// %s: output not connected" % name])
            if not ins:
                return ["// %s: no connected inputs" % name]
            if controlled:
                ctrl = ins[-1]
                data = ins[:-1]
                base = data[0] if len(data) == 1 else "(%s)" % " & ".join(data)
                expr = "%s & %s" % (ctrl, base)
                if invert:
                    expr = "~(%s)" % expr
                return (["assign %s = %s;" % (out, expr)] if out else [])
            joined = " %s " % op
            expr = joined.join("(%s)" % e if " " in e else e for e in ins)
            if invert:
                expr = "~(%s)" % expr
            w = max([comp.ports[i].width for i in range(1, len(comp.ports))] + [1])
            if w > 1:
                expr = "(%s)" % expr if " " in expr else expr
            return (["assign %s = %s;" % (out, expr)] if out else [])
        if name == "Constant":
            if not out:
                return ["// constant not connected"]
            w = comp.attr_int("width", 1)
            raw = comp.attr("value", "0x0")
            try:
                val = int(str(raw), 0)
            except ValueError:
                val = 0
            val &= (1 << w) - 1
            return ["assign %s = %d'h%x;" % (out, w, val)]
        if name in ("Ground", "Power"):
            if not out:
                return ["// %s not connected" % name]
            return ["assign %s = 1'b%s;" % (out, "0" if name == "Ground" else "1")]
        if name == "Clock":
            if not out:
                return ["// clock not connected"]
            return ["%sLTR_CLOCK u_clk_%d (.clk(%s));" % (self.prefix, comp.idx, out)]
        if name == "Pull Resistor":
            pull = comp.attr("pull", "0")
            bit = {"1": "1'b1", "0": "1'b0"}.get(pull, "1'bz")
            target = E(0) or "1'bz"
            return ["// pull resistor: %s (weak driver)" % bit,
                    "pullup u_pull_%d (%s);" % (comp.idx, target) if pull == "1" else
                    ("pulldown u_pull_%d (%s);" % (comp.idx, target) if pull == "0"
                     else "// floating pull resistor")]
        if name == "Splitter":
            return self._splitter_stmt(circ, comp, net_names)
        if name == "Tunnel":
            return ["// tunnel %s -> net %s" % (comp.label, E(0))]
        if name == "Bit Extender":
            src = E(1)
            if src is None:
                return ["// bit extender: input not connected"]
            mode = comp.attr("type", "sign")
            out_w = comp.attr_int("out_width", 16)
            in_w = comp.attr_int("in_width", 8)
            if mode == "sign":
                return ["assign %s = $signed(%s);" % (out, src)]
            if mode == "zero":
                return ["assign %s = {{%d{1'b0}}, %s};" % (out, out_w - in_w, src)]
            if mode == "one":
                return ["assign %s = {{%d{1'b1}}, %s};" % (out, out_w - in_w, src)]
            ctrl = E(2) or "1'b0"
            return ["assign %s = %s ? $signed(%s) : {{%d{1'b0}}, %s};"
                    % (out, ctrl, src, out_w - in_w, src)]
        if name in ("Multiplexer", "Demultiplexer"):
            return self._mux_stmt(circ, comp, net_names)
        if name == "Decoder":
            return self._decoder_stmt(circ, comp, net_names)
        if name in MEMORY_CELLS or name in ("Adder", "Subtractor", "Multiplier", "Divider",
                                            "Negator", "Comparator", "Shifter", "BitAdder",
                                            "BitFinder", "Random", "Priority Encoder",
                                            "BitSelector", "LED", "Button",
                                            "Hex Digit Display", "7-Segment Display",
                                            "DotMatrix", "TTY", "Keyboard", "Joystick"):
            return self._instance_stmt(circ, comp, net_names)
        if comp.subcircuit:
            return self._subcircuit_stmt(circ, comp, net_names)
        return ["// %s: no Verilog model" % name]

    def _splitter_stmt(self, circ, comp, net_names):
        widths = _splitter_widths(comp)
        out = []
        mixed = self._port_expr(circ, comp, 0, net_names)
        fanout = comp.attr_int("fanout", 2)
        fanout = max(1, fanout)
        running = 0
        for end in range(1, fanout + 1):
            w = max(1, widths[end]) if end < len(widths) else 1
            target = self._port_expr(circ, comp, end, net_names)
            if target:
                sel = mixed if w == widths[0] else (
                    "[%d:%d] %s" % (running + w - 1, running, mixed))
                out.append("assign %s = %s;" % (target, sel))
            running += w
        if not out:
            out.append("// splitter with no connected ends")
        return out

    def _mux_stmt(self, circ, comp, net_names):
        sel_w = max(1, comp.attr_int("select", 1))
        n = 1 << sel_w
        is_mux = comp.name == "Multiplexer"
        data = [self._port_expr(circ, comp, i, net_names) for i in range(n)]
        sel = self._port_expr(circ, comp, n, net_names)
        enable = comp.attr_bool("enable", False)
        out_port = self._port_expr(circ, comp, len(comp.ports) - 1, net_names)
        stmts = []
        if is_mux:
            expr = data[-1] if data[-1] else "1'b0"
            for i in range(n - 2, -1, -1):
                cond = "%s == %d'd%d" % (sel or "0", sel_w, i)
                expr = "(%s) ? %s : (%s)" % (cond, data[i] or "1'b0", expr)
            if enable:
                en = self._port_expr(circ, comp, n + 1, net_names)
                expr = "(%s) ? %s : 1'bz" % (en or "1'b1", expr)
            stmts.append("assign %s = %s;" % (out_port, expr))
        else:
            src = self._port_expr(circ, comp, len(comp.ports) - 1, net_names)
            for i in range(n):
                target = data[i]
                if not target:
                    continue
                cond = "%s == %d'd%d" % (sel or "0", sel_w, i)
                body = "%s ? %s : " % (cond, src or "1'b0")
                stmts.append("assign %s = %s%s;" % (target, body,
                                                    "1'bz" if enable else "1'b0"))
        return stmts or ["// %s: nothing connected" % comp.name]

    def _decoder_stmt(self, circ, comp, net_names):
        sel_w = max(1, comp.attr_int("select", 1))
        n = 1 << sel_w
        sel = self._port_expr(circ, comp, n, net_names)
        stmts = []
        for i in range(n):
            target = self._port_expr(circ, comp, i, net_names)
            if not target:
                continue
            stmts.append("assign %s = (%s == %d'd%d);" % (target, sel or "0", sel_w, i))
        return stmts or ["// decoder: no outputs connected"]

    def _instance_stmt(self, circ, comp, net_names):
        """Instantiate a primitive model; keep the original pin names as port map keys."""
        pins = []
        for i, port in enumerate(comp.ports):
            net = self._port_expr(circ, comp, i, net_names)
            if port.name and port.name != "?":
                key = _vid(port.name)
                pins.append("." + key + "(" + (net or "") + ")")
        module = "%sLTR_%s" % (self.prefix, _vid(comp.name))
        inst = "u_%s_%d" % (_vid(comp.name), comp.idx)
        if not pins:
            return ["// %s has no connections" % comp.name]
        return ["%s %s (%s);" % (module, inst, ", ".join(pins))]

    def _subcircuit_stmt(self, circ, comp, net_names):
        pins = self._subcircuit_ports(comp)
        args = []
        lhs = defaultdict(list)
        rhs = defaultdict(list)
        for i, (pin_name, direction, width) in enumerate(pins):
            net = self._port_expr(circ, comp, i, net_names)
            if net is None:
                continue
            if direction == "in":
                lhs[net].append(pin_name)
            else:
                rhs[net].append(pin_name)
        for net, names in lhs.items():
            if names:
                args.append("." + names[0] + "(" + net + ")")
        for net, names in rhs.items():
            if names:
                args.append("." + names[0] + "(" + net + ")")
        module = "%s%s" % (self.prefix, _vid(comp.subcircuit or comp.name))
        inst = "u_%s_%d" % (_vid(comp.name), comp.idx)
        if not args:
            return ["%s %s ();" % (module, inst)]
        return ["%s %s (%s);" % (module, inst, ", ".join(args))]

    def _subcircuit_ports(self, comp: Comp):
        """Port names of a sub-circuit instance, matched by geometry like Logisim does."""
        key = (comp.subcircuit, tuple(sorted((p.dx, p.dy) for p in comp.ports)))
        if key in self.used_subcircuit_ports:
            return self.used_subcircuit_ports[key]
        target = None
        for c in self.project.circuits:
            if c.name == comp.subcircuit:
                target = c
                break
        if target is None:
            return [(p.name or "p%d" % i, "in" if p.kind != "out" else "out", p.width)
                    for i, p in enumerate(comp.ports)]
        ins, outs = [], []
        for pin in target.comps:
            if not pin.is_pin():
                continue
            entry = (_vid(pin.label or ("pin_%d" % pin.idx)), pin.loc[1], pin.loc[0])
            (outs if pin.pin_is_output() else ins).append(entry)
        ins.sort(key=lambda e: (e[1], e[2]))
        outs.sort(key=lambda e: (e[1], e[2]))
        ordered = ([(n, "in") for n, _, _ in ins] + [(n, "out") for n, _, _ in outs])
        # instance pins: inputs on the west edge sorted by y, then outputs on the east edge
        west, east, other = [], [], []
        for i, port in enumerate(comp.ports):
            side = pin_side(comp, port)
            (west if side in ("west", "north", "south") else east).append((i, port.dy, port.dx))
        west.sort(key=lambda e: (e[1], e[2]))
        east.sort(key=lambda e: (e[1], e[2]))
        result = []
        idx = 0
        for _, _, _ in west:
            if idx < len(ins):
                result.append((ins[idx][0], "in", 1))
                idx += 1
        idx = 0
        for _, _, _ in east:
            if idx < len(outs):
                result.append((outs[idx][0], "out", 1))
                idx += 1
        if not result:
            result = [(p.name or "p%d" % i, "in" if p.kind != "out" else "out", p.width)
                      for i, p in enumerate(comp.ports)]
        self.used_subcircuit_ports[key] = result
        return result

    @property
    def prefix(self):
        return self.opts.get("module_prefix", "") or ""

    # -- file --------------------------------------------------------------------------
    def write(self, out_path: str, sheets) -> str:
        header = [
            "// Declarative Verilog netlist generated by LogisimTopoRouter %s (issue #1391)"
            % __version__,
            "// Source project: %s" % os.path.basename(self.project.path),
            "// Topologically sorted, one module per Logisim circuit.",
            "// NOTE: Logisim has no bidirectional (Bidir) ports; nets that would need an",
            "//       `inout` are split into separate `*_i` / `*_o` ports (see the report).",
            "",
        ]
        chunks = []
        if self.opts.get("primitives", True):
            chunks.append(PRIMITIVES_VERILOG)
        for sheet in sheets:
            chunks.append(self.module(sheet.circ))
        with open(out_path, "w", encoding="utf-8") as fh:
            fh.write("\n".join(header) + "\n" + "\n\n".join(chunks) + "\n")
        return out_path


# ======================================================================================
# PNG rendering of a routed sheet
# ======================================================================================

CELL_SHORT = {
    "AND Gate": "AND", "OR Gate": "OR", "NAND Gate": "NAND", "NOR Gate": "NOR",
    "XOR Gate": "XOR", "XNOR Gate": "XNOR", "NOT Gate": "NOT", "Buffer": "BUF",
    "Controlled Buffer": "CBUF", "Controlled Inverter": "CINV", "Odd Parity": "ODD",
    "Even Parity": "EVEN", "Transistor": "FET", "Transmission Gate": "TG",
    "Pull Resistor": "PULL", "Constant": "CONST", "Ground": "GND", "Power": "VCC",
    "Clock": "CLK", "Splitter": "SPLIT", "Multiplexer": "MUX", "Demultiplexer": "DMX",
    "Decoder": "DEC", "Priority Encoder": "PRIO", "BitSelector": "BSEL",
    "Bit Extender": "EXT", "Adder": "ADD", "Subtractor": "SUB", "Multiplier": "MUL",
    "Divider": "DIV", "Negator": "NEG", "Comparator": "CMP", "Shifter": "SHF",
    "BitAdder": "BADD", "BitFinder": "BFIND", "D Flip-Flop": "DFF", "T Flip-Flop": "TFF",
    "J-K Flip-Flop": "JKFF", "S-R Flip-Flop": "SRFF", "Register": "REG",
    "Counter": "CNT", "Shift Register": "SREG", "RAM": "RAM", "ROM": "ROM",
    "Random": "RND", "LED": "LED", "Button": "BTN", "Hex Digit Display": "HEX",
    "7-Segment Display": "7SEG", "DotMatrix": "DOT", "TTY": "TTY", "Keyboard": "KBD",
    "Joystick": "JOY", "Probe": "PRB", "NoConnect": "NC",
}


class SheetRenderer:
    """Renders a routed sheet as a PlanAhead-flavoured PNG."""

    def __init__(self, style: dict):
        self.style = style
        self.png = style.get("png", {})

    def render(self, sheet: Sheet, path: str, title="", subtitle="", sheet_no=1,
               total=1) -> tuple:
        scale = int(self.png.get("scale", 2) or 2)
        max_pixels = int(self.png.get("max_pixels", 24_000_000))
        max_dim = int(self.png.get("max_dimension", 12000))
        width = max(400, int(sheet.width) + 20)
        height = max(300, int(sheet.height) + 20)
        while scale > 1 and (width * scale > max_dim or height * scale > max_dim
                             or width * scale * height * scale > max_pixels):
            scale -= 1
        scale_down = 1
        while (width * height) // (scale_down * scale_down) > max_pixels:
            scale_down += 1
        img = Image(width * scale, height * scale,
                    _hex_to_rgb(self.png.get("background", "#ffffff"), (255, 255, 255)))
        self._frame(img, sheet, scale, title, subtitle, sheet_no, total)
        if self.png.get("grid", False):
            self._grid(img, sheet, scale)
        self._wires(img, sheet, scale)
        self._cells(img, sheet, scale)
        if self.png.get("level_headers", True):
            self._headers(img, sheet, scale)
        if self.png.get("net_labels", True):
            self._net_labels(img, sheet, scale)
        return write_png(path, img, scale_down)

    # -- primitives --------------------------------------------------------------------
    def _px(self, pt, scale):
        return (int(pt[0] * scale), int(pt[1] * scale))

    def _frame(self, img, sheet, scale, title, subtitle, sheet_no, total):
        fg = _hex_to_rgb(self.png.get("frame_color", "#7a0000"), (122, 0, 0))
        thin = _hex_to_rgb(self.png.get("frame_thin_color", "#b0b0b0"), (176, 176, 176))
        m = int(sheet.margin * scale)
        img.rect((4, 4, img.w - 8, img.h - 8), fg, max(2, scale))
        if self.png.get("inner_frame", True):
            img.rect((m // 2, m // 2, img.w - m, img.h - m), thin, max(1, scale // 2))
        text = self.png.get("title_block", True)
        if text and title:
            img.text(m // 2 + 8, m // 2 + 8, title,
                     _hex_to_rgb(self.png.get("title_color", "#7a0000")), scale=2)
        if text:
            info = "%s   [%d/%d]   LogisimTopoRouter" % (subtitle or "", sheet_no, total)
            img.text(m // 2 + 8, img.h - m // 2 - 20 * max(1, scale // 2), info,
                     (60, 60, 60), scale=1)

    def _grid(self, img, sheet, scale):
        color = _hex_to_rgb(self.png.get("grid_color", "#e8e8e8"), (232, 232, 232))
        for x in range(0, sheet.width, 100):
            img.vline(x * scale, 0, img.h - 1, color)
        for y in range(0, sheet.height, 100):
            img.hline(0, img.w - 1, y * scale, color)

    def _wires(self, img, sheet, scale):
        wire = _hex_to_rgb(self.png.get("wire_color", "#202020"), (32, 32, 32))
        bus = _hex_to_rgb(self.png.get("bus_color", "#004080"), (0, 64, 128))
        widths = {}
        for net in sheet.circ.nets:
            for comp, i in net.members:
                widths[(comp.idx, i)] = max(1, comp.ports[i].width)
        bus_nets = {net.idx for net in sheet.circ.nets if net.width > 1}
        for a, b in sheet.wires:
            img.line(self._px(a, scale), self._px(b, scale), wire,
                     max(1, scale))
        for net in sheet.circ.nets:
            if net.idx not in bus_nets or net.track_y is None:
                continue
            xs = sorted(net.lane_x.values())
            if xs:
                img.hline(xs[0] * scale, xs[-1] * scale, net.track_y * scale, bus,
                          max(1, scale))

    def _cells(self, img, sheet, scale):
        fill = _hex_to_rgb(self.png.get("cell_fill", "#fffbe6"), (255, 251, 230))
        fill2 = _hex_to_rgb(self.png.get("memory_fill", "#e8f0ff"), (232, 240, 255))
        block = _hex_to_rgb(self.png.get("block_fill", "#f0e8ff"), (240, 232, 255))
        edge = _hex_to_rgb(self.png.get("cell_edge", "#404040"), (64, 64, 64))
        in_col = _hex_to_rgb(self.style["text"].get("input_color", "#00007a"), (0, 0, 122))
        out_col = _hex_to_rgb(self.style["text"].get("output_color", "#7a0000"), (122, 0, 0))
        label_col = _hex_to_rgb(self.style["text"].get("block_color", "#00007a"), (0, 0, 122))
        for comp in sheet.circ.comps:
            base = comp.new_loc or comp.loc
            bx, by, bw, bh = comp.bbox
            if bw <= 0 or bh <= 0:
                bw, bh = 10, 10
            box = ((base[0] + bx) * scale, (base[1] + by) * scale,
                   max(6, bw * scale), max(6, bh * scale))
            if comp.is_pin():
                color = out_col if comp.pin_is_output() else in_col
                img.rect(box, color, max(1, scale))
                text = comp.label or comp.attr("label", "")
                if text:
                    img.text(box[0] + 2, box[1] - 9 * max(1, scale // 2), text, color,
                             scale=1)
                continue
            if comp.is_tunnel():
                img.rect(box, (150, 100, 0), 1)
                img.text(box[0] + 2, box[1] + 2, comp.label, (120, 80, 0), scale=1)
                continue
            if comp.name == "Text":
                img.text(box[0], box[1] + 2, comp.attr("text", ""), (0, 0, 0), scale=1)
                continue
            body = block if comp.subcircuit else (
                fill2 if comp.name in MEMORY_CELLS else fill)
            img.fill(box, body)
            img.rect(box, edge, 1)
            short = CELL_SHORT.get(comp.name, comp.name[:6].upper())
            cx = box[0] + 3
            cy = box[1] + max(2, (box[3] - 7) // 2)
            img.text(cx, cy, short, (20, 20, 20), scale=1)
            if comp.subcircuit:
                img.text(box[0] + 3, box[1] + 3, comp.subcircuit[:16], (60, 0, 90), scale=1)
            if comp.label:
                img.text(box[0] + 2, box[1] + box[3] + 2, comp.label, label_col, scale=1)

    def _headers(self, img, sheet, scale):
        color = _hex_to_rgb(self.style["text"].get("sheet_title_color", "#7a0000"), (122, 0, 0))
        for c in range(sheet.ncols):
            x = sheet.col_x[c] * scale
            level = sheet.level_of_col[c] if c < len(sheet.level_of_col) else c
            img.text(x, max(2, int(sheet.margin * scale) - 16 * scale),
                     "L%d" % level, color, scale=1)

    def _net_labels(self, img, sheet, scale):
        color = _hex_to_rgb(self.style["text"].get("signal_color", "#004000"), (0, 64, 0))
        shown = 0
        for net in sheet.circ.nets:
            if net.track_y is None or len(net.members) < 2:
                continue
            if not net.label or net.label.startswith("n"):
                continue
            xs = sorted(net.lane_x.values())
            if not xs:
                continue
            if shown > int(self.png.get("max_net_labels", 4000)):
                break
            img.text(xs[0] * scale + 2, (net.track_y - 7) * scale, net.label[:24],
                     color, scale=1)
            shown += 1


# ======================================================================================
# Console report
# ======================================================================================

def _table(rows, headers):
    if not rows:
        return []
    widths = [len(h) for h in headers]
    for row in rows:
        for i, cell in enumerate(row):
            widths[i] = max(widths[i], len(str(cell)))
    out = ["  " + "  ".join(h.ljust(widths[i]) for i, h in enumerate(headers)),
           "  " + "  ".join("-" * w for w in widths)]
    for row in rows:
        out.append("  " + "  ".join(str(c).ljust(widths[i]) for i, c in enumerate(row)))
    return out


def _comp_net(circ: Circuit, comp: Comp):
    for net in circ.nets:
        for c, i in net.members:
            if c is comp:
                return net
    return None


def report_circuit(sheet: Sheet, out=None, verbose=True) -> list:
    circ = sheet.circ
    out = out if out is not None else []
    stats = circ.stats
    out.append("")
    out.append("=" * 78)
    out.append("SHEET %s" % circ.name)
    out.append("=" * 78)
    out.append("  cells           : %d (%d distinct types)"
               % (stats["n_cells"], len(stats["cells"])))
    out.append("  nets            : %d (%d buses)" % (stats["n_nets"], stats["n_buses"]))
    out.append("  levels / columns: %d / %d   rows: %d"
               % (stats["max_level"] + 1, sheet.ncols, sheet.nrows))
    out.append("  primary inputs  : %d   primary outputs: %d"
               % (stats["n_inputs"], stats["n_outputs"]))
    out.append("  cycles (SCC)    : %d" % stats["n_cycles"])
    out.append("  multiple drivers: %d" % stats["n_conflicting"])
    out.append("  routed wires    : %d   opened nets: %d   shorts: %d"
               % (len(sheet.wires), len(sheet.opens), len(sheet.shorts)))
    out.append("")
    out.append("  Cells by type:")
    rows = [[("%s/%s" % (lib, name)), count]
            for (lib, name), count in sorted(stats["cells"].items(),
                                             key=lambda kv: (-kv[1], str(kv[0])))]
    out.extend(_table(rows, ["library/component", "count"]))
    if stats["gates"]:
        out.append("")
        out.append("  Logic cells:")
        out.extend(_table([[g, c] for g, c in sorted(stats["gates"].items(),
                                                     key=lambda kv: (-kv[1], kv[0]))],
                          ["gate", "count"]))
    if circ.cycles:
        out.append("")
        out.append("  Cyclic groups (feedback / latch structures):")
        for n, scc in enumerate(circ.cycles[:20]):
            names = Counter(circ.comps[i].name for i in scc if i < len(circ.comps))
            summary = ", ".join("%s x%d" % (k, v) for k, v in
                                sorted(names.items(), key=lambda kv: -kv[1])[:6])
            out.append("    #%d: %d cells - %s" % (n + 1, len(scc), summary))
        if len(circ.cycles) > 20:
            out.append("    ... %d more" % (len(circ.cycles) - 20))
    if stats["inputs"]:
        out.append("")
        out.append("  Input signals:")
        rows = []
        for comp in sorted(stats["inputs"], key=lambda c: (c.level, c.loc[1])):
            net = _comp_net(circ, comp)
            rows.append([comp.label or ("pin%d" % comp.idx),
                         comp.attr_int("width", 1),
                         net.label if net else "-",
                         len(net.sinks) + len(net.drivers) - 1 if net else 0,
                         comp.level])
        out.extend(_table(rows, ["signal", "width", "net", "fanout", "level"]))
    if stats["outputs"]:
        out.append("")
        out.append("  Output signals:")
        rows = []
        for comp in sorted(stats["outputs"], key=lambda c: (c.level, c.loc[1])):
            net = _comp_net(circ, comp)
            rows.append([comp.label or ("pin%d" % comp.idx),
                         comp.attr_int("width", 1),
                         net.label if net else "-",
                         len(net.drivers) if net else 0,
                         comp.level])
        out.extend(_table(rows, ["signal", "width", "net", "drivers", "level"]))
    bidir = [n for n in circ.nets if n.external_in and n.drivers]
    if bidir:
        out.append("")
        out.append("  Bidir / contention suspects (Logisim has no inout: split in Verilog):")
        for net in bidir[:20]:
            out.append("    net %s: %d external input pin(s), %d internal driver(s)"
                       % (net.label, len(net.external_in), len(net.drivers)))
    warnings = list(circ.warnings)
    if sheet.opens:
        warnings.append("%d net(s) did not route into a single wire tree" % len(sheet.opens))
    if sheet.shorts:
        warnings.append("%d short(s) between different nets" % len(sheet.shorts))
    if warnings:
        out.append("")
        out.append("  Warnings:")
        for w in warnings[:40]:
            out.append("    - %s" % w)
        if len(warnings) > 40:
            out.append("    ... %d more" % (len(warnings) - 40))
    return out


# ======================================================================================
# Command line interface
# ======================================================================================

def build_arg_parser():
    p = argparse.ArgumentParser(
        prog="LogisimTopoRouter.py",
        description="Topologically sort, route and document Logisim / Logisim-evolution "
                    "schematics (issue #1391).")
    p.add_argument("inputs", nargs="+", help="input .circ file(s)")
    p.add_argument("-o", "--output", default=None,
                   help="output directory (default: next to the input file)")
    p.add_argument("--suffix", default="_topo",
                   help="suffix for generated files (default: _topo)")
    p.add_argument("--style", default=None, help="style JSON (default: next to this script)")
    p.add_argument("--atlas", action="store_true",
                   help="force atlas output even for a single-circuit project")
    p.add_argument("--circuit", action="append", default=None,
                   help="only process this circuit (repeatable)")
    p.add_argument("--no-route", action="store_true",
                   help="analysis only: no .circ / .v / .png output")
    p.add_argument("--no-circ", action="store_true", help="do not write the routed .circ")
    p.add_argument("--verilog", default=None, help="Verilog output path (single input only)")
    p.add_argument("--no-verilog", action="store_true", help="do not write Verilog")
    p.add_argument("--verify", action="store_true",
                   help="re-read the generated .circ and compare its netlist with the input")
    p.add_argument("--png", action="store_true", help="also render PNG images of the sheets")
    p.add_argument("--no-png", action="store_true", help="never render PNG images")
    p.add_argument("--png-scale", type=int, default=None, help="pixels per Logisim unit")
    p.add_argument("--json", default=None, help="write machine readable statistics here")
    p.add_argument("--quiet", action="store_true", help="only print the summary")
    p.add_argument("-v", "--verbose", action="store_true", help="more per-cell diagnostics")
    p.add_argument("--version", action="version", version="LogisimTopoRouter " + __version__)
    return p


def process_file(path: str, args, style: dict) -> dict:
    result = {"file": path, "circuits": [], "errors": []}
    try:
        project = parse_project(path)
    except Exception as exc:                      # noqa: BLE001 - report, never crash
        result["errors"].append("cannot parse %s: %s" % (path, exc))
        return result

    wanted = set(args.circuit or [])
    circuits = [c for c in project.circuits if not wanted or c.name in wanted]
    if not circuits:
        result["errors"].append("no circuit selected in %s" % path)
        return result
    atlas = args.atlas or len(project.circuits) > 1

    sheets = []
    for circ in circuits:
        try:
            build_netlist(circ, project)
            analyze_circuit(circ)
            sheet = layout_circuit(circ, style) if not args.no_route else _analysis_sheet(circ)
        except Exception as exc:                  # noqa: BLE001
            result["errors"].append("circuit %s failed: %s" % (circ.name, exc))
            if args.verbose:
                import traceback
                traceback.print_exc()
            continue
        sheets.append(sheet)
        entry = {
            "name": circ.name,
            "cells": circ.stats["n_cells"],
            "nets": circ.stats["n_nets"],
            "buses": circ.stats["n_buses"],
            "cycles": circ.stats["n_cycles"],
            "levels": circ.stats["max_level"] + 1,
            "inputs": circ.stats["n_inputs"],
            "outputs": circ.stats["n_outputs"],
            "wires": len(sheet.wires),
            "opens": len(sheet.opens),
            "shorts": len(sheet.shorts),
            "warnings": circ.warnings[:20],
            "cells_by_type": {"%s/%s" % k: v for k, v in circ.stats["cells"].items()},
            "gates": dict(circ.stats["gates"]),
            "net_signature": _net_signature(circ),
        }
        result["circuits"].append(entry)

    if args.no_route:
        result["report"] = sum((report_circuit(s, []) for s in sheets), [])
        return result

    # -- outputs -----------------------------------------------------------------------
    base = os.path.splitext(os.path.basename(path))[0]
    out_dir = args.output or os.path.dirname(os.path.abspath(path))
    os.makedirs(out_dir, exist_ok=True)
    stem = base if not atlas else base
    titles = {}
    for i, sheet in enumerate(sheets):
        titles[sheet.circ.name] = {
            "title": "%s  -  %s" % (base, sheet.circ.name),
            "subtitle": "sheet %d/%d  cells=%d  cycles=%d"
                        % (i + 1, len(sheets), sheet.circ.stats["n_cells"],
                           sheet.circ.stats["n_cycles"]),
        }
    if not args.no_circ:
        out_circ = os.path.join(out_dir, stem + args.suffix + ".circ")
        CircWriter(project, style).write(out_circ, sheets, titles=titles)
        result["circ"] = out_circ
        if args.verify:
            result["verify"] = verify_output(out_circ, result["circuits"])
    if not args.no_verilog:
        out_v = args.verilog or os.path.join(out_dir, stem + args.suffix + ".v")
        VerilogWriter(project, style).write(out_v, sheets)
        result["verilog"] = out_v

    want_png = args.png or (not args.no_png and style.get("png", {}).get("enabled", True))
    if want_png and not args.no_png:
        png_style = json.loads(json.dumps(style))
        if args.png_scale:
            png_style.setdefault("png", {})["scale"] = args.png_scale
        renderer = SheetRenderer(png_style)
        images = []
        for i, sheet in enumerate(sheets):
            if len(project.circuits) == 1:
                name = "%s%s.png" % (stem, args.suffix)
            else:
                name = "%s%s_%s.png" % (stem, args.suffix, _vid(sheet.circ.name).lower())
            out_png = os.path.join(out_dir, name)
            try:
                w, h = renderer.render(sheet, out_png, titles[sheet.circ.name]["title"],
                                       titles[sheet.circ.name]["subtitle"], i + 1, len(sheets))
                images.append({"path": out_png, "width": w, "height": h})
            except Exception as exc:              # noqa: BLE001
                result["errors"].append("PNG for %s failed: %s" % (sheet.circ.name, exc))
        result["png"] = images
    return result


def verify_output(path: str, circuits_expected) -> dict:
    """Re-read the routed .circ and check that its netlist matches the input's."""
    out = {"ok": True, "circuits": []}
    try:
        check = parse_project(path)
    except Exception as exc:                       # noqa: BLE001
        return {"ok": False, "error": "generated file does not parse: %s" % exc}
    for entry in circuits_expected:
        name = entry["name"]
        target = next((c for c in check.circuits if c.name == name), None)
        if target is None:
            out["ok"] = False
            out["circuits"].append({"circuit": name, "ok": False, "reason": "missing"})
            continue
        try:
            build_netlist(target, check)
        except Exception as exc:                   # noqa: BLE001
            out["ok"] = False
            out["circuits"].append({"circuit": name, "ok": False,
                                    "reason": "netlist failed: %s" % exc})
            continue
        original = entry.get("net_signature") or {}
        current = _net_signature(target)
        same = original.get("multi") == current["multi"]
        out["circuits"].append({
            "circuit": name, "ok": bool(same),
            "cells_in": entry["cells"], "cells_out": len(target.comps),
            "nets_in": entry["nets"], "nets_out": len(target.nets),
            "unconnected_nets": len([n for n in target.nets if len(n.members) < 2]),
            "single_delta": current["singles"] - original.get("singles", 0),
        })
        if not same:
            out["ok"] = False
    return out


def _net_signature(circ: Circuit):
    """A position-independent fingerprint of a circuit's connectivity.

    Only nets that actually join two or more ends are part of the fingerprint: a net with
    a single member is an unconnected pin, and whether such a pin is or is not listed by
    a re-parse has no electrical meaning.
    """
    multi = []
    singles = 0
    for net in circ.nets:
        members = []
        for comp, i in net.members:
            port = comp.ports[i]
            members.append("%s:%s:%s:%d,%d" % (comp.name, comp.subcircuit or "-",
                                               comp.label or "-", port.dx, port.dy))
        if len(net.members) > 1:
            multi.append("|".join(sorted(members)))
        else:
            singles += 1
    return {"multi": sorted(multi), "singles": singles}


def _analysis_sheet(circ: Circuit) -> Sheet:
    sheet = Sheet(circ=circ)
    for comp in circ.comps:
        comp.new_loc = comp.loc
        comp.col = comp.level
        comp.row = 0
    sheet.ncols = circ.stats["max_level"] + 1
    sheet.nrows = 1
    return sheet


def main(argv=None):
    args = build_arg_parser().parse_args(argv)
    style = load_style(args.style)
    results = [process_file(path, args, style) for path in args.inputs]

    summary_rows = []
    for res in results:
        print("")
        print("### %s" % res["file"])
        for err in res["errors"]:
            print("  ERROR: %s" % err)
        for circ in res["circuits"]:
            if not args.quiet:
                print("")
                for line in _circuit_report_lines(res, circ):
                    print(line)
            summary_rows.append([os.path.basename(res["file"]), circ["name"], circ["cells"],
                                 circ["nets"], circ["levels"], circ["cycles"],
                                 circ["inputs"], circ["outputs"], circ["shorts"]])
    print("")
    print("Summary")
    for line in _table(summary_rows, ["file", "circuit", "cells", "nets", "levels",
                                      "cycles", "in", "out", "shorts"]):
        print(line)
    for res in results:
        for key, label in (("circ", "routed schematic"), ("verilog", "Verilog"),
                           ("png", "PNG")):
            if key in res:
                if isinstance(res[key], list):
                    for item in res[key]:
                        print("  %-16s %s (%dx%d)" % (label, item["path"], item["width"],
                                                      item["height"]))
                else:
                    print("  %-16s %s" % (label, res[key]))
    if args.json:
        with open(args.json, "w", encoding="utf-8") as fh:
            json.dump(results, fh, indent=2, sort_keys=True, default=str)
        print("  %-16s %s" % ("statistics", args.json))
    return 0 if not any(r["errors"] for r in results) else 1


def _circuit_report_lines(res, circ):
    lines = ["-" * 78, "circuit %s" % circ["name"], "-" * 78,
             "  cells=%d nets=%d buses=%d levels=%d cycles=%d in=%d out=%d"
             % (circ["cells"], circ["nets"], circ["buses"], circ["levels"],
                circ["cycles"], circ["inputs"], circ["outputs"]),
             "  routed wires=%d opened=%d shorts=%d"
             % (circ["wires"], circ["opens"], circ["shorts"])]
    if circ["gates"]:
        lines.append("  gates: " + ", ".join("%s=%d" % (k, v) for k, v in
                                             sorted(circ["gates"].items(),
                                                    key=lambda kv: -kv[1])))
    if circ["warnings"]:
        lines.append("  warnings:")
        lines.extend("    - %s" % w for w in circ["warnings"][:10])
    return lines


if __name__ == "__main__":
    sys.exit(main())
