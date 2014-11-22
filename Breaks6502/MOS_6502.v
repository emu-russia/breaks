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
  IR, _T
);

    input [7:0] IR;
    input [5:0] _T;
    output [129:0] decoder_out;
    wire [129:0] decoder_out;

    wire IR01;

    assign IR01 = IR[0] | IR[1];

    assign decoder_out[0] = ~(IR[5] | IR[6] | ~IR[2] | ~IR[7] | IR01);
    assign decoder_out[1] = ~(IR[2] | IR[3] | ~IR[4] | ~IR[0] | _T[3]);
    assign decoder_out[2] = ~(IR[2] | ~IR[3] | ~IR[4] | ~IR[0] | _T[2]);
    assign decoder_out[3] = ~(_T[0] | IR[5] | IR[2] | ~IR[3] | IR[4] | ~IR[7] | IR01);
    assign decoder_out[4] = ~(_T[0] | IR[5] | IR[6] | IR[2] | ~IR[3] | ~IR[4] | ~IR[7] | IR01);
    assign decoder_out[5] = ~(_T[0] | IR[5] | ~IR[6] | IR[4] | ~IR[7] | IR01);
    assign decoder_out[6] = ~(~IR[2] | ~IR[4] | _T[2]);
    assign decoder_out[7] = ~(IR[6] | ~IR[7] | ~IR[1]);
    assign decoder_out[8] = ~(IR[2] | IR[3] | IR[4] | ~IR[0] | _T[2]);
    assign decoder_out[9] = ~(_T[0] | IR[5] | IR[6] | IR[2] | ~IR[3] | IR[4] | ~IR[7] | ~IR[1]);
    assign decoder_out[10] = ~(_T[0] | IR[5] | ~IR[6] | IR[2] | ~IR[3] | IR[4] | ~IR[7] | ~IR[1]);
    assign decoder_out[11] = ~(_T[0] | ~IR[5] | ~IR[6] | IR[4] | ~IR[7] | IR01);
    assign decoder_out[12] = ~(IR[5] | IR[6] | ~IR[7] | ~IR[1]);
    assign decoder_out[13] = ~(_T[0] | IR[5] | IR[6] | IR[2] | ~IR[3] | ~IR[4] | ~IR[7] | ~IR[1]);
    assign decoder_out[14] = ~(_T[0] | ~IR[5] | IR[6] | ~IR[7] | ~IR[1]);
    assign decoder_out[15] = ~(_T[1] | IR[5] | ~IR[6] | IR[2] | ~IR[3] | IR[4] | ~IR[7] | ~IR[1]);
    assign decoder_out[16] = ~(_T[1] | ~IR[5] | ~IR[6] | IR[2] | ~IR[3] | IR[4] | ~IR[7] | IR01);
    assign decoder_out[17] = ~(_T[0] | ~IR[5] | IR[6] | IR[2] | ~IR[3] | ~IR[4] | ~IR[7] | ~IR[1]);
    assign decoder_out[18] = ~(_T[1] | IR[5] | IR[2] | ~IR[3] | IR[4] | ~IR[7] | IR01);
    assign decoder_out[19] = ~(_T[0] | ~IR[5] | IR[6] | ~IR[2] | ~IR[7] | IR01);
    assign decoder_out[20] = ~(_T[0] | ~IR[5] | IR[6] | IR[4] | ~IR[7] | IR01);
    assign decoder_out[21] = ~(_T[0] | ~IR[5] | IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01);
    assign decoder_out[22] = ~(IR[5] | IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[5]);
    assign decoder_out[23] = ~(_T[0] | IR[5] | IR[2] | ~IR[3] | IR[4] | IR[7] | IR01);
    assign decoder_out[24] = ~(~IR[5] | ~IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[4]);
    assign decoder_out[25] = ~(~IR[5] | IR[2] | ~IR[3] | IR[4] | IR[7] | IR01 | _T[3]);
    assign decoder_out[26] = ~(IR[5] | ~IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[5]);
    assign decoder_out[27] = ~(~IR[5] | ~IR[6] | IR[7] | ~IR[1]);
    assign decoder_out[28] = ~(_T[2]);
    assign decoder_out[29] = ~(_T[0] | IR[5] | ~IR[6] | IR[7] | ~IR[0]);
    assign decoder_out[30] = ~(~IR[6] | ~IR[2] | ~IR[3] | IR[4] | IR[7] | IR01);
    assign decoder_out[31] = ~(~IR[2] | ~IR[3] | IR[4] | _T[2]);
    assign decoder_out[32] = ~(_T[0] | IR[5] | IR[6] | IR[7] | ~IR[0]);
    assign decoder_out[33] = ~(IR[3] | _T[2]);
    assign decoder_out[34] = ~(_T[0]);
    assign decoder_out[35] = ~(IR[2] | IR[4] | IR[7] | IR01 | _T[2]);
    assign decoder_out[36] = ~(IR[4] | IR[7] | IR01 | _T[3]);
    assign decoder_out[37] = ~(IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[4]);
    assign decoder_out[38] = ~(IR[5] | ~IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[4]);
    assign decoder_out[39] = ~(IR[2] | IR[3] | IR[4] | ~IR[0] | _T[3]);
    assign decoder_out[40] = ~(IR[2] | IR[3] | ~IR[4] | ~IR[0] | _T[4]);
    assign decoder_out[41] = ~(IR[2] | IR[3] | ~IR[4] | ~IR[0] | _T[2]);
    assign decoder_out[42] = ~(~IR[3] | ~IR[4] | _T[3]);
    assign decoder_out[43] = ~(~IR[5] | IR[2] | ~IR[3] | IR[4] | IR[7] | IR01);
    assign decoder_out[44] = ~(~IR[5] | ~IR[6] | ~IR[7] | ~IR[1]);
    assign decoder_out[45] = ~(IR[2] | IR[3] | IR[4] | ~IR[0] | _T[4]);
    assign decoder_out[46] = ~(IR[2] | IR[3] | ~IR[4] | ~IR[0] | _T[3]);
    assign decoder_out[47] = ~(~IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01);
    assign decoder_out[48] = ~(~IR[5] | IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[2]);
    assign decoder_out[49] = ~(_T[0] | ~IR[6] | IR[4] | ~IR[7] | IR01);
    assign decoder_out[50] = ~(_T[0] | IR[5] | ~IR[6] | ~IR[7] | ~IR[0]);
    assign decoder_out[51] = ~(_T[0] | ~IR[5] | ~IR[6] | ~IR[7] | ~IR[0]);
    assign decoder_out[52] = ~(_T[0] | ~IR[5] | ~IR[6] | ~IR[0]);
    assign decoder_out[53] = ~(~IR[5] | IR[6] | IR[7] | ~IR[1]);
    assign decoder_out[54] = ~(~IR[6] | ~IR[2] | ~IR[3] | IR[4] | IR[7] | IR01 | _T[3]);
    assign decoder_out[55] = ~(IR[6] | IR[7] | ~IR[1]);
    assign decoder_out[56] = ~(~IR[5] | IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[5]);
    assign decoder_out[57] = ~(IR[2] | IR[4] | IR[7] | IR01 | _T[2]);
    assign decoder_out[58] = ~(_T[0] | IR[5] | IR[6] | IR[2] | ~IR[3] | ~IR[4] | ~IR[7] | IR01);
    assign decoder_out[59] = ~(_T[1] | IR[7] | ~IR[0]);
    assign decoder_out[60] = ~(_T[1] | ~IR[5] | ~IR[6] | ~IR[0]);
    assign decoder_out[61] = ~(_T[1] | IR[2] | ~IR[3] | IR[4] | IR[7] | ~IR[1]);
    assign decoder_out[62] = ~(_T[0] | IR[5] | IR[6] | IR[2] | ~IR[3] | IR[4] | ~IR[7] | ~IR[1]);
    assign decoder_out[63] = ~(_T[0] | ~IR[5] | ~IR[6] | IR[2] | ~IR[3] | IR[4] | IR[7] | IR01);
    assign decoder_out[64] = ~(_T[0] | ~IR[5] | IR[6] | ~IR[7] | ~IR[0]);
    assign decoder_out[65] = ~(_T[0] | ~IR[0]);
    assign decoder_out[66] = ~(_T[0] | ~IR[5] | IR[6] | IR[2] | ~IR[3] | IR[4] | ~IR[7] | IR01);
    assign decoder_out[67] = ~(_T[0] | IR[2] | ~IR[3] | IR[4] | IR[7] | ~IR[1]);
    assign decoder_out[68] = ~(_T[0] | ~IR[5] | IR[6] | IR[2] | ~IR[3] | IR[4] | ~IR[7] | ~IR[1]);
    assign decoder_out[69] = ~(_T[0] | ~IR[5] | IR[6] | ~IR[2] | IR[4] | IR[7] | IR01);
    assign decoder_out[70] = ~(_T[0] | ~IR[5] | IR[6] | IR[7] | ~IR[0]);
    assign decoder_out[71] = ~(~IR[3] | ~IR[4] | _T[4]);
    assign decoder_out[72] = ~(IR[2] | IR[3] | ~IR[4] | ~IR[0] | _T[5]);
    assign decoder_out[73] = ~(_T[0] | IR[2] | IR[3] | ~IR[4] | IR01);
    assign decoder_out[74] = ~(IR[5] | ~IR[6] | IR[2] | ~IR[3] | IR[4] | IR[7] | IR01 | _T[2]);
    assign decoder_out[75] = ~(_T[0] | ~IR[6] | IR[2] | ~IR[3] | IR[4] | IR[7] | ~IR[1]);
    assign decoder_out[76] = ~(~IR[6] | IR[7] | ~IR[1]);
    assign decoder_out[77] = ~(IR[5] | IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[2]);
    assign decoder_out[78] = ~(~IR[5] | IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[3]);
    assign decoder_out[79] = ~(IR[5] | IR[6] | ~IR[7] | ~IR[0]);
    assign decoder_out[80] = ~(IR[2] | IR[3] | ~IR[4] | IR01 | _T[2]);
    assign decoder_out[81] = ~(~IR[2] | IR[3] | _T[2]);
    assign decoder_out[82] = ~(IR[2] | IR[3] | ~IR[0] | _T[2]);
    assign decoder_out[83] = ~(~IR[3] | _T[2]);
    assign decoder_out[84] = ~(~IR[5] | ~IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[5]);
    assign decoder_out[85] = ~(_T[4]);
    assign decoder_out[86] = ~(_T[3]);
    assign decoder_out[87] = ~(_T[0] | IR[5] | IR[2] | IR[3] | IR[4] | IR[7] | IR01);
    assign decoder_out[88] = ~(_T[0] | ~IR[6] | ~IR[2] | ~IR[3] | IR[4] | IR[7] | IR01);
    assign decoder_out[89] = ~(IR[2] | IR[3] | IR[4] | ~IR[0] | _T[5]);
    assign decoder_out[90] = ~(~IR[3] | _T[3]);
    assign decoder_out[91] = ~(IR[2] | IR[3] | ~IR[4] | ~IR[0] | _T[4]);
    assign decoder_out[92] = ~(~IR[3] | ~IR[4] | _T[3]);
    assign decoder_out[93] = ~(IR[2] | IR[3] | ~IR[4] | IR01 | _T[3]);
    assign decoder_out[94] = ~(IR[5] | IR[2] | IR[3] | IR[4] | IR[7] | IR01);
    assign decoder_out[95] = ~(~IR[5] | IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01);
    assign decoder_out[96] = ~(~IR[6] | ~IR[2] | ~IR[3] | IR[4] | IR[7] | IR01);
    assign decoder_out[97] = ~(IR[5] | IR[6] | ~IR[7]);
    assign decoder_out[98] = ~(IR[5] | IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[4]);
    assign decoder_out[99] = ~(IR[5] | IR[6] | IR[2] | ~IR[3] | IR[4] | IR[7] | IR01 | _T[2]);
    assign decoder_out[100] = ~(IR[5] | IR[2] | ~IR[3] | IR[4] | IR[7] | IR01 | _T[2]);
    assign decoder_out[101] = ~(~IR[6] | ~IR[2] | ~IR[3] | IR[4] | IR[7] | IR01 | _T[4]);
    assign decoder_out[102] = ~(~IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[5]);
    assign decoder_out[103] = ~(~IR[5] | IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[5]);
    assign decoder_out[104] = ~(IR[5] | ~IR[6] | ~IR[2] | ~IR[3] | IR[4] | IR[7] | IR01 | _T[2]);
    assign decoder_out[105] = ~(~IR[5] | IR[2] | ~IR[3] | IR[4] | IR[7] | IR01 | _T[3]);
    assign decoder_out[106] = ~(~IR[6] | ~IR[1]);
    assign decoder_out[107] = ~(IR[6] | IR[7] | ~IR[1]);
    assign decoder_out[108] = ~(_T[0] | ~IR[6] | IR[2] | ~IR[3] | ~IR[4] | IR[7] | IR01);
    assign decoder_out[109] = ~(_T[1] | ~IR[5] | IR[6] | ~IR[2] | IR[4] | IR[7] | IR01);
    assign decoder_out[110] = ~(_T[0] | IR[6] | IR[2] | ~IR[3] | ~IR[4] | IR[7] | IR01);
    assign decoder_out[111] = ~(~IR[2] | IR[3] | ~IR[4] | _T[3]);
    assign decoder_out[112] = ~(_T[1] | ~IR[5] | ~IR[6] | ~IR[0]);
    assign decoder_out[113] = ~(_T[0] | ~IR[5] | IR[6] | ~IR[2] | IR[4] | IR[7] | IR01);
    assign decoder_out[114] = ~(_T[0] | ~IR[5] | IR[6] | IR[2] | ~IR[3] | IR[4] | IR[7] | IR01);
    assign decoder_out[115] = ~(IR[5] | ~IR[6] | IR[2] | IR[3] | IR[4] | IR[7] | IR01 | _T[4]);
    assign decoder_out[116] = ~(_T[1] | IR[5] | ~IR[6] | ~IR[7] | ~IR[0]);
    assign decoder_out[117] = ~(_T[1] | ~IR[6] | ~IR[2] | ~IR[3] | IR[4] | ~IR[7] | IR01);
    assign decoder_out[118] = ~(_T[1] | IR[6] | IR[2] | ~IR[3] | IR[4] | IR[7] | ~IR[1]);
    assign decoder_out[119] = ~(_T[1] | ~IR[6] | IR[3] | IR[4] | ~IR[7] | IR01);
    assign decoder_out[120] = ~(_T[0] | ~IR[6] | IR[2] | ~IR[3] | ~IR[4] | ~IR[7] | IR01);
    assign decoder_out[121] = ~(IR[6]);
    assign decoder_out[122] = ~(~IR[2] | ~IR[3] | IR[4] | _T[3]);
    assign decoder_out[123] = ~(~IR[2] | IR[3] | IR[4] | _T[2]);
    assign decoder_out[124] = ~(IR[2] | IR[3] | ~IR[0] | _T[5]);
    assign decoder_out[125] = ~(~IR[3] | ~IR[4] | _T[4]);
    assign decoder_out[126] = ~(IR[7]);
    assign decoder_out[127] = ~(~IR[5] | IR[6] | IR[2] | ~IR[3] | ~IR[4] | ~IR[7] | IR01);

    // Line 128 (IMPL)
    assign decoder_out[128] = ~(IR[0] | IR[2] | ~IR[3]);

    // Line 129 (Push/Pull)
    assign decoder_out[129] = ~(IR[2] | ~IR[3] | IR[4] | IR[7] | IR01);

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

