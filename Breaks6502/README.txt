Breaks 6502.
Clock accurate MOS 6502 CPU emulator for speed applications.

Internally 6502 divided on 2 major parts : "top" and "bottom".

Top part do some intelligent actions and bottom part acting with outworld and contain heart of all calculations - ALU.

Top part components:
- Instruction register (IR)
- T-counter
- PLA decoder
- Predecoder
- Random logic (heavy tangle) including flags
- Miscellaneous logic: IRQ, NMI, reset handling and output pins

Bottom part components:
- Address bus outputs
- Data latch and read/write tri-state logic
- Registers X, Y, S
- Program Counter
- ALU

Top part controls bottom through special control lines - "drivers".

Clock phases.

6502 has two internal modes: "write mode" and "read mode".
To determine which mode is active in time, it use two internal clocks: PHI1 and PHI2, which are additionally outputs to outerworld.
When PHI1 is high 6502 works in "write mode", external devices can read from data bus.
And when PHI2 is high 6502 works in "read mode", external deviced can write to data bus.

Propagation timing.

Due to fact that propagation delay triggers different parts of CPU not in same time, 6502 emu must pay attention to this.
This is implemented in following way: internal components are dispatched one by one in sequence, according to its priority.

Download LCC here : http://www.cs.virginia.edu/~lcc-win32/
(Or search "lcc" in Google)