// Synthesizable MOS 6502 on Verilog
// Project Breaks http://breaknes.com

//`define QUARTUS

// Enable APU 2A03 Decimal Correction hack (disable BCD correction)
// Appliable only for NES / Famicom.
//`define BCD_HACK

`define TEST_BENCH

// Level-sensitive D-latch (required for N-MOS)
// http://quartushelp.altera.com/14.0/mergedProjects/hdl/prim/prim_file_latch.htm
module latch( 
   // Outputs 
   dout, 
   // Inputs 
   din, en 
);
`ifndef QUARTUS
    input din; 
    output dout; 
    input  en; // latch enable 
    reg dout; 
    always @(din or en) 
         if (en == 1'b1) 
           dout <= din;   //Use non-blocking
`else
    LATCH MyLatch (.d(din), .ena(en), .q(dout));
`endif      // QUARTUS
endmodule // latch

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

//always      // By default all decoder outputs are zero.
//    for (i=0; i<130; i++)
//    begin
//        decoder_out[i] = 0'b0;
//    end
//end

always #10 begin

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
    latch IRQP_Latch (_IRQP, IRQP_FF, PHI1);
    latch RESP_Latch (RESP, ~RESP_FF, PHI1);

    // Interrupt cycle 6-7.
    wire BRK7;  // internal
    wire Latch1_Out, Latch2_Out;
    latch Latch1 (Latch1_Out, BRK5 & ~_ready, PHI2);
    latch Latch2 (Latch2_Out, ~(BRK5 & Latch2_Out) & ~Latch1_Out, PHI1);
    latch Latch3 (BRK6E, Latch2_Out, PHI2);
    assign BRK7 = ~(Latch2_Out | BRK5);

    // Reset FLIP/FLOP
    wire Latch4_Out, Latch5_Out; 
    latch Latch4 (Latch4_Out, RESP, PHI2);
    latch Latch5 (
        Latch5_Out,
        ~(BRK6E | ~(~Latch4_Out | ~Latch5_Out) ), PHI1);
    assign DORES = (~Latch4_Out | ~Latch5_Out);

    // NMI Edge Detection
    // CHECK : Does this shit actually work at all after synthesize?
    wire _DONMI;        // internal
    wire Latch6_Out, Latch7_Out, Latch8_Out, Latch9_Out;
    wire Latch10_Out, Latch11_Out, Latch12_Out, LastLatch_Out;
    wire temp;
    latch Latch6 (Latch6_Out, _NMIP, PHI1);
    latch Latch7 (Latch7_Out, BRK7, PHI2);
    latch Latch8 (Latch8_Out, _DONMI, PHI2);
    latch Latch9 (Latch9_Out, BRK6E & ~_ready, PHI1);
    latch Latch10 (Latch10_Out, _DONMI, PHI2);
    latch Latch11 (Latch11_Out, ~Latch10_Out, PHI1);
    assign temp = ~( Latch6_Out | (~( Latch11_Out | Latch12_Out)) );
    latch Latch12 (Latch12_Out, temp, PHI2);
    latch LastLatch ( LastLatch_Out, ~(~Latch7_Out | _NMIP | temp), PHI1);
    assign _DONMI = ~( LastLatch_Out | ~(Latch8_Out | Latch9_Out) );

    // Interrupt Check
    wire IntCheck;      // internal
    assign IntCheck = 
        ( (~( ( ~( ~(_I_OUT & ~BRK6E) | _IRQP) ) | ~_DONMI )) | ~(BR2 | T0));

    // B-Flag
    wire BLatch1_Out, BLatch2_Out;
    latch BLatch1 (BLatch1_Out, ~(BRK6E | BLatch2_Out), PHI1);
    latch BLatch2 (BLatch2_Out, IntCheck & ~BLatch1_Out, PHI2);
    assign B_OUT = ~( (~(BRK6E | BLatch2_Out)) | DORES);

    // Interrupt Vector address lines controls.
    wire ADL0_Latch_Out, ADL1_Latch_Out, ADL2_Latch_Out;
    latch ADL0_Latch ( ADL0_Latch_Out, BRK5, PHI2);
    latch ADL1_Latch ( ADL1_Latch_Out, (BRK7 | ~DORES), PHI2);
    latch ADL2_Latch ( ADL2_Latch_Out, ~(BRK7 | _DONMI | DORES), PHI2);
    assign Z_ADL0 = ~ADL0_Latch_Out;
    assign Z_ADL1 = ~ADL1_Latch_Out;
    assign Z_ADL2 = ADL2_Latch_Out;     // watch this carefully

always #10 @(PHI2) begin    // Lock pads on input FFs         
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
// Instruction Register

// ------------------
// Predecode

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

// ------------------
// XYS Registers

// ------------------
// ALU

// ------------------
// Program Counter

// --------------------------------------------------------------------------------
// Core

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

    // Internal buses
    wire [7:0]  DB, SB, ADH, ADL;

    // Clock Generator.
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    // Break that shit.

/*
    InterruptControl interrupts (
    );

    Dispatcher dispatch (
    );

    Decoder decode (
    );

    RandomLogic random (
    );

    Flags flags (
    );
*/

endmodule   // Core6502


// --------------------------------------------------------------------------------
// Test application / Icarus Verilog.

`ifdef TEST_BENCH

module TestBench();

    reg PHI0, _NMI, _IRQ, _RES, RDY, SO;
    wire PHI1, PHI2, RW, SYNC;
    wire [15:0] ADDR;
    wire [7:0] DATA;

    Core6502 core (
        PHI1, PHI2, RW, SYNC, ADDR,
        PHI0, _NMI, _IRQ, _RES, RDY, SO,
        DATA );

    always #10 PHI0 <= ~PHI0;

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

`endif      // TEST_BENCH