module Flags (
    // Outputs
    _Z_OUT, _N_OUT, _C_OUT, _D_OUT, _I_OUT, _V_OUT,
    // Inputs
    PHI0, 
    P_DB, DB_P, DBZ_Z, DB_N, IR5_C, ACR_C, DB_C, IR5_D, IR5_I, AVR_V, DB_V, ZERO_V, ONE_V, 
    _IR5, ACR, AVR, B_OUT,
    // Buses
    DB
);

    input PHI0;
    input P_DB, DB_P, DBZ_Z, DB_N, IR5_C, ACR_C, DB_C, IR5_D, IR5_I, AVR_V, DB_V, ZERO_V, ONE_V;
    input _IR5, ACR, AVR, B_OUT;

    output _Z_OUT, _N_OUT, _C_OUT, _D_OUT, _I_OUT, _V_OUT;

    inout [7:0] DB;
    wire [7:0] DB;

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    wire DBZ;
    assign DBZ = ~ ( DB[0] | DB[1] | DB[2] | DB[3] | DB[4] | DB[5] | DB[6] | DB[7]);

    // Z FLAG
    wire _Z_OUT;
    wire Z_LatchOut;
    wire z;
    assign z = (DBZ_Z | DB_P) ? ( ~(~DBZ & DBZ_Z) & ~(~DB[1] & DB_P) ) : ~Z_LatchOut;
    mylatch Z_Latch1 ( _Z_OUT, z, PHI1 );
    mylatch Z_Latch2 ( Z_LatchOut, _Z_OUT, PHI2 );

    // N FLAG
    wire _N_OUT;
    wire N_LatchOut;
    wire n;
    assign n = DB_N ? (~(~DB[7] & DB_N)) : ~N_LatchOut;
    mylatch N_Latch1 ( _N_OUT, n, PHI1 );
    mylatch N_Latch2 ( N_LatchOut, _N_OUT, PHI2 );

    // C FLAG
    wire _C_OUT;
    wire C_LatchOut;
    wire c;
    assign c = ~(_IR5 & IR5_C) &
               ~(~ACR & ACR_C) & 
               ~(~DB[0] & DB_C) & 
               ~(C_LatchOut & ~(IR5_C | ACR_C | DB_C) );
    mylatch C_Latch1 ( _C_OUT, c, PHI1 );
    mylatch C_Latch2 ( C_LatchOut, _C_OUT, PHI2 );

    // D FLAG
    wire _D_OUT;
    wire D_LatchOut;
    wire d;
    assign d = ~(_IR5 & IR5_D) &
               ~(~DB[3] & DB_P) &
               ~(D_LatchOut & ~(IR5_D | DB_P));
    mylatch D_Latch1 ( _D_OUT, d, PHI1 );
    mylatch D_Latch2 ( D_LatchOut, _D_OUT, PHI2 ); 

    // I FLAG
    wire _I_OUT;
    wire I_LatchOut;
    wire i;
    assign i = ~(_IR5 & IR5_I) &
               ~(~DB[2] & DB_P) &
               ~(I_LatchOut & ~(IR5_I | DB_P));
    mylatch I_Latch1 ( _I_OUT, i, PHI1 );
    mylatch I_Latch2 ( I_LatchOut, _I_OUT, PHI2 );

    // V FLAG
    wire _V_OUT;
    wire V_LatchOut;
    wire v;
    assign v = ~(~AVR & AVR_V) &
               ~(~DB[6] & DB_V) &
               ~(V_LatchOut & ~(AVR_V | ONE_V | DB_V) ) &
               ~ZERO_V;
    mylatch V_Latch1 ( _V_OUT, v, PHI1 );
    mylatch V_Latch2 ( V_LatchOut, _V_OUT, PHI2 );

    // Output flags on DB
    assign DB[0] = P_DB ? ~_C_OUT : 1'bz;
    assign DB[1] = P_DB ? ~_Z_OUT : 1'bz;
    assign DB[2] = P_DB ? ~_I_OUT : 1'bz;
    assign DB[3] = P_DB ? ~_D_OUT : 1'bz;
    assign DB[4] = P_DB ? B_OUT : 1'bz;
    assign DB[6] = P_DB ? ~_V_OUT : 1'bz;
    assign DB[7] = P_DB ? ~_N_OUT : 1'bz;

