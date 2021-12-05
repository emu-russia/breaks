# 6502

The 6502 processor was developed by [MOS](../MOS.md). It was based on the architecture of the Motorola 6800 processor:

|6502|6800|
|---|---|
|<img src="/BreakingNESWiki/imgstore/6502_die_shot.jpg" width="200px">|<img src="/BreakingNESWiki/imgstore/6800.jpg" width="220px">|

In both cases the top part is occupied by the decoder and random logic, and the whole bottom part of the processor is occupied by the context and the ALU.

## Architecture

The processor is divided into two parts: the upper part and the lower part.

The upper part contains the control logic, which issues a number of control lines ("commands") to the lower part.
The lower part contains the context of the processor: internal buses and registers, with one exception - the flags register (P) is in the upper part in a "spread out" form.

Also in the lower part is the [ALU](alu.md).

The processor is clocked by the PHI0 clock pulse, both half-cycles are used.
During the first half-cycle (PHI1) the processor is in "talking" mode. At this time the processor is outputting data to the outside.
During the second half-cycle (PHI2) the processor is in "listening" mode, during this half-cycle external devices can put data on the data bus for the processor to process it.

6502 overview chart:

![6502_logisim_big](/BreakingNESWiki/imgstore/6502_logisim_big.png)

## Registers

- PD: current operation code for precoding
- IR: instruction register (stores the current operation code)
- X, Y: index registers
- S: Stack pointer
- AI, BI: input values for ALU
- ADD: Intermediate result of an ALU operation
- AC: accumulator
- PCH/PCL: program counter in two halves
- PCHS/PCLS: program counter auxiliary registers (S stands for "set" (?))
- ABH/ABL: registers for output to the external address bus
- DL: data latch, stores the last read value of the external data bus
- DOR: data output register, holds the value which will be written to the data bus
- P: flag register, actually consists of a set of latches scattered around the circuit

The following registers are directly available to the programmer: A (accumulator), X, Y, S, P, PC.

## External Buses

There are only two external buses: a 16-bit address bus (ADDR) and an 8-bit data bus (DATA). The address bus is one-way - only the processor can write to it. The data bus is bidirectional.

## Internal Buses

- ADH/ADL: address bus
- SB: side(?) bus, register exchange bus
- DB: Internal data bus

During the second half-step (PHI2) all internal buses are precharged and have a value of 0xff. This is done because it is faster to "discharge" the transistor at the right moment than to "charge" it (the change of 1=>0 is faster than the change of 0=>1).

## Register-Bus Connections

![6502_context](/BreakingNESWiki/imgstore/6502_context.jpg)

By connecting buses and registers in series, the processor executes a variety of instructions. The variety of connections provides a variety of processor instructions, and the division of instructions into clock cycles allows complex actions to be performed. In addition, the ALU is controlled (addition, logical operations, etc.).

## Software Model

### Addressing Modes

Addressing modes are described here because they should be kept in mind when analyzing circuits.

**Addressing** is a way to get the operand to (or load it from) the desired memory location. The developers of the 6502 were very generous and added as many as two X and Y index registers to the context.

"Indexed" means that an offset is added to the memory address in a certain way to get a new address. This is usually needed to access arrays. In this case the beginning of the array will be a fixed address and the value in the index register will be the array index (offset).

List of addressing modes:
- Immediate (immediate operand). In this case the operand is stored in the instruction itself (usually the second byte, after the operation code). Example `LDA #$1C`: A = 0x1C
- Absolute (absolute addressing). The instruction specifies the full 16-bit address from which to get the operand. For example `LDA $1234`: A = \[$1234\]
- Zero Page Absolute: Developers have made an optimized version of absolute addressing by adding the ability to address only page zero (pages are 256 bytes in size). Example `LDA $56`: In this case the processor itself makes the highest 8 bits of the address equal to 0x00, while the lowest 8 bits are taken from the instruction. The final address is 0x0056. A = \[0x0056\]. This is done to save instruction size (one byte is saved).
- Indexed: In this addressing mode an offset from the X or Y register is added to the constant address value. For example `LDA $1234, X`: A = \[$1234 + X\]
- Zero Page Indexed: Similar to Indexed but only the X register can be used. Example `LDA $33, X`: A = \[$0033 + X\]

And then the special magic begins:
- Pre-indexed Indirect: The value of the operand which is the address in page zero is added to the value of register X and the indirect address is obtained. The address the indirect address refers to is then used to get the value of the operand. Example `LDA ($34, X)`: A = \[\[$0034 + X\]\]. Important: When you add an address and a value in the X register, it "wraps" around 256 bytes. That is, it does not wrap to the higher half of the address. (0xFF + 0x02 will be 0x0001, not 0x0101). **Indirect** means "take address by address".
- Post-indexed Indirect: Different from the previous one in that the indirect address from page zero is selected first, and then the index register Y value is added to it. Example `LDA ($2A), Y`: A = \[\[$002A\] + Y\].

