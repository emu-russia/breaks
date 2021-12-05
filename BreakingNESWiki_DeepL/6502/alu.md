# ALU

![6502_locator_alu](/BreakingNESWiki/imgstore/6502_locator_alu.jpg)

It is not possible to show the whole ALU circuit, so let's saw it into its component parts and consider each one separately.

![alu_preview](/BreakingNESWiki/imgstore/alu_preview.jpg)

The ALU consists of the following components:
- Input circuits for AI/BI latch loading
- The main computational part (Operations)
- A fast carry calculation circuit for the BCD 
- Intermediate result (ADD latch)
- BCD correction circuit
- Accumulator (AC)

Generally speaking the ALU is a mess of transistors and wires, but its workings are not very complicated, as you can see later.

Overview of the ALU connections:

![alu_logisim](/BreakingNESWiki/imgstore/alu_logisim.jpg)

## AI/BI Latches

The input circuits consist of 8 identical chunks, which are designed to load input values on the AI and BI latches:

![alu_input_tran](/BreakingNESWiki/imgstore/alu_input_tran.jpg)

(The picture shows the circuit for bit 0, the rest are the same)

Control signals:
- DB/ADD: Load direct value from DB bus to the BI latch
- NDB/ADD: Load inverse value from DB bus to the BI latch
- ADL/ADD: Load a value from the ADL bus to the BI latch
- SB/ADD: Load a value from the SB bus to the AI latch
- 0/ADD: Write 0 to the AI latch

## Computational Part

The ALU uses an inverted carry chain, so the even and odd bit circuits alternate.

Bit 0 is slightly different from the other even bits because it has an input carry (`/ACIN`) and no `SRS` input.

Schematic for bit 0:

![alu_bit0_tran](/BreakingNESWiki/imgstore/alu_bit0_tran.jpg)

Schematics for bits 1, 3, 5, 7:

![alu_bit_odd_tran](/BreakingNESWiki/imgstore/alu_bit_odd_tran.jpg)

(The circuit for bit 1 is shown, the rest are the same)

Schematics for bits 2, 4, 6:

![alu_bit_even_tran](/BreakingNESWiki/imgstore/alu_bit_even_tran.jpg)

(The circuit for bit 2 is shown, the rest are the same)

Anatomically, the left side deals with logical operations, the right side is the adder (Full Adder), and in the middle is the carry chain.

Control signals for ALU operations:
- ORS: Logical OR operation (AI | BI)
- ANDS: Logical AND operation (AI & BI)
- EORS: Logical XOR operation (AI ^ BI)
- SRS: Shift Right. For this the result of the current `nand` operation is stored as the result of the previous bit.  
- SUMS: Summation (AI + BI)

Notations on the schematics:
- nand: intermediate result of NAND operation for the selected bit
- and: intermediate result of AND operation for the selected bit (obtained by `nand` inversion)
- nor: intermediate result of NOR operation for a selected bit
- xor: intermediate result of EOR operation for the selected bit
- nxor: intermediate result of an ENOR operation for the selected bit
- carry: the result of a carry operation. The carry chain is inverted every bit, but for simplicity all `carry` names do not consider value inversion.
- res: the result of a logical operation or the result of an adder which is then stored on the ADD latch. The result of an operation in inverted form.

To make it clearer how the intermediate results are obtained, all the main motifs are marked in the image below:

![alu_bit_annotated_tran](/BreakingNESWiki/imgstore/alu_bit_annotated_tran.jpg)

(Bit 1 is shown, for the other bits the motif looks similar)

Logic for even bits:

![alu_even_bit_logisim](/BreakingNESWiki/imgstore/logisim/alu_even_bit_logisim.jpg)

Logic for odd bits:

![alu_odd_bit_logisim](/BreakingNESWiki/imgstore/logisim/alu_odd_bit_logisim.jpg)

Overflow calculation (control signal `AVR`):

![alu_avr_tran](/BreakingNESWiki/imgstore/alu_avr_tran.jpg)

## Fast BCD Carry