endmodule   // Flags

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

module BranchLogic (
    // Outputs
    BRFW, _BRTAKEN,
    // Inputs
    PHI0, BR2, DB7, _IR5, _IR6, _IR7, _C_OUT, _V_OUT, _N_OUT, _Z_OUT
);

    input PHI0, BR2, DB7, _IR5, _IR6, _IR7, _C_OUT, _V_OUT, _N_OUT, _Z_OUT;

    output BRFW, _BRTAKEN;

    wire BRFW, _BRTAKEN;

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    // Branch Forward
    wire BR2Latch_Out, Latch1_Out, Latch2_Out;
    mylatch BR2Latch ( BR2Latch_Out, BR2, PHI2);
    mylatch Latch1 ( Latch1_Out, (~(~DB7 & BR2Latch_Out) & ~(~BR2Latch_Out & Latch2_Out)), PHI1);
    mylatch Latch2 ( Latch2_Out, ~Latch1_Out, PHI2);
    assign BRFW = Latch1_Out;

    // Branch Taken
    wire temp;
    assign temp = ~(
        ~(_C_OUT | ~_IR6 | _IR7) |
        ~(_V_OUT | _IR6 | ~_IR7) |
        ~(_N_OUT | ~_IR6 | ~_IR7) |
        ~(_Z_OUT | _IR6 | _IR7) );
    assign _BRTAKEN = ~(temp & _IR5) & (temp | _IR5);

