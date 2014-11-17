// Synthesizable MOS 6502 on Verilog
// Project Breaks http://breaknes.com

//`define QUARTUS
`define ICARUS

// Enable APU 2A03 Decimal Correction hack (disable BCD correction)
// Appliable only for NES / Famicom.
//`define BCD_HACK

// Level-sensitive D-latch (required for N-MOS)
// http://quartushelp.altera.com/14.0/mergedProjects/hdl/prim/prim_file_latch.htm
module mylatch( 
   // Outputs 
   dout, 
   // Inputs 
   din, en 
);
    input din; 
    output dout; 
    input  en; // latch enable 
`ifndef QUARTUS
    reg dout; 
    always @(din or en) 
         if (en == 1'b1) 
           dout <= din;   //Use non-blocking
`else
    LATCH MyLatch (.d(din), .ena(en), .q(dout));
`endif      // QUARTUS
endmodule // mylatch

// --------------------------------------------------------------------------------
// TOP PART

// ------------------
// Decoder

// http://breaknes.com/files/6502/decoder.htm
// http://wiki.breaknes.com/6502:decoder

module Decoder (
  // Outputs
  decoder_out,
  // Inputs
  instr_reg, _timer
);

    input [7:0] instr_reg;
    input [5:0] _timer;
    output [129:0] decoder_out;

    reg [129:0] decoder_out;        // On real 6502 these are actually wires array
    wire [20:0] inputs;

    // Assign inputs as it happen in real decoder.
    assign inputs[0] = _timer[1];
    assign inputs[1] = _timer[0];
    assign inputs[2] = ~ instr_reg[5];
    assign inputs[3] = instr_reg[5];
    assign inputs[4] = ~ instr_reg[6];
    assign inputs[5] = instr_reg[6];
    assign inputs[6] = ~ instr_reg[2];
    assign inputs[7] = instr_reg[2];
    assign inputs[8] = ~ instr_reg[3];
    assign inputs[9] = instr_reg[3];
    assign inputs[10] = ~ instr_reg[4];
    assign inputs[11] = instr_reg[4];
    assign inputs[12] = ~ instr_reg[7];
    assign inputs[13] = instr_reg[7];
    assign inputs[14] = ~ instr_reg[0];
    assign inputs[15] = instr_reg[0] | instr_reg[1];    // IR01
    assign inputs[16] = ~ instr_reg[1];
    assign inputs[17] = _timer[2];
    assign inputs[18] = _timer[3];
    assign inputs[19] = _timer[4];
    assign inputs[20] = _timer[5];

always #1 @(*) begin

    // By default all decoder outputs are zero.
    decoder_out = 0;        // CHECK : Is it synthesizable ??? Can we just zero it?

    case (inputs)
        21'b000101100000100100000: decoder_out[0] <= 1'b1;
        21'b000000010110001000100: decoder_out[1] <= 1'b1;
        21'b000000011010001001000: decoder_out[2] <= 1'b1;
        21'b010100011001100100000: decoder_out[3] <= 1'b1;
        21'b010101011010100100000: decoder_out[4] <= 1'b1;
        21'b010110000001100100000: decoder_out[5] <= 1'b1;

    endcase

    // Line 128 (IMPL)
    decoder_out[128] <= ~ (instr_reg[0] | instr_reg[2] | ~instr_reg[3]);

    // Line 129 (Push/Pull)

end

endmodule     // Decoder

// ------------------
// Interrupt Control

// This stuff looks complicated, because of old-school style #NMI edge-detection
// (edge detection is based on cross-coupled RS flip/flops)

module InterruptControl (
    // Outputs
    Z_ADL0, Z_ADL1, Z_ADL2, DORES, RESP, BRK6E, B_OUT,
    // Inputs
    PHI0, _NMI, _IRQ, _RES, _I_OUT, BR2, T0, BRK5, _ready
);

    input PHI0, _NMI, _IRQ, _RES, _I_OUT, BR2, T0, BRK5, _ready;
    output Z_ADL0, Z_ADL1, Z_ADL2, DORES, RESP, BRK6E, B_OUT;

    wire Z_ADL0, Z_ADL1, Z_ADL2;
    wire DORES, RESP, BRK6E, B_OUT;

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    // Input pads flip/flops.
    reg NMIP_FF, IRQP_FF, RESP_FF;
    wire _NMIP, _IRQP;      // internal wires.
    assign _NMIP = NMIP_FF;
    mylatch IRQP_Latch (_IRQP, IRQP_FF, PHI1);
    mylatch RESP_Latch (RESP, ~RESP_FF, PHI1);

    // Interrupt cycle 6-7.
    wire BRK7;  // internal
    wire Latch1_Out, Latch2_Out;
    mylatch Latch1 (Latch1_Out, BRK5 & ~_ready, PHI2);
    mylatch Latch2 (Latch2_Out, ~(BRK5 & Latch2_Out) & ~Latch1_Out, PHI1);
    mylatch Latch3 (BRK6E, Latch2_Out, PHI2);
    assign BRK7 = ~(Latch2_Out | BRK5);

    // Reset FLIP/FLOP
    wire Latch4_Out, Latch5_Out; 
    mylatch Latch4 (Latch4_Out, RESP, PHI2);
    mylatch Latch5 (
        Latch5_Out,
        ~(BRK6E | ~(~Latch4_Out | ~Latch5_Out) ), PHI1);
    assign DORES = (~Latch4_Out | ~Latch5_Out);     // DO Reset

    // NMI Edge Detection
    // CHECK : Does this stuff actually work at all after synthesize?
    wire _DONMI;        // internal
    wire Latch6_Out, Latch7_Out, Latch8_Out, Latch9_Out;
    wire Latch10_Out, Latch11_Out, Latch12_Out, LastLatch_Out;
    wire temp;
    mylatch Latch6 (Latch6_Out, _NMIP, PHI1);
    mylatch Latch7 (Latch7_Out, BRK7, PHI2);
    mylatch Latch8 (Latch8_Out, _DONMI, PHI2);
    mylatch Latch9 (Latch9_Out, BRK6E & ~_ready, PHI1);
    mylatch Latch10 (Latch10_Out, _DONMI, PHI2);
    mylatch Latch11 (Latch11_Out, ~Latch10_Out, PHI1);
    assign temp = ~( Latch6_Out | (~( Latch11_Out | Latch12_Out)) );
    mylatch Latch12 (Latch12_Out, temp, PHI2);
    mylatch LastLatch ( LastLatch_Out, ~(~Latch7_Out | _NMIP | temp), PHI1);
    assign _DONMI = ~( LastLatch_Out | ~(Latch8_Out | Latch9_Out) );        // DO NMI after all

    // Interrupt Check
    wire IntCheck;      // internal
    assign IntCheck = 
        ( (~( ( ~( ~(_I_OUT & ~BRK6E) | _IRQP) ) | ~_DONMI )) | ~(BR2 | T0));

    // B-Flag
    wire BLatch1_Out, BLatch2_Out;
    mylatch BLatch1 (BLatch1_Out, ~(BRK6E | BLatch2_Out), PHI1);
    mylatch BLatch2 (BLatch2_Out, IntCheck & ~BLatch1_Out, PHI2);
    assign B_OUT = ~( (~(BRK6E | BLatch2_Out)) | DORES);        // no need to do additional checks for RESET

    // Interrupt Vector address lines controls.
    // 0xFFFA   NMI         (ADL[2:0] = 3'b010)
    // 0xFFFC   RESET       (ADL[2:0] = 3'b100)
    // 0xFFFE   IRQ         (ADL[2:0] = 3'b110)
    wire ADL0_Latch_Out, ADL1_Latch_Out, ADL2_Latch_Out;
    mylatch ADL0_Latch ( ADL0_Latch_Out, BRK5, PHI2);
    mylatch ADL1_Latch ( ADL1_Latch_Out, (BRK7 | ~DORES), PHI2);
    mylatch ADL2_Latch ( ADL2_Latch_Out, ~(BRK7 | _DONMI | DORES), PHI2);
    assign Z_ADL0 = ~ADL0_Latch_Out;
    assign Z_ADL1 = ~ADL1_Latch_Out;
    assign Z_ADL2 = ADL2_Latch_Out;     // watch this carefully

always #1 @(PHI2) begin    // Lock pads on input FFs         
    NMIP_FF <= _NMI;
    IRQP_FF <= _IRQ;
    RESP_FF <= _RES;
end

endmodule   // InterruptControl

// ------------------
// Random Logic

module RandomLogic (
    // Outputs

    // Inputs

);


    // Temp Wires and Latches (helpers)

    // XYS Regs Control

    // ALU Control

    // ADH/ADL Control

    // SB/DB Control

    // PCH/PCL Control

    // DL Control

    // Flags Control

endmodule   // RandomLogic

// ------------------
// Flags

// ------------------
// Instruction Register (IR)

// Controls:
// FETCH: Load IR from PD (Predecode Latch)

module InstructionRegister (
    // Outputs
    IR,
    // Inputs
    PHI0, FETCH, _PD
);

    input PHI0, FETCH;
    input [7:0] _PD;        // Active-low!

    output [7:0] IR;

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    reg [7:0] IR = 8'b11111111;     // Power-up state (IR = 0xFF)

initial begin
    IR = 8'b11111111;       // For safety.
end

always @(PHI1) begin
    if (FETCH) IR = ~_PD;
end

endmodule   // InstructionRegister

// ------------------
// Predecode

// Controls:
// 0/IR : "Inject" BRK opcode after interrupt (force IR = 0x00), to initiate common "BRK-sequence" service
// #IMPLIED : NOT Implied instruction (has operands)
// #TWOCYCLE : NOT short two-cycle instruction (more than 2 cycles)

module Predecode (
    // Outputs
    PD, _IMPLIED, _TWOCYCLE,
    // Inputs
    PHI0, Z_IR,
    // Buses
    DATA
);

    input PHI0, Z_IR;

    output [7:0] PD;
    output _IMPLIED, _TWOCYCLE;

    inout [7:0] DATA;

    wire [7:0] DATA;

    reg [7:0] PD = 8'b00000000;     // Power-up state

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    wire temp1, temp2;
    wire [7:0] pdout;
    assign pdout = Z_IR ? 8'b00000000 : PD;

    assign _IMPLIED = (pdout[0] | pdout[2] | ~pdout[3]);

    assign temp1 = ~(~pdout[0] | pdout[2] | ~pdout[3] | pdout[4]);
    assign temp2 = ~(pdout[0] | pdout[2] | pdout[3] | pdout[4] | ~pdout[7]); 
    assign _TWOCYCLE = (~(temp1 | temp2) & ~(~_IMPLIED & (pdout[1] | pdout[4] | pdout[7])));

initial begin
    PD = 8'b00000000;       // For safety
end

always @(PHI2) begin        // D-latch array on real 6502
    PD = DATA;
end

endmodule   // Predecode

// ------------------
// Branch Logic

// ------------------
// Dispatcher

module Dispatcher (
    // Outputs

    // Inputs

);

    // Ready Control

    // R/W Control

    // Short Cycle Counter (T0-T1)

    // Long Cycle Counter (T2-T5)

    // Extra Cycle Counter (T5-T6)

    // Instruction Termination (reset cycle counters)

    // ACR Latch

    // Program Counter Increment Control

    // Fetch Control

endmodule   // Dispatcher

// --------------------------------------------------------------------------------
// BOTTOM PART

// ------------------
// Internal Buses

    // Precharge buses
    // Precharge is not only used in mean of optimized value exchange, but also in special cases
    // (for example during interrupt vector assignment)
    // SB_DB

// ------------------
// XYS Registers

// On real 6502 XYS registers are "refreshed" during PHI2 and loaded by new values during PHI1.

// Controls:
// X/SB : Put X on SB bus
// Y/SB : Put Y on SB bus
// SB/X : Load X from SB bus
// SB/Y : Load Y from SB bus
// S/SB : Put S on SB bus
// S/ADL : Put S on ADL bus
// S/S : Maintain S (refresh)
// SB/S : Load S from SB bus

module XYSRegs (
    // Inputs
    Y_SB, SB_Y, X_SB, SB_X, S_SB, S_ADL, S_S, SB_S,
    // Buses
    SB, ADL
);

    input Y_SB, SB_Y, X_SB, SB_X, S_SB, S_ADL, S_S, SB_S;

    inout [7:0] SB, ADL;

    wire [7:0] SB, ADL;

    reg [7:0] X = 8'b00000000, Y = 8'b00000000, S = 8'b11111111;    // Power-up state

    assign SB = X_SB ? X : 8'bzzzzzzzz;
    assign SB = Y_SB ? Y : 8'bzzzzzzzz;
    assign SB = S_SB ? S : 8'bzzzzzzzz;
    assign ADL = S_ADL ? S : 8'bzzzzzzzz;

initial begin           // Power-up state for safety
    X = 8'b00000000;
    Y = 8'b00000000;
    S = 8'b11111111;
end

always @(*) begin
    if (SB_X) X = SB;
    if (SB_Y) Y = SB;
    if (SB_S) S = SB;
    if (S_S) S = S;     // refresh
end

endmodule   // XYSRegs

// ------------------
// ALU

// https://www.google.com/patents/US3991307

module ALU (
    // Outputs
    ACR, AVR,
    // Inputs
    PHI0,
    Z_ADD, SB_ADD, DB_ADD, NDB_ADD, ADL_ADD, SB_AC,
    ORS, ANDS, EORS, SUMS, SRS, 
    ADD_SB06, ADD_SB7, ADD_ADL, AC_SB, AC_DB,
    _ADDC, _DAA, _DSA,
    // Buses
    SB, DB, ADL
);

    input PHI0;
    input Z_ADD, SB_ADD, DB_ADD, NDB_ADD, ADL_ADD, SB_AC;
    input ORS, ANDS, EORS, SUMS, SRS;
    input ADD_SB06, ADD_SB7, ADD_ADL, AC_SB, AC_DB;
    input _ADDC, _DAA, _DSA;

    output ACR, AVR;        // Carry & Overflow Return

    inout [7:0] SB, DB, ADL;     // Buses

    wire   ACR, AVR;
    wire  [7:0] SB, DB, ADL;

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    integer n;      // Loop counter (bit number)

    reg carry_out;      // wire on real 6502 (carry chain)

    reg [7:0] AI, BI;       // MOSFET gate latches on real ALU (values can evaporate in time)
    reg [7:0] _ADD;         // Adder Hold. Value is saved in inverted form here (active-low)
    reg [7:0] AC;           // Accumulator (A)
    reg [7:0] nors, nands, enors, eors, sums;       // intermediate results
    reg BC0, BC3, BC4, BC6, DC3, DC7;      // Binary/decimal carries

    wire DAAL, DSAL, DAAH, DSAH;
    reg a, b, c;   // temp vars

    wire BinaryCarry, DecimalCarry;
    wire OverflowLatch_Out;
    assign BinaryCarry = ~carry_out;
    assign DecimalCarry = DC7;
    mylatch OverflowLatch (OverflowLatch_Out, ~(nors[7] & BC6) & (nands[7] | BC6), PHI2 );

    wire LatchDAA_Out, LatchDSA_Out, LatchDAAL_Out, LatchDSAL_Out;
    mylatch LatchDAA (LatchDAA_Out, ~_DAA, PHI2);
    mylatch LatchDSA (LatchDSA_Out, ~_DSA, PHI2);
    mylatch LatchDAAL (LatchDAAL_Out, ~(~BC3 & LatchDAA_Out), PHI2);
    mylatch LatchDSAL (LatchDSAL_Out, ~(~BC3 | ~LatchDSA_Out), PHI2);

    assign ACR = BinaryCarry | DecimalCarry;
    assign AVR = ~OverflowLatch_Out;
    assign DAAL = ~LatchDAAL_Out;
    assign DSAL = LatchDSAL_Out;
    assign DAAH = ~(~ACR | ~LatchDAA_Out);
    assign DSAH = ~(ACR | ~LatchDSA_Out);

    // Assign outputs
    assign SB[6:0] = ADD_SB06 ? ~_ADD[6:0] : 7'bzzzzzzz;
    assign SB[7] = ADD_SB7 ? ~_ADD[7] : 1'bz;
    assign ADL = ADD_ADL ? ~_ADD : 8'bzzzzzzzz;
    assign SB = AC_SB ? AC : 8'bzzzzzzzz;
    assign DB = AC_DB ? AC : 8'bzzzzzzzz;

    // Ricoh 2A03 Hack (disable BCD correction)
`ifdef BCD_HACK
    assign _DSA = 1'b1;
    assign _DAA = 1'b1;