This is the circuit that appears in patent US 3991307 (https://patents.google.com/patent/US3991307A).

![alu_bcd_carry_tran1](/BreakingNESWiki/imgstore/alu_bcd_carry_tran1.jpg)

![alu_bcd_carry_tran2](/BreakingNESWiki/imgstore/alu_bcd_carry_tran2.jpg)

The schematics are "layered on the side" for easy perception.

`DC3` output is connected to the carry chain as follows:

![alu_carry3_tran](/BreakingNESWiki/imgstore/alu_carry3_tran.jpg)

How exactly this circuit works is written in the patent, I have nothing much to add. Just a mishmash of logic gates - do the same and it will work.

Besides calculating the carry for BCD the circuit also generates the `ACR` (ALU carry for flags) and `DAAH` control signals for the BCD correction circuit.

Logic:

![alu_bcd_carry_logisim](/BreakingNESWiki/imgstore/logisim/alu_bcd_carry_logisim.jpg)

## Intermediate Result (ADD)

The intermediate result is stored on the ADD latch (stored in inverted form, output to the buses in direct form). The ADD latch circuit consists of 8 identical pieces:

![alu_add_tran](/BreakingNESWiki/imgstore/alu_add_tran.jpg)

(The circuit is shown for bit 0, the others are the same)

- ADD/SB06: Place the value of the ADD latch on the SB bus. The control signal `ADD/SB7` is used instead of ADD/SB06 for bit 7.
- ADD/ADL: Place the ADD latch value on the ADL bus

## BCD Correction

The BCD correction circuit is controlled by two signals: `/DAA` (perform correction after addition) and `/DSA` (perform correction after subtraction).

The outputs of the circuit are connected to the accumulator inputs (AC) and the circuit takes into account the ALU operation when the BCD mode is disabled.

Some of the accumulator inputs are connected directly to the SB bus and do not participate in BCD correction (bits 0 and 4).

The circuit uses 4 auxiliary internal signals in its operation: DAAL, DAAH, DSAL and DSAH. The "L" in the name stands for the lower part of the bits (0-3), the "H" stands for the higher part of the bits (4-7).

Circuits for obtaining auxiliary signals:

|DAAL|DSAL|DSAH|
|---|---|---|
|![alu_daal_tran](/BreakingNESWiki/imgstore/alu_daal_tran.jpg)|![alu_dsal_tran](/BreakingNESWiki/imgstore/alu_dsal_tran.jpg)|![alu_dsah_tran](/BreakingNESWiki/imgstore/alu_dsah_tran.jpg)|

The `DAAH` circuit is in the carry circuit.

The correction circuits use a common motif:
- The input combinatorial circuits, in various combinations accounting for the 4 auxiliary signals and the bits of the intermediate result (ADD latches)
- Output xor, one of the inputs of which is a bit of the bus SB, and the second of the above combinatorial circuits

Sawed schematics:

|Bit 1|Bit 2|Bit 3|Bit 5|Bit 6|Bit 7|
|---|---|---|---|---|---|
|![alu_bcd1_tran](/BreakingNESWiki/imgstore/alu_bcd1_tran.jpg)|![alu_bcd2_tran](/BreakingNESWiki/imgstore/alu_bcd2_tran.jpg)|![alu_bcd3_tran](/BreakingNESWiki/imgstore/alu_bcd3_tran.jpg)|![alu_bcd5_tran](/BreakingNESWiki/imgstore/alu_bcd5_tran.jpg)|![alu_bcd6_tran](/BreakingNESWiki/imgstore/alu_bcd6_tran.jpg)|![alu_bcd7_tran](/BreakingNESWiki/imgstore/alu_bcd7_tran.jpg)|

The auxiliary signals /ADDx on the BCD correction circuits are derived from the values of the ADD latch bits as follows:

![alu_add_temp_tran](/BreakingNESWiki/imgstore/alu_add_temp_tran.jpg)

(Using `/ADD5` as an example)

Logic:

![alu_bcd_logisim](/BreakingNESWiki/imgstore/logisim/alu_bcd_logisim.jpg)

## Accumulator (AC)

The accumulator consists of eight identical pieces:

![alu_ac_tran](/BreakingNESWiki/imgstore/alu_ac_tran.jpg)

(The circuit for bit 3 is shown, the others are the same)

The accumulator inputs a value from the BCD correction circuit (bits 1-3, 5-7) or directly from the SB bus (bits 0 and 4).

In addition to directly outputting the accumulator to the SB and DB buses, other bus operations are also performed at this point, so they are also discussed in this section.

- SB/AC: Place the value from the SB bus/BCD correction circuit into the accumulator
- AC/SB: Place the AC value on the SB bus
- AC/DB: Place the AC value on the DB bus
- SB/DB: Connect the SB bus to DB bus
- SB/ADH: Connect the SB bus to ADH bus
- 0/ADH17: Forced write 0 to ADH bits 1-7. The control signal `0/ADH0` is used for bit 0 instead of 0/ADH17.