endmodule   // BranchLogic

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
// Buses

module Buses (
    // Inputs
    PHI0,
    Z_ADL0, Z_ADL1, Z_ADL2, ADL_ABL, ADH_ABH, SB_DB, SB_ADH, Z_ADH0, Z_ADH17, DL_ADL, DL_ADH, DL_DB, RD,
    // Outputs
    ADDR,
    // Buses
    DATA, SB, DB, ADL, ADH
);

    input PHI0, Z_ADL0, Z_ADL1, Z_ADL2, ADL_ABL, ADH_ABH, SB_DB, SB_ADH, Z_ADH0, Z_ADH17, DL_ADL, DL_ADH, DL_DB, RD;

    output [15:0] ADDR;
    wire [15:0] ADDR;

    inout [7:0] DATA, SB, DB, ADL, ADH;
    wire [7:0] DATA, SB, DB, ADL, ADH;

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    // SB/DB
    assign SB = (SB_DB) ? DB : 8'bzzzzzzzz;
    assign DB = (SB_DB) ? SB : 8'bzzzzzzzz;

    // SB/ADH
    assign SB = (SB_ADH) ? ADH : 8'bzzzzzzzz;
    assign ADH = (SB_ADH) ? SB : 8'bzzzzzzzz;

    reg [7:0] ABH, ABL;

    // Precharge buses
    // Precharge is not only used in mean of optimized value exchange, but also in special cases
    // (for example during interrupt vector assignment)
    assign SB = (PHI2) ? 8'b11111111 : 8'bzzzzzzzz;
    assign DB = (PHI2) ? 8'b11111111 : 8'bzzzzzzzz;
    assign ADH = (PHI2) ? 8'b11111111 : 8'bzzzzzzzz;
    assign ADL = (PHI2) ? 8'b11111111 : 8'bzzzzzzzz;

    // Data latch Input.
    wire [7:0] DataLatchInput;
    mylatch DataLatch0 ( DataLatchInput[0], ~DB[0], PHI2 );
    mylatch DataLatch1 ( DataLatchInput[1], ~DB[1], PHI2 );
    mylatch DataLatch2 ( DataLatchInput[2], ~DB[2], PHI2 );
    mylatch DataLatch3 ( DataLatchInput[3], ~DB[3], PHI2 );
    mylatch DataLatch4 ( DataLatchInput[4], ~DB[4], PHI2 );
    mylatch DataLatch5 ( DataLatchInput[5], ~DB[5], PHI2 );
    mylatch DataLatch6 ( DataLatchInput[6], ~DB[6], PHI2 );
    mylatch DataLatch7 ( DataLatchInput[7], ~DB[7], PHI2 );
    assign ADL = (PHI1 & DL_ADL) ? ~DataLatchInput : 8'bzzzzzzzz;
    assign ADH = (PHI1 & DL_ADH) ? ~DataLatchInput : 8'bzzzzzzzz;
    assign DB = (PHI1 & DL_DB) ? ~DataLatchInput : 8'bzzzzzzzz;

    // Data Latch Output
    wire [7:0] DataLatchOutput;
    mylatch DataLatch8 ( DataLatchOutput[0], ~DB[0], PHI1 );
    mylatch DataLatch9 ( DataLatchOutput[1], ~DB[1], PHI1 );
    mylatch DataLatch10 ( DataLatchOutput[2], ~DB[2], PHI1 );
    mylatch DataLatch11 ( DataLatchOutput[3], ~DB[3], PHI1 );
    mylatch DataLatch12 ( DataLatchOutput[4], ~DB[4], PHI1 );
    mylatch DataLatch13 ( DataLatchOutput[5], ~DB[5], PHI1 );
    mylatch DataLatch14 ( DataLatchOutput[6], ~DB[6], PHI1 );
    mylatch DataLatch15 ( DataLatchOutput[7], ~DB[7], PHI1 );
    assign DATA = (~RD) ? ~DataLatchOutput : 8'bzzzzzzzz;

    // External address bus
    assign ADDR[7:0] = ABL[7:0];
    assign ADDR[15:8] = ABH[7:0];

