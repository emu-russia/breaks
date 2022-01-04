# MOS 6502 Core

MOS 6502 processor core emulator on the gate level.

## Approaches to simulation

Some modules are simulated immediately with output values. And for some, simulation and output values are separated for convenience.

In general, the source code is a bit like Verilog, but unlike the latter, we choose the sequence of execution of circuit elements ourselves,
thereby imitating the propagation delay that we have in real circuits.

If the module has few inputs/outputs, they are passed as parameters. If there are a lot of inputs/outputs, an array indexed by enum definitions is used as a parameter.
