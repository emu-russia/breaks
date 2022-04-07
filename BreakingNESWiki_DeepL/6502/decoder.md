# Decoder

![6502_locator_decoder](/BreakingNESWiki/imgstore/6502/6502_locator_decoder.jpg)

The decoder is an ordinary demultiplexer, but a very large one. The formula for the demultiplexer is 21-to-130. Sometimes the 6502 instruction decoder is also called a PLA.

Topologically, the decoder is divided by ground lines into several groups, so we'll stick to the same division, for convenience.

The input signals are:
- /T0, /T1X: current cycle for short (2 clock) instructions. These signals are output from [dispatch logic](dispatch.md).
- /T2, /T3, /T4, /T5: current cycle for long instructions. Signals are output from [extended cycle counter](extra_counter.md).
- /IR0, /IR1, IR01: the lower bits of the operation code from [instruction register](ir.md). To reduce the number of lines 0 and 1 bits are combined into one control line `IR01`.
- IR2-IR7, /IR2-/IR7: direct and inverse values of the remaining bits. The direct and inverse forms are needed to check the bit for 0 and 1.

The decoder logic is based on the exclusion principle. Schematically, each output is a multi-input NOR element, which means that if at least one of the inputs has a 1, the whole line will NOT work.

That is, the decoder outputs are not in inverse logic (as is usual), but in direct logic.

![decoder_nice1](/BreakingNESWiki/imgstore/decoder_nice1.jpg)

![decoder_nice2](/BreakingNESWiki/imgstore/decoder_nice2.jpg)

The ttlworks version of the decoder:

![10_decoder](/BreakingNESWiki/imgstore/6502/ttlworks/10_decoder.png)

## Special Lines

Additional logical operations are applied to some decoder outputs, which although territorially are in the decoder area, are actually part of [random logic](random_logic.md). Most likely this logic got into the decoder simply because it was more convenient to split the connections that way.

List:
- Internal Push/Pull line: a special (129th) line that does not extend beyond the decoder. It is used to "cut off" Push/pull instructions when selecting instructions. It is used in three lines: 83, 90, and 128. Appears on the schematic in duplicate, for different parts of the decoder.
- /PRDY: this line goes to decoder line 73 (Branch T0)
- IR0: normally the common signal IR01 is used to check the two lowest bits of the operation code, but exclusively for the 128th line (IMPL), IR0 is used (IR0 is not included in the mask for the table below).

## PLA Contents