always @(*) begin
    if (ADL_ABL & PHI1) begin
        ABL[0] <= ADL[0] & ~Z_ADL0;
        ABL[1] <= ADL[1] & ~Z_ADL1;
        ABL[2] <= ADL[2] & ~Z_ADL2;
        ABL[7:3] <= ADL[7:3];
    end     // ADL_ABL

    if (ADH_ABH & PHI1) begin
        ABH[0] <= ADH[0] & ~Z_ADH0;
        ABH[1] <= ADH[1] & ~Z_ADH17;
        ABH[2] <= ADH[2] & ~Z_ADH17;
        ABH[3] <= ADH[3] & ~Z_ADH17;
        ABH[4] <= ADH[4] & ~Z_ADH17;
        ABH[5] <= ADH[5] & ~Z_ADH17;
        ABH[6] <= ADH[6] & ~Z_ADH17;
        ABH[7] <= ADH[7] & ~Z_ADH17;
    end     // ADH_ABH
end

endmodule   // Buses

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
    if (SB_X) X <= SB;
    if (SB_Y) Y <= SB;
    if (SB_S) S <= SB;
    if (S_S) S <= S;     // refresh
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
    wire [15:0]  ADDR;

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
    
    wire DORES, RESP, BRK6E, B_OUT;
    wire _I_OUT, BR2, T0, BRK5, _ready;

    wire BRFW, _BRTAKEN;

    wire _C_OUT, _V_OUT, _N_OUT, _Z_OUT, _D_OUT;

    wire P_DB, DB_P, DBZ_Z, DB_N, IR5_C, ACR_C, DB_C, IR5_D, IR5_I, AVR_V, DB_V, ZERO_V, ONE_V;

    wire Y_SB, SB_Y, X_SB, SB_X, S_SB, S_ADL, S_S, SB_S;

    wire Z_ADL0, Z_ADL1, Z_ADL2, ADL_ABL, ADH_ABH, SB_DB, SB_ADH, Z_ADH0, Z_ADH17, DL_ADL, DL_ADH, DL_DB, RD;

    wire [7:0] IR;
    wire [7:0] PD;
    wire [5:0] _T;
    wire [129:0] decoder;

    wire FETCH, Z_IR, _IMPLIED, _TWOCYCLE;

    // Break that shit.

    InterruptControl interrupts (
        Z_ADL0, Z_ADL1, Z_ADL2, DORES, RESP, BRK6E, B_OUT,
        PHI0, _NMI, _IRQ, _RES, _I_OUT, BR2, T0, BRK5, _ready
    );

    Decoder decode ( decoder, IR, _T );

    Flags flags (
        _Z_OUT, _N_OUT, _C_OUT, _D_OUT, _I_OUT, _V_OUT,
        PHI0, 
        P_DB, DB_P, DBZ_Z, DB_N, IR5_C, ACR_C, DB_C, IR5_D, IR5_I, AVR_V, DB_V, ZERO_V, ONE_V, 
        ~IR[5], ACR, AVR, B_OUT,
        DB
    );   

    ALU alu ( ACR, AVR, PHI0, 
        Z_ADD, SB_ADD, DB_ADD, NDB_ADD, ADL_ADD, SB_AC,
        ORS, ANDS, EORS, SUMS, SRS, 
        ADD_SB06, ADD_SB7, ADD_ADL, AC_SB, AC_DB,
        _ADDC, _DAA, _DSA,
        SB, DB, ADL
    );

    BranchLogic branch (
        BRFW, _BRTAKEN,
        PHI0, BR2, DB[7], ~IR[5], ~IR[6], ~IR[7], _C_OUT, _V_OUT, _N_OUT, _Z_OUT
    );

    XYSRegs regs (
        Y_SB, SB_Y, X_SB, SB_X, S_SB, S_ADL, S_S, SB_S,
        SB, ADL
    );

    InstructionRegister ir (
        IR,
        PHI0, FETCH, ~PD
    );

    Predecode predecode (
        PD, _IMPLIED, _TWOCYCLE,
        PHI0, Z_IR,
        DATA
    );

    Buses buses (
        PHI0,
        Z_ADL0, Z_ADL1, Z_ADL2, ADL_ABL, ADH_ABH, SB_DB, SB_ADH, Z_ADH0, Z_ADH17, DL_ADL, DL_ADH, DL_DB, RD,
        ADDR,
        DATA, SB, DB, ADL, ADH );

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