`endif

always @(*) begin

    carry_out = _ADDC;

    // Only if any input control enabled
    if (SB_ADD | Z_ADD | DB_ADD | NDB_ADD | ADL_ADD) begin 
        AI = 8'b11111111;   // precharge to get rid of bus conflicts (see below)
        BI = 8'b11111111;
    end         // otherwise keep the charge.

    // Same method to get rid of possible bus conflicts in Adder Hold.
    if (ORS | ANDS | EORS | SRS | SUMS)
        _ADD = 8'b11111111;

    for (n=0; n<8; n=n+1) begin
    // Inputs
    // Potentially we can get rid of simultaneous control signals assertion by reserved opcodes.
    // Thats why we need to precharge AI/BI latches to mimic original 6502 behavior.
    // We perform 'AND' operation to follow generic bus-conflict work-around: "Ground wins"
        if (SB_ADD) AI[n] = AI[n] & SB[n];
        if (Z_ADD) AI[n] = 1'b0;
        if (DB_ADD) BI[n] = BI[n] & DB[n];
        if (NDB_ADD) BI[n] = BI[n] & ~DB[n];
        if (ADL_ADD) BI[n] = BI[n] & ADL[n];

    // Logic part
        nors[n] <= ~(AI[n] | BI[n]);
        nands[n] <= ~(AI[n] & BI[n]);

    // Arithmetic part + inverted carry chain + decimal carry lookahead (US Patent 3991307)
        if (n & 1) begin
            eors[n] = ~( ~nands[n] | nors[n] );
            sums[n] = ~(eors[n] & ~carry_out) & (eors[n] | ~carry_out);
            carry_out = ~(~nors[n] & carry_out) & nands[n];
        end
        else begin
            enors[n] = ~(~nors[n] & nands[n]);
            sums[n] = ~(enors[n] & ~carry_out) & (enors[n] | ~carry_out);
            carry_out = ~(nands[n] & carry_out) & ~nors[n];
        end

        if (n == 0) BC0 = carry_out;
        else if (n == 4) BC4 = carry_out;
        else if (n == 6) BC6 = carry_out;

        // decimal half-carry look-ahead
        if (n == 3) begin
            if ( ~_DAA) begin
                a <= ~( ~(~nands[1] & BC0) | nors[2]);
                b <= ~(eors[3] | ~nands[2]);
                c <= ~(eors[1] | ~nands[1]) & ~BC0 & ( ~nands[2] | nors[2]);
                DC3 = a | ~(b | c);
            end
            else DC3 = 1'b0;
            BC3 = carry_out & ~DC3;
        end

        // decimal carry look-ahead
        if (n == 7) begin
            if (~_DAA) begin
                a <= ~( ~(~nands[5] & BC4) | enors[6]);
                b <= ~(~nands[6] | eors[7]);
                c <= ~(~nands[5] | eors[5]) & ~(BC4 | ~enors[6]);
                DC7 = a | ~(b | c);
            end
            else DC7 = 1'b0;
        end 

    // Hold result in temporary latch (active-low)
    if (PHI2) begin
        if (ORS) _ADD[n] = _ADD[n] & nors[n];
        if (ANDS) _ADD[n] = _ADD[n] & nands[n];
        if (EORS) begin
            if (n & 1) _ADD[n] = _ADD[n] & ~eors[n];
            else _ADD[n] = _ADD[n] & enors[n];
        end     // EORS
        if (SRS && n != 0) _ADD[n-1] = _ADD[n-1] & nands[n];  // 7th bit is precharged to 1.
        if (SUMS) _ADD[n] = _ADD[n] & sums[n];
    end     // PHI2

    // Decimal adjustment
        if ( SB_AC ) begin
            if (n == 0) AC[0] <= SB[0];
            if (n == 1) AC[1] <= ~(SB[1] ^ ~(DSAL | DAAL));
            if (n == 2) AC[2] <= ~(SB[2] ^ ( ~(~_ADD[1] & DSAL) & ~(_ADD[1] & DAAL)) );
            if (n == 3) AC[3] <= ~(SB[3] ^ (~((_ADD[1]|_ADD[2]) & DSAL) & ~(~(_ADD[1] & _ADD[2]) & DAAL)) );

            if (n == 4) AC[4] <= SB[4];
            if (n == 5) AC[5] <= ~(SB[5] ^ ~(DSAH | DAAH));
            if (n == 6) AC[6] <= ~(SB[6] ^ ( ~(~_ADD[5] & DSAH) & ~(_ADD[5] & DAAH)) );
            if (n == 7) AC[7] <= ~(SB[7] ^ (~((_ADD[5]|_ADD[6]) & DSAH) & ~(~(_ADD[5] & _ADD[6]) & DAAH)) );
        end     // SB_AC

    end     // for

end

endmodule       // ALU

// ------------------
// Program Counter

// --------------------------------------------------------------------------------
// Core

// Pads:
// #NMI : Non-maskable interrupt (active-low, edge triggered)
// #IRQ : Maskable Interrupt (active-low, level triggered)
// #RES : Reset (active-low, level triggered)
// RDY : Halt CPU execution during RDY = 0 
// SO : Set Overflow flag
// R/W : Read/NotWrite
// SYNC : Active during opcode fetch cycle (useless at most 6502 applications)

module Core6502 (
    // Outputs
    PHI1, PHI2, RW, SYNC, ADDR,
    // Inputs
    PHI0, _NMI, _IRQ, _RES, RDY, SO,
    // Input/Output
    DATA
);

    input   PHI0, _NMI, _IRQ, _RES, RDY, SO;

    output  PHI1, PHI2, RW, SYNC;  
    output [15:0]  ADDR;

    inout [7:0]   DATA;

    // Assign wires.
    wire  PHI1;
    wire  PHI2;
    wire  RW;
    wire  SYNC;

    wire [7:0]   DATA;

    // Internal wires
    
    wire ACR, AVR;

    // Internal buses
    wire [7:0]  DB, SB, ADH, ADL;
    
    wire Z_ADD, SB_ADD, DB_ADD, NDB_ADD, ADL_ADD, SB_AC;
    wire ORS, ANDS, EORS, SUMS, SRS;
    wire ADD_SB06, ADD_SB7, ADD_ADL, AC_SB, AC_DB;
    wire _ADDC, _DAA, _DSA;

    // Clock Generator.
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;
    
    wire Z_ADL0, Z_ADL1, Z_ADL2, DORES, RESP, BRK6E, B_OUT;
    wire _I_OUT, BR2, T0, BRK5, _ready;

    // Break that shit.

    InterruptControl interrupts (
        Z_ADL0, Z_ADL1, Z_ADL2, DORES, RESP, BRK6E, B_OUT,
        PHI0, _NMI, _IRQ, _RES, _I_OUT, BR2, T0, BRK5, _ready
    );

/*
    Dispatcher dispatch (
    );

    Decoder decode (
    );

    RandomLogic random (
    );

    Flags flags (
    );
*/

    ALU alu ( ACR, AVR, PHI0, 
        Z_ADD, SB_ADD, DB_ADD, NDB_ADD, ADL_ADD, SB_AC,
        ORS, ANDS, EORS, SUMS, SRS, 
        ADD_SB06, ADD_SB7, ADD_ADL, AC_SB, AC_DB,
        _ADDC, _DAA, _DSA,
        SB, DB, ADL
    );

endmodule   // Core6502


// --------------------------------------------------------------------------------
// Test application / Icarus Verilog.

`ifdef ICARUS

module TestBench;

    reg PHI0, _NMI, _IRQ, _RES, RDY, SO;
    wire PHI1, PHI2, RW, SYNC;
    wire [15:0] ADDR;
    wire [7:0] DATA;

    Core6502 core (
        PHI1, PHI2, RW, SYNC, ADDR,
        PHI0, _NMI, _IRQ, _RES, RDY, SO,
        DATA );

    always #1 PHI0 <= ~PHI0;

initial begin
    //$dumpfile("core.vcd");
    //$dumpvars(-1, core);
    $monitor("PHI0 = %b", PHI0);
end

initial begin

    PHI0 = 1'b0;

    repeat(1) @(PHI0);      // single cycle.

    $finish;
end 

endmodule

`endif      // ICARUS