|Group|N|Mask value (Raw bits)|Decoded mask value|Cycle (T)|Comments|Where to use|
|---|---|---|---|---|---|---|
|A|||||||
|A01   |0 |000101100000100100000   |100XX100 |TX     |STY|Register control|
|A02   |1 |000000010110001000100   |XXX100X1 |T3     |OP ind, Y|Register control|
|A03   |2 |000000011010001001000   |XXX110X1 |T2     |OP abs, Y|Register control|
|A04   |3 |010100011001100100000   |1X001000 |T0     |DEY INY  |Register control|
|A05   |4 |010101011010100100000   |10011000 |T0     |TYA      |Register control|
|A06   |5 |010110000001100100000   |1100XX00 |T0     |CPY INY  |Register control|
|B|||||||
|B01   |6 |000000100010000001000   |XXX1X1XX |T2     |OP zpg, X/Y & OP abs, X/Y |Register control|
|B02   |7 |000001000000100010000   |10XXXX1X |TX     |LDX STX A<->X S<->X       |Register control|
|B03   |8 |000000010101001001000   |XXX000X1 |T2     |OP ind, X        |Register control|
|B04   |9 |010101011001100010000   |1000101X |T0     |TXA              |Register control|
|B05  |10 |010110011001100010000   |1100101X |T0     |DEX              |Register control|
|B06  |11 |011010000001100100000   |1110XX00 |T0     |CPX INX          |Register control|
|B07  |12 |000101000000100010000   |100XXX1X |TX     |STX TXA TXS|Register control|
|B08  |13 |010101011010100010000   |1001101X |T0     |TXS                |Register control|
|B09  |14 |011001000000100010000   |101XXX1X |T0     |LDX TAX TSX|Register control|
|B10  |15 |100110011001100010000   |1100101X |T1     |DEX|Register control|
|B11  |16 |101010011001100100000   |11101000 |T1     |INX|Register control|
|B12  |17 |011001011010100010000   |1011101X |T0     |TSX|Register control|
|B13  |18 |100100011001100100000   |1X001000 |T1     |DEY INY|Register control|
|B14  |19 |011001100000100100000   |101XX100 |T0     |LDY|Register control|
|B15  |20 |011001000001100100000   |1010XX00 |T0     |LDY TAY|Register control|
|C|||||||
|C01  |21 |011001010101010100000   |00100000 |T0     |JSR|Register control|
|C02  |22 |000101010101010100001   |00000000 |T5     |BRK|Register control; Auxiliary signal BRK5|
|C03  |23 |010100011001010100000   |0X001000 |T0     |Push|Register control|
|C04  |24 |001010010101010100010   |01100000 |T4     |RTS|Register control|
|C05  |25 |001000011001010100100   |0X101000 |T3     |Pull|Register control|
|C06  |26 |000110010101010100001   |01000000 |T5     |RTI|Register control; Auxiliary signal RTI/5|
|C07  |27 |001010000000010010000   |011XXX1X |TX     |ROR|To obtain an auxiliary /ROR signal for the ADD/SB7 circuit|
|C08  |28 |000000000000000001000   |XXXXXXXX |T2     |T2 ANY|Auxiliary signal T2 (processor is in cycle T2)|
|C09  |29 |010110000000011000000   |010XXXX1 |T0     |EOR|ALU Control|
|C10  |30 |000010101001010100000   |01X01100 |TX     |JMP (excluder for C11)|ALU Control|
|C11  |31 |000000101001000001000   |XXX011XX |T2     |ALU absolute|ALU Control|
|C12  |32 |010101000000011000000   |000XXXX1 |T0     |ORA|ALU Control|
|C13  |33 |000000000100000001000   |XXXX0XXX |T2     |The entire "left" half of the opcode table (values `X0-X7`)|ALU Control|
|C14  |34 |010000000000000000000   |XXXXXXXX |T0     |T0 ANY|ALU Control|
|C15  |35 |000000010001010101000   |0XX0X000 |T2     |BRK JSR RTI RTS Push/pull - stack operations on T2|Regs Control, ALU Control; Auxiliary signal STK2|
|C16  |36 |000000000001010100100   |0XX0XX00 |T3     |BRK JSR RTI RTS Push/pull + BIT JMP|ALU Control|
|D|||||||
|D01  |37 |000001010101010100010   |00X00000 |T4     |BRK JSR|ALU Control|
|D02  |38 |000110010101010100010   |01000000 |T4     |RTI|ALU Control|
|D03  |39 |000000010101001000100   |XXX000X1 |T3     |OP X, ind|ALU Control|
|D04  |40 |000000010110001000010   |XXX100X1 |T4     |OP ind, Y|ALU Control|
|D05  |41 |000000010110001001000   |XXX100X1 |T2     |OP ind, Y|ALU Control|
|D06  |42 |000000001010000000100   |XXX11XXX |T3     |RIGHT ODD|ALU Control|
|D07  |43 |001000011001010100000   |0X101000 |TX     |Pull|ALU Control|
|D08  |44 |001010000000100010000   |111XXX1X |TX     |INC NOP|ALU Control|
|D09  |45 |000000010101001000010   |XXX000X1 |T4     |OP X, ind|ALU Control; Bus Control (DL/DB)|
|D10  |46 |000000010110001000100   |XXX100X1 |T3     |OP ind, Y|Bus Control (DL/DB)|
|D11  |47 |000010010101010100000   |01X00000 |TX     |RTI RTS|Bus Control (DL/DB); Auxiliary signal RET|
|D12  |48 |001001010101010101000   |00100000 |T2     |JSR|Auxiliary signal JSR2|
|D13  |49 |010010000001100100000   |11X0XX00 |T0     |CPY CPX INY INX|ALU Control|
|D14  |50 |010110000000101000000   |110XXXX1 |T0     |CMP|ALU Control|
|D15  |51 |011010000000101000000   |111XXXX1 |T0     |SBC|ALU Control; Auxiliary signal SBC0|
|D16  |52 |011010000000001000000   |X11XXXX1 |T0     |ADC SBC|ALU Control|
|D17  |53 |001001000000010010000   |001XXX1X |TX     |ROL|ALU Control|
|E|||||||
|E01  |54 |000010101001010100100   |01X01100 |T3     |JMP ind|ALU Control|
|E02  |55 |000001000000010010000   |00XXXX1X |TX     |ASL ROL|Bus Control|
|E03  |56 |001001010101010100001   |00100000 |T5     |JSR|Auxiliary signal JSR/5|
|E04  |57 |000000010001010101000   |0XX0X000 |T2     |BRK JSR RTI RTS Push/pull|Bus Control|
|E05  |58 |010101011010100100000   |10011000 |T0     |TYA|Bus Control|
|E06  |59 |100000000000011000000   |0XXXXXX1 |T1     |UPPER ODD|Bus Control|
|E07  |60 |101010000000001000000   |X11XXXX1 |T1     |ADC SBC|Bus Control|
|E08  |61 |100000011001010010000   |0XX0101X |T1     |ASL ROL LSR ROR|Bus Control|
|E09  |62 |010101011001100010000   |1000101X |T0     |TXA|Bus Control|
|E10  |63 |011010011001010100000   |01101000 |T0     |PLA|Bus Control|
|E11  |64 |011001000000101000000   |101XXXX1 |T0     |LDA|Bus Control|
|E12  |65 |010000000000001000000   |XXXXXXX1 |T0     |ALL ODD|Bus Control|
|E13  |66 |011001011001100100000   |10101000 |T0     |TAY|Bus Control|
|E14  |67 |010000011001010010000   |0XX0101X |T0     |ASL ROL LSR ROR|Bus Control|
|E15  |68 |011001011001100010000   |1010101X |T0     |TAX|Bus Control|
|E16  |69 |011001100001010100000   |0010X100 |T0     |BIT0|ALU Control (AND)|
|E17  |70 |011001000000011000000   |001XXXX1 |T0     |AND0|ALU Control (AND)|
|E18  |71 |000000001010000000010   |XXX11XXX |T4     |OP abs,XY|Bus Control (ADL/ABL)|
|E19  |72 |000000010110001000001   |XXX100X1 |T5     |OP ind,Y|Bus Control (ADL/ABL)|
|F|||||||
|F01  |73 |010000010110000100000   |XXX10000 |T0 |<-  Branch, additionally affected by the /PRDY line (from the RDY contact), immediately on the spot|Auxiliary signal BR0|
|F02  |74 |000110011001010101000   |01001000 |T2     |PHA|Bus Control (AC/DB)|
|F03  |75 |010010011001010010000   |01X0101X |T0     |LSR ROR|ALU Control (SR)|
|F04  |76 |000010000000010010000   |01XXXX1X |TX     |LSR ROR|ALU Control (SR)|
|F05  |77 |000101010101010101000   |00000000 |T2     |BRK|PC Control|
|F06  |78 |001001010101010100100   |00100000 |T3     |JSR|PC Control|
|F07  |79 |000101000000101000000   |100XXXX1 |TX     |STA|Auxiliary signal STA|
|F08  |80 |000000010110000101000   |XXX10000 |T2     |BR2 (Branch T2)|PC control circuit and PC increment circuit|
|F09  |81 |000000100100000001000   |XXXX01XX |T2     |zero page|Bus Control (DL/ADL)|
|F10  |82 |000000010100001001000   |XXXX00X1 |T2     |ALU indirect|Bus Control (DL/ADL)|
|F11  |83 |000000001000000001000   |XXXX1XXX |T2     |The entire "right" half of the opcode table (`X8-XF` values). The Push/Pull opcode exclusion operation is additionally applied to this line, right in place|Auxiliary signal ABS/2|
|F12  |84 |001010010101010100001   |01100000 |T5     |RTS|Auxiliary signal RTS/5|
|F13  |85 |000000000000000000010   |XXXXXXXX |T4     |T4 ANY|Bus Control (NOADL)|
|F14  |86 |000000000000000000100   |XXXXXXXX |T3     |T3 ANY|Bus Control (NOADL)|
|F15  |87 |010100010101010100000   |0X000000 |T0     |BRK RTI|Bus Control (NOADL)|
|F16  |88 |010010101001010100000   |01X01100 |T0     |JMP|Bus Control (IND)|
|F17  |89 |000000010101001000001   |XXX000X1 |T5     |OP X, ind|Bus Control (NOADL, IND)|
|F18  |90 |000000001000000000100   |XXXX1XXX |T3     |The entire "right" half of the opcode table (`X8-XF` values). The Push/Pull opcode exclusion operation is additionally applied to this line, right in place|Bus Control (IND)|
|G|||||||
|G01  |91 |000000010110001000010   |XXX100X1 |T4     |OP ind, Y|Cycle Counter Reset, Bus Control (IND)|
|G02  |92 |000000001010000000100   |XXX11XXX |T3     |RIGHT ODD|Cycle Counter Reset|
|G03  |93 |000000010110000100100   |XXX10000 |T3     |BR3 (Branch T3)|PC control circuit and PC increment circuit|
|G04  |94 |000100010101010100000   |0X000000 |TX     |BRK RTI|PC Control (JB)|
|G05  |95 |001001010101010100000   |00100000 |TX     |JSR|PC Control (JB)|
|G06  |96 |000010101001010100000   |01X01100 |TX     |JMP|PC Control (JB), ENDX (Long instruction completion)|
|P/P |129 |000000011001010100000   |0XX01000 |TX |<-  Push/pull opcodes, used as an exclusive for F11 & F18||
|G07  |97 |000101000000100000000   |100XXXXX |TX     |STORE|For RW Control and to obtain an auxiliary STOR signal|
|G08  |98 |000101010101010100010   |00000000 |T4     |BRK|RW Control, !POUT (flags control)|
|G09  |99 |000101011001010101000   |00001000 |T2     |PHP|!POUT (flags control)|
|G10 |100 |000100011001010101000   |0X001000 |T2     |Push|RW Control, ENDX (Long instruction completion)|
|G11 |101 |000010101001010100010   |01X01100 |T4     |JMP ind|ENDX, Bus Control; Auxiliary signal JMP/4|
|G12 |102 |000010010101010100001   |01X00000 |T5     |RTI RTS|ENDX (Long instruction completion)|
|G13 |103 |001001010101010100001   |00100000 |T5     |JSR|ENDX (Long instruction completion)|
|H|||||||
|H01 |104 |000110101001010101000   |01001100 |T2     |JMP abs|ENDX (Long instruction completion)|
|H02 |105 |001000011001010100100   |0X101000 |T3     |Pull|ENDX (Long instruction completion)|
|H03 |106 |000010000000000010000   |X1XXXX1X |TX     |LSR ROR DEC INC DEX NOP (4x4 bottom right)|Cycle Counter 5-6|
|H04 |107 |000001000000010010000   |00XXXX1X |TX     |ASL ROL|Cycle Counter 5-6, flags control|
|H05 |108 |010010011010010100000   |01X11000 |T0     |CLI SEI|flags control|
|H06 |109 |101001100001010100000   |0010X100 |T1     |BIT|flags control|
|H07 |110 |010001011010010100000   |00X11000 |T0     |CLC SEC|flags control|
|H08 |111 |000000100110000000100   |XXX101XX |T3     |Memory zero page X/Y|MemOP|
|H09 |112 |101010000000001000000   |X11XXXX1 |T1     |ADC SBC|flags control|
|H10 |113 |011001100001010100000   |0010X100 |T0     |BIT|flags control|
|H11 |114 |011001011001010100000   |00101000 |T0     |PLP|flags control|
|H12 |115 |000110010101010100010   |01000000 |T4     |RTI|flags control|
|H13 |116 |100110000000101000000   |110XXXX1 |T1     |CMP|flags control|
|H14 |117 |100010101001100100000   |11X01100 |T1     |CPY CPX abs|flags control|
|H15 |118 |100001011001010010000   |00X0101X |T1     |ASL ROL|flags control|
|H16 |119 |100010000101100100000   |11X00X00 |T1     |CPY CPX zpg/immed|flags control|
|K|||||||
|P/P |129 |000000011001010100000   |0XX01000 |TX     |<-  Push/pull opcodes, used as an exclusive for K09|![pp](/BreakingNESWiki/imgstore/6502/pp.jpg)|
|K01 |120 |010010011010100100000   |11X11000 |T0     |CLD SED|flags control|
|K02 |121 |000001000000000000000   |X0XXXXXX |TX     |/IR6|Branch Logic|
|K03 |122 |000000101001000000100   |XXX011XX |T3     |Memory absolute|MemOP|
|K04 |123 |000000100101000001000   |XXX001XX |T2     |Memory zero page|MemOP|
|K05 |124 |000000010100001000001   |XXXX00X1 |T5     |Memory indirect|MemOP|
|K06 |125 |000000001010000000010   |XXX11XXX |T4     |Memory absolute X/Y|MemOP|
|K07 |126 |000000000000010000000   |0XXXXXXX |TX     |/IR7|Branch Logic|
|K08 |127 |001001011010100100000   |10111000 |TX     |CLV|flags control|
|K09 |128 |000000011000000000000   |XXXX10X0 |TX     |IMPL. The Push/Pull opcode exclusion operation is additionally applied to this line, right on the spot. Also, the mask for this line does not take into account the `& ~IR0` operation|Bus Control (DL/DB)|

