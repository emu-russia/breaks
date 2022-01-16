# Breaks Debugger

A simple GUI for checking the operation of the 6502 Core component (`M6502Core`).

![concept](concept.jpg)

The PropertyGrids shows signals, registers and rest of DebugInfo of the 6502 core.
Buttons above are manual control of the respective pins.
The CPU Memory tab displays the HexDump of the memory.
The Assembler tab shows a TextBox with the source, which will be assembled with the built-in Breakasm and loaded immediately into memory.

Breakasm and M6502Core are in their respective Interop DLLs.

## Build

You must use Debug/Release x86/x64 configuration to build. AnyCPU is not suitable because it uses native code in Interop DLLs.

Just don't forget to switch back to Any CPU when you need to edit forms. Microsoft has a problem with this.

## Processor state dump

To enable a detailed dump of all internals directly in Markdown and with pictures, you need to create the `WikiMarkdown` folder.