### Instruction Set

The 6502 has all the necessary instructions and also includes such rather handy instructions as bit rotation (ROL/ROR) and bit testing (BIT). Not all processors of the time contained such instructions.

The instruction type and address mode are fully contained in the operation code, to simplify decoding, but the bus width (8 bits) does not allow all instructions to be executed in a single clock cycle. Also, the decoder is somewhat unoptimized, so the minimum instruction execution time is 2 clock cycles, with the first clock cycle always taken by sampling the operation code (the first byte of the instruction).

Summary of instructions:

|Instruction|Description|
|---|---|
|ADC |Add Memory to Accumulator with Carry|
|AND |"AND" Memory with Accumulator|
|ASL |Shift Left One Bit (Memory or Accumulator)|
|BCC |Branch on Carry Clear|
|BCS |Branch on Carry Set|
|BEQ |Branch on Result Zero|
|BIT |Test Bits in Memory with Accumulator|
|BMI |Branch on Result Minus|
|BNE |Branch on Result not Zero|
|BPL |Branch on Result Plus|
|BRK |Force Break|
|BVC |Branch on Overflow Clear|
|BVS |Branch on Overflow Set|
|CLC |Clear Carry Flag|
|CLD |Clear Decimal Mode|
|CLI |Clear interrupt Disable Bit|
|CLV |Clear Overflow Flag|
|CMP |Compare Memory and Accumulator|
|CPX |Compare Memory and Index X|
|CPY |Compare Memory and Index Y|
|DEC |Decrement Memory by One|
|DEX |Decrement Index X by One|
|DEY |Decrement Index Y by One|
|EOR |"Exclusive-Or" Memory with Accumulator|
|INC |Increment Memory by One|
|INX |Increment Index X by One|
|INY |Increment Index Y by One|
|JMP |Jump to New Location|
|JSR |Jump to New Location Saving Return Address|
|LDA |Load Accumulator with Memory|
|LDX |Load Index X with Memory|
|LDY |Load Index Y with Memory|
|LSR |Shift Right One Bit (Memory or Accumulator)|
|NOP |No Operation|
|ORA |"OR" Memory with Accumulator|
|PHA |Push Accumulator on Stack|
|PHP |Push Processor Status on Stack|
|PLA |Pull Accumulator from Stack|
|PLP |Pull Processor Status from Stack|
|ROL |Rotate One Bit Left (Memory or Accumulator)|
|ROR |Rotate One Bit Right (Memory or Accumulator)|
|RTI |Return from Interrupt|
|RTS |Return from Subroutine|
|SBC |Subtract Memory from Accumulator with Borrow|
|SEC |Set Carry Flag|
|SED |Set Decimal Mode|
|SEI |Set Interrupt Disable Status|
|STA |Store Accumulator in Memory|
|STX |Store Index X in Memory|
|STY |Store Index Y in Memory|
|TAX |Transfer Accumulator to Index X|
|TAY |Transfer Accumulator to Index Y|
|TSX |Transfer Stack Pointer to Index X|
|TXA |Transfer Index X to Accumulator|
|TXS |Transfer Index X to Stack Pointer|
|TYA |Transfer Index Y to Accumulator|

The developers chose the encoding so that it would be easier to process by [decoder](decoder.md) and [random logic](random_logic.md).

Table of 6502 opcodes (for reference):

![6502_opcode_table](/BreakingNESWiki/imgstore/6502_opcode_table.jpg)

You can find a description of the instructions in any Reference Manual for 6502.

### Interrupts

6502 interrupts:
- IRQ: hardware interrupt. Can be disabled with flag I (interrupt disable), if flag I=1 the interrupt is "disabled" and does not go to the CPU. 
- NMI: non-maskable interrupt. It has higher priority than IRQ, triggered on falling edge. 
- RES: hardware reset. After powering up the 6502 it is necessary to set the /RES pin to 0 for a few cycles so that the processor "comes to its senses".
- BRK: software interrupt. It is initiated by the `BRK` instruction.

## Note on Transistor Circuits

The transistor circuits of each component are chopped into component parts so that they don't take up too much space.

To keep you from getting lost, each section includes a special "locator" at the beginning that marks the approximate location of the component being studied on the large 6502 "family portrait" (https://github.com/emu-russia/breaks/blob/master/Docs/6502/6502.jpg)

Example locator:

![6502_locator_alu_control](/BreakingNESWiki/imgstore/6502_locator_alu_control.jpg)