## What Raw bits mean

If you think of a decoder as a 21x130 ROM, where each bit represents a transistor, then the `Raw bits` value will represent one line of the decoder. This is why it is called the mask value.

For example, the picture shows the 5th line of the decoder. The bit counting starts from bottom to top. 0 means no transistor, 1 means present.

![decoder_line](/BreakingNESWiki/imgstore/decoder_line.jpg)

## Online Decoder

You can use an online decoder to highlight opcodes: https://github.com/emu-russia/breaks/blob/master/Docs/6502/decoder.htm

In the `Raw bits` field you can insert the mask value from the table above and when you press the `Make IR Mask` button you will get the decoded mask value (e.g. `11X00X00`). 
The decoded mask value can be inserted into the `IR` field and when the `Decode` button is pressed, the opcodes that correspond to the specified IR mask will be highlighted in the table.

## Branch T0 Skip

From pin [RDY](pads.md) a special line `/PRDY` comes through the delay line. If the processor was not ready when the _previous_ instruction finished, then if the next instruction is a conditional branch, its cycle 0 (T0) is skipped.

The meaning of this operation is not known yet.

## Why the decoder is so big and scary

Actually, there is nothing scary about it.

The decoder was compiled according to the requirements of random logic. Random logic is divided into several parts (domains) and each part corresponds to its own zone in the decoder, which was specially chosen so that the necessary opcodes were processed.

In other words - it is not random logic that adjusts to decoder, but vice versa. The impression that the decoder is "more important" is formed simply because it is above random logic.
