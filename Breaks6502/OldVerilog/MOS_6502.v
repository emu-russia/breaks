// Synthesizable MOS 6502 on Verilog
// Project Breaks http://breaknes.com

// Note from Future:
// It is possible to work with this verilog, but you should take into account that there may be old uncorrected errors in the circuits.
// Therefore, if someone goes on, you will need to consider all current logic circuits from the 6502 wiki: 
// https://github.com/emu-russia/breaks/tree/master/BreakingNESWiki_DeepL/6502
// In general, the verilog motif can be taken as a basis. The only thing I don't really like is the way the ALU is made.

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
        ( (~( ( ~( ~_I_OUT | _IRQP) ) | ~_DONMI )) | ~(BR2 | T0));

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
    BRK5, BR2, _ADL_PCL, PC_DB, 
    ADH_ABH, ADL_ABL, Y_SB, X_SB, SB_Y, SB_X, S_SB, S_ADL, SB_S, S_S, 
    NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD, ANDS, EORS, ORS, _ADDC, SRS, SUMS, _DAA, ADD_SB7, ADD_SB06, ADD_ADL, _DSA,
    Z_ADH0, SB_DB, SB_AC, SB_ADH, Z_ADH17, AC_SB, AC_DB, 
    ADH_PCH, PCH_PCH, PCH_DB, PCL_DB, PCH_ADH, PCL_PCL, PCL_ADL, ADL_PCL, DL_ADL, DL_ADH, DL_DB,
    P_DB, ACR_C, AVR_V, DBZ_Z, DB_N, DB_P, DB_C, DB_V, IR5_C, IR5_I, IR5_D, ZERO_V, ONE_V,
    // Inputs
    PHI0, BRK6E, Z_ADL0, SO, RDY, BRFW, ACRL2, _C_OUT, _D_OUT, _ready, T0, T1, T5, T6,
    decoder
);
    output wire BRK5, BR2, _ADL_PCL, PC_DB;
    output wire ADH_ABH, ADL_ABL, Y_SB, X_SB, SB_Y, SB_X, S_SB, S_ADL, SB_S, S_S;
    output wire NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD, ANDS, EORS, ORS, _ADDC, SRS, SUMS, _DAA, ADD_SB7, ADD_SB06, ADD_ADL, _DSA;
    output wire Z_ADH0, SB_DB, SB_AC, SB_ADH, Z_ADH17, AC_SB, AC_DB;
    output wire ADH_PCH, PCH_PCH, PCH_DB, PCL_DB, PCH_ADH, PCL_PCL, PCL_ADL, ADL_PCL, DL_ADL, DL_ADH, DL_DB;
    output wire P_DB, ACR_C, AVR_V, DBZ_Z, DB_N, DB_P, DB_C, DB_V, IR5_C, IR5_I, IR5_D, ZERO_V, ONE_V;

    input PHI0, BRK6E, Z_ADL0, SO, RDY, BRFW, ACRL2, _C_OUT, _D_OUT, _ready, T0, T1, T5, T6;

    input [129:0] decoder;

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    // Temp Wires and Latches (helpers)
    wire NotReadyPhi1, ReadyDelay1_Out, ReadyDelay2_Out;
    wire BR0, BR3, PGX, JSR_5, RTS_5, RTI_5, PushPull, IND, IMPL, _MemOP, JB, STKOP, STOR, STXY, SBXY, STK2, TXS, JSR2, SBC0;
    wire ROR, _SRS, _ANDS, _EORS, _ORS, NOADL, BRX, RET, INC_SB, CSET, STA, JSXY, _ZTST, ABS_2, JMP_4;
    mylatch NotReadyPhi1_Latch ( NotReadyPhi1, _ready, PHI1 );
    assign PGX = ~(decoder[71] | decoder[72]) & ~BR0;
    mylatch ReadyDelay1 ( ReadyDelay1_Out, ~RDY, PHI2 );
    mylatch ReadyDelay2 ( ReadyDelay2_Out, ~ReadyDelay1_Out, PHI1 );
    assign BR0 = ~(~ReadyDelay2_Out | decoder[73]);
    assign BR2 = decoder[80];
    assign BR3 = decoder[93];
    assign JSR_5 = decoder[56];
    assign RTS_5 = decoder[84];
    assign RTI_5 = decoder[26];
    assign BRK5 = decoder[22];
    assign PushPull = decoder[129];
    assign STK2 = decoder[35];
    assign TXS = decoder[13];
    assign JSR2 = decoder[48];
    assign SBC0 = decoder[51];
    assign ROR = decoder[27];
    assign RET = decoder[47];
    assign STA = decoder[79];
    assign JMP_4 = decoder[102];
    assign IND = ( decoder[89] | ~(PushPull | decoder[90]) | decoder[91] | RTS_5 );
    assign IMPL = decoder[128] & ~PushPull;
    assign _MemOP = ~( decoder[111] | decoder[122] | decoder[123] | decoder[124] | decoder[125] );
    assign JB = ~( decoder[94] | decoder[95] | decoder[96] );
    assign STKOP = ~( NotReadyPhi1 | ~(decoder[21] | BRK5 | decoder[23] | decoder[24] | decoder[25] | RTI_5) );
    assign STOR = ~( ~decoder[97] | _MemOP );
    assign STXY = ~(STOR & decoder[0]) & ~(STOR & decoder[12]);
    assign SBXY = ~(_SB_X & _SB_Y);
    assign _SRS = ~(~(decoder[76] & T5) & ~decoder[75]);
    assign _ANDS = decoder[69] | decoder[70];
    assign _EORS = decoder[29];
    assign _ORS = _ready | decoder[32];
    assign NOADL = ~( decoder[85] | decoder[86] | RTS_5 | RTI_5 | decoder[87] | decoder[88] | decoder[89] );
    assign BRX = decoder[49] | decoder[50] | ~(~BR3 | BRFW);
    assign INC_SB = ~(~(decoder[39] | decoder[40] | decoder[41] | decoder[42] | decoder[43]) & ~(decoder[44] & T5));
    assign CSET = ~( ( ( ~(T0 | T5) | _C_OUT) | ~(decoder[52] | decoder[53])) & ~decoder[54]);
    assign JSXY = ~(~JSR2 & STXY);
    assign _ZTST = ~( ~_SB_AC | SBXY | T6 | _ANDS );
    assign ABS_2 = ~( decoder[83] | PushPull);

    // XYS Regs Control
    wire YSB_Out, XSB_Out, _SB_X, _SB_Y, SBY_Out, SBX_Out, SSB_Out, SADL_Out, _SB_S, SBS_Out, SS_Out;
    mylatch YSB ( YSB_Out, 
        (~(STOR & decoder[0])) & (~(decoder[1]|decoder[2]|decoder[3]|decoder[4]|decoder[5])) & (~(decoder[6] & decoder[7])),
        PHI2 );
    mylatch XSB ( XSB_Out,
        (~(decoder[6] & ~decoder[7])) & (~(decoder[8]|decoder[9]|decoder[10]|decoder[11]|TXS)) & (~(STOR & decoder[12])),
        PHI2 );
    assign Y_SB = ~YSB_Out & ~PHI2;
    assign X_SB = ~XSB_Out & ~PHI2;
    assign _SB_X = ~(decoder[14] | decoder[15] | decoder[16]);
    assign _SB_Y = ~(decoder[18] | decoder[19] | decoder[20]);
    mylatch SBY ( SBY_Out, _SB_Y, PHI2 );
    assign SB_Y = ~SBY_Out & ~PHI2;
    mylatch SBX ( SBX_Out, _SB_X, PHI2 );
    assign SB_X = ~SBX_Out & ~PHI2;
    mylatch SSB ( SSB_Out, ~decoder[17], PHI2 );
    assign S_SB = ~SSB_Out;
    mylatch SADL ( SADL_Out, ~(decoder[21] & ~NotReadyPhi1) & ~STK2, PHI2 );
    assign S_ADL = ~SADL_Out;
    assign _SB_S = ~( STKOP | ~(~JSR2 | NotReadyPhi1) | TXS );
    mylatch SBS ( SBS_Out, _SB_S, PHI2 );
    assign SB_S = ~SBS_Out & ~PHI2;
    mylatch SS ( SS_Out, ~_SB_S, PHI2 );
    assign S_S = ~SS_Out & ~PHI2;

    // ALU Control
    wire _NDB_ADD, _ADL_ADD, SB_ADD_Int, NDBADD_Out, DBADD_Out, ZADD_Out, SBADD_Out, ADLADD_Out;
    assign _NDB_ADD = ~( BRX | SBC0 | JSR_5) | _ready;
    assign _ADL_ADD = ~(decoder[33] & ~decoder[34]) & ~( STK2 | decoder[36] | decoder[37] | decoder[38] | decoder[39] | _ready );
    assign SB_ADD_Int = ~( decoder[30] | decoder[31] | RET | _ready | STKOP | INC_SB | decoder[45] | BRK6E | JSR2 );
    mylatch NDBADD (NDBADD_Out, _NDB_ADD, PHI2 );
    assign NDB_ADD = ~NDBADD_Out & ~PHI2;
    mylatch DBADD (DBADD_Out, ~(_NDB_ADD & _ADL_ADD), PHI2 );
    assign DB_ADD = ~DBADD_Out & ~PHI2;
    mylatch ZADD (ZADD_Out, SB_ADD_Int, PHI2 );
    assign Z_ADD = ~ZADD_Out & ~PHI2;
    mylatch SBADD (SBADD_Out, ~SB_ADD_Int, PHI2);
    assign SB_ADD = ~SBADD_Out & ~PHI2;
    mylatch ADLADD ( ADLADD_Out, _ADL_ADD, PHI2 );
    assign ADL_ADD = ~ADLADD_Out & ~PHI2;
    wire ANDS1_Out, ANDS2_Out, EORS1_Out, EORS2_Out, ORS1_Out, ORS2_Out, SRS1_Out, SRS2_Out, SUMS1_Out, SUMS2_Out;
    mylatch ANDS1 ( ANDS1_Out, _ANDS, PHI2 );
    mylatch ANDS2 ( ANDS2_Out, ~ANDS1_Out, PHI1 );
    assign ANDS = ~ANDS2_Out;
    mylatch EORS1 ( EORS1_Out, _EORS, PHI2 );
    mylatch EORS2 ( EORS2_Out, ~EORS1_Out, PHI1 );
    assign EORS = ~EORS2_Out;
    mylatch ORS1 ( ORS1_Out, _ORS, PHI2 );
    mylatch ORS2 ( ORS2_Out, ~ORS1_Out, PHI1 );
    assign ORS = ~ORS2_Out;
    mylatch SRS1 ( SRS1_Out, _SRS, PHI2 );
    mylatch SRS2 ( SRS2_Out, ~SRS1_Out, PHI1 );
    assign SRS = ~SRS2_Out;
    mylatch SUMS1 ( SUMS1_Out, ~( _ANDS | _EORS | _ORS | _SRS ), PHI2 );
    mylatch SUMS2 ( SUMS2_Out, ~SUMS1_Out, PHI1 );
    assign SUMS = ~SUMS2_Out;
    wire [6:0] ADDSB7_Out;
    wire _ADD_SB7, _ADD_SB06, ADD_SB7_Out, ADD_SB06_Out;
    mylatch ADDSB7_1 ( ADDSB7_Out[1], ~_C_OUT, PHI2 );
    mylatch ADDSB7_2 ( ADDSB7_Out[2], ~(NotReadyPhi1 | ~_SRS), PHI2 );
    mylatch ADDSB7_3 ( ADDSB7_Out[3], _SRS, PHI2 );
    mylatch ADDSB7_4 ( ADDSB7_Out[4], ~ADDSB7_Out[3], PHI1 );
    mylatch ADDSB7_5 ( ADDSB7_Out[5], ~(~ADDSB7_Out[1] & ADDSB7_Out[2]) & ~(~ADDSB7_Out[2] & ADDSB7_Out[6]), PHI1 );
    mylatch ADDSB7_6 ( ADDSB7_Out[6], ~ADDSB7_Out[5], PHI2 );
    assign _ADD_SB7 = ~( ~ADDSB7_Out[4] | ~ROR | ~ADDSB7_Out[5] );
    assign _ADD_SB06 = ~( T6 | STKOP | PGX | T1 | JSR_5 );
    mylatch ADD_SB7Latch ( ADD_SB7_Out, ~(_ADD_SB7 | _ADD_SB06), PHI2 );
    assign ADD_SB7 = ~ADD_SB7_Out;
    mylatch ADD_SB06Latch ( ADD_SB06_Out, _ADD_SB06, PHI2 );
    assign ADD_SB06 = ~ADD_SB06_Out;
    wire ADDADL_Out;
    mylatch ADDADL ( ADDADL_Out, PGX | NOADL, PHI2 );
    assign ADD_ADL = ~ADDADL_Out;
    wire DSA1_Out, DSA2_Out, DAA1_Out, DAA2_Out;
    mylatch DSA1 ( DSA1_Out, SBC0 | ~(decoder[52] & ~_D_OUT), PHI2 );
    mylatch DSA2 ( DSA2_Out, ~DSA1_Out, PHI1 );
    assign _DSA = ~DSA2_Out;
    mylatch DAA1 ( DAA1_Out, ~(SBC0 & ~_D_OUT), PHI2 );
    mylatch DAA2 ( DAA2_Out, ~DAA1_Out, PHI1 );
    assign _DAA = ~DAA2_Out;
    wire ACIN1_Out, ACIN2_Out, ACIN3_Out, ACIN4_Out, _ACIN_Int;
    mylatch ACIN1 ( ACIN1_Out, ~(~RET | _ADL_ADD), PHI2 );
    mylatch ACIN2 ( ACIN2_Out, INC_SB, PHI2 );
    mylatch ACIN3 ( ACIN3_Out, BRX, PHI2 );
    mylatch ACIN4 ( ACIN4_Out, CSET, PHI2 );
    assign _ACIN_Int = ~(ACIN1_Out | ACIN2_Out | ACIN3_Out | ACIN4_Out);
    mylatch ACIN ( _ADDC, _ACIN_Int, PHI1 );
    wire _SB_AC, _AC_SB, _AC_DB, SBAC_Out, ACSB_Out, ACDB_Out;
    assign _SB_AC = ~( decoder[58] | decoder[59] | decoder[60] | decoder[61] | decoder[62] | decoder[63] | decoder[64] );
    mylatch SBAC ( SBAC_Out, _SB_AC, PHI2 );
    assign SB_AC = ~SBAC_Out & ~PHI2;
    assign _AC_SB = (~(decoder[65] & ~decoder[64])) & ~( decoder[66] | decoder[67] | decoder[68] | _ANDS);
    mylatch ACSB ( ACSB_Out, _AC_SB, PHI2 );
    assign AC_SB = ~ACSB_Out & ~PHI2;
    assign _AC_DB = ~(STA & STOR) & ~decoder[74];
    mylatch ACDB ( ACDB_Out, _AC_DB, PHI2 );
    assign AC_DB = ~ACDB_Out & ~PHI2;

    // ADH/ADL Control
    wire _Z_ADH17, _ADL_ABL, ADHABH_Out, ADLABL_Out, ZADH0_Out, ZADH17_Out;
    mylatch ADHABH ( ADHABH_Out, 
        ( ~(~( ~(T2 | _PCH_PCH | JSR_5 | IND) | _ready) | ~(~(~NotReadyPhi1 & ACRL2) | _SB_ADH)) | BR3) & ~Z_ADL0,
        PHI2 );
    assign ADH_ABH = ~ADHABH_Out;
    assign _ADL_ABL = ~(~((decoder[71] | decoder[72]) | _ready) & ~(T5 | T6));
    mylatch ADLABL ( ADLABL_Out, _ADL_ABL, PHI2 );
    assign ADL_ABL = ~ADLABL_Out;
    mylatch ZADH0 ( ZADH0_Out, _DL_ADL, PHI2 );
    assign Z_ADH0 = ~ZADH0_Out;
    assign _Z_ADH17 = ~(decoder[57] | ~_DL_ADL);
    mylatch ZADH17 ( ZADH17_Out, _Z_ADH17, PHI2 );
    assign Z_ADH17 = ~ZADH17_Out;

    // SB/DB Control
    wire _SB_ADH, _SB_DB, SBADH_Out, SBDB_Out;
    assign _SB_ADH = ~(PGX | BR3);
    mylatch SBADH ( SBADH_Out, _SB_ADH, PHI2 );
    assign SB_ADH = ~SBADH_Out;
    assign _SB_DB = ~( ~(_ZTST | _ANDS) | decoder[67] | (decoder[55] & T5) | T1 | BR2 | JSXY);
    mylatch SBDB ( SBDB_Out, _SB_DB, PHI2 );
    assign SB_DB = ~SBDB_Out;

    // PCH/PCL Control
    wire _ADH_PCH, _PCH_DB, _PCL_DB, ADHPCH_Out, PCHPCH_Out, PCHDB_Out, PCLDB1_Out, PCLDB2_Out, PCLDB_Out;
    assign _ADH_PCH = ~( RTS_5 | ABS_2 | BR3 | T1 | BR2 | T0 );
    mylatch ADHPCH ( ADHPCH_Out, _ADH_PCH, PHI2 );
    assign ADH_PCH = ~ADHPCH_Out & ~PHI2;
    mylatch PCHPCH ( PCHPCH_Out, ~_ADH_PCH, PHI2 );
    assign PCH_PCH = ~PCHPCH_Out & ~PHI2;
    assign _PCH_DB = ~( decoder[77] | decoder[78] );
    mylatch PCHDB ( PCHDB_Out, _PCH_DB, PHI2 );
    assign PCH_DB = ~PCHDB_Out;
    mylatch PCLDB1 ( PCLDB1_Out, _PCH_DB, PHI2 );
    mylatch PCLDB2 ( PCLDB2_Out, ~( PCLDB1_Out | _ready), PHI1 );
    assign _PCL_DB = PCLDB2_Out;
    mylatch PCLDB ( PCLDB_Out, _PCL_DB, PHI2 );
    assign PCL_DB = ~PCLDB_Out;
    assign PC_DB = ~(_PCH_DB & _PCL_DB);
    wire _PCH_ADH, _PCL_ADL, PCHADH_Out, PCLPCL_Out, ADLPCL_Out, PCLADL_Out;
    assign _PCH_ADH = ~( ~(_PCL_ADL | BR0 | DL_PCH) | BR3);
    mylatch PCHADH ( PCHADH_Out, _PCH_ADH, PHI2 );
    assign PCH_ADH = ~PCHADH_Out;
    assign _PCL_ADL = ~( ABS_2 | T1 | BR2 | JSR_5 | ~( ~(JB | NotReadyPhi1) | ~T0));
    assign _ADL_PCL = ~(~_PCL_ADL | T0 | RTS_5) & ~(BR3 & ~NotReadyPhi1);
    mylatch PCLCPL ( PCLPCL_Out, ~_ADL_PCL, PHI2);
    assign PCL_PCL = ~PCLPCL_Out & ~PHI2;
    mylatch PCLADL ( PCLADL_Out, _PCL_ADL, PHI2 );
    assign PCL_ADL = ~PCLADL_Out;
    mylatch ADLPCL ( ADLPCL_Out, _ADL_PCL, PHI2 );
    assign ADL_PCL = ~ADLPCL_Out & ~PHI2;

    // DL Control
    wire _DL_ADL, DL_PCH, DLADL_Out, DLADH_Out, DLDB_Out;
    assign _DL_ADL = ~(decoder[81] | decoder[82]);
    mylatch DLADL ( DLADL_Out, _DL_ADL, PHI2 );
    assign DL_ADL = ~DLADL_Out;
    assign DL_PCH = ~( ~T0 | JB);
    mylatch DLADH ( DLADH_Out, ~(DL_PCH | IND), PHI2 );
    assign DL_ADH = ~DLADH_Out;
    assign temp = INC_SB | BRK6E | JSR2 | decoder[45] | decoder[46] | RET;
    mylatch DLDB ( DLDB_Out, ~( JMP_4 | T5 | temp | ~(~(ABS_2 | T0) | IMPL) | BR2 ), PHI2 );
    assign DL_DB = ~DLDB_Out;

    // Flags Control
    wire PDB_Out, ACRC_Out, DBZZ_Out, PIN_Out, BIT1_Out, DBC_Out, DBV_Out, IR5C_Out, IR5I_Out, IR5D_Out, ZEROV_Out;
    wire SODelay1_Out, SODelay2_Out, SODelay3_Out;
    mylatch PDB ( PDB_Out, ~(decoder[98] | decoder[99]), PHI2 );
    assign P_DB = ~PDB_Out;
    mylatch ACRC ( ACRC_Out, ~(decoder[112] | decoder[116] | decoder[117] | decoder[118] | decoder[119]) & ~(decoder[107] & T6), PHI2 );
    assign ACR_C = ~ACRC_Out;
    mylatch AVRV ( AVR_V, decoder[112], PHI2 );
    mylatch DBZZ ( DBZZ_Out, ~(ACR_C | decoder[109] | ~_ZTST), PHI2 );
    assign DBZ_Z = ~DBZZ_Out;
    mylatch PIN ( PIN_Out, ~(decoder[114] | decoder[115]), PHI2 );
    mylatch BIT1 ( BIT1_Out, decoder[109], PHI2 );
    assign DB_N = ~(PIN_Out & DBZZ_Out) & ~BIT1_Out;
    assign DB_P = PIN_Out & ~_ready;
    mylatch DBC ( DBC_Out, ~(_SRS | DB_P), PHI2 );
    assign DB_C = ~DBC_Out;
    mylatch DBV ( DBV_Out, ~decoder[113], PHI2 );
    assign DB_V = ~(DBV_Out & PIN_Out);
    mylatch IR5C ( IR5C_Out, ~decoder[110], PHI2 );
    assign IR5_C = ~IR5C_Out;
    mylatch IR5I ( IR5I_Out, ~decoder[108], PHI2 );
    assign IR5_I = ~IR5I_Out;
    mylatch IR5D ( IR5D_Out, ~decoder[120], PHI2 );
    assign IR5_D = ~IR5D_Out;
    mylatch ZEROV ( ZEROV_Out, ~decoder[127], PHI2 );
    assign ZERO_V = ~ZEROV_Out;
    mylatch SODelay1 ( SODelay1_Out, ~SO, PHI1 );
    mylatch SODelay2 ( SODelay2_Out, ~SODelay1_Out, PHI2 );
    mylatch SODelay3 ( SODelay3_Out, ~SODelay2_Out, PHI1 );
    mylatch ONEV ( ONE_V, ~(SODelay3_Out | ~SODelay1_Out), PHI2 );

endmodule   // RandomLogic

// ------------------
// Flags

module Flags (
    // Outputs
    _Z_OUT, _N_OUT, _C_OUT, _D_OUT, _I_OUT, _V_OUT,
    // Inputs
    PHI0, 
    P_DB, DB_P, DBZ_Z, DB_N, IR5_C, ACR_C, DB_C, IR5_D, IR5_I, AVR_V, DB_V, ZERO_V, ONE_V, 
    _IR5, ACR, AVR, B_OUT, BRK6E, 
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
    wire I_Latch1Out;
    wire I_Latch2Out;
    wire i;
    assign i = ~(_IR5 & IR5_I) &
               ~(~DB[2] & DB_P) &
               ~(I_Latch2Out & ~(IR5_I | DB_P));
    mylatch I_Latch1 ( I_Latch1Out, i, PHI1 );
    assign _I_OUT = ~(~I_Latch1Out & ~BRK6E);
    mylatch I_Latch2 ( I_Latch2Out, _I_OUT, PHI2 );

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
    PD <= DATA;
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
    _ready, _IPC, _T0X, _T1X, T0, T1, _T2, _T3, _T4, _T5, T5, T6, RD, Z_IR, FETCH, RW, SYNC, ACRL2, 
    // Inputs
    PHI0, RDY,
    DORES, RESP, B_OUT, BRK6E, BRFW, _BRTAKEN, ACR, _ADL_PCL, PC_DB, _IMPLIED, _TWOCYCLE, 
    decoder
);

    input PHI0, RDY;
    input DORES, RESP, B_OUT, BRK6E, BRFW, _BRTAKEN, ACR, _ADL_PCL, PC_DB, _IMPLIED, _TWOCYCLE;
    input [129:0] decoder;

    output _ready, _IPC, _T0X, _T1X, T0, T1, _T2, _T3, _T4, _T5, T5, T6, RD, Z_IR, FETCH, RW, SYNC, ACRL2;
    wire _ready, _IPC, _T0X, _T1X, T0, T1, _T2, _T3, _T4, _T5, T5, T6, RD, Z_IR, FETCH, RW, SYNC;

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    // Misc
    wire BR2, BR3, _MemOP, STOR, _SHIFT, _STORE;
    assign BR2 = decoder[80];
    assign BR3 = decoder[93];
    assign _MemOP = ~( decoder[111] | decoder[122] | decoder[123] | decoder[124] | decoder[125] );
    assign STOR = ~( ~decoder[97] | _MemOP );
    assign _SHIFT = ~( decoder[106] | decoder[107] );
    assign _STORE = ~decoder[97];

    // Ready Control
    wire Ready1_Out, Ready2_Out;
    mylatch Ready1 ( Ready1_Out, ~(RDY | Ready2_Out), PHI2 );
    mylatch Ready2 ( Ready2_Out, WR, PHI1 );
    assign _ready = Ready1_Out;

    // R/W Control
    wire WRLatch_Out, RWLatch_Out;
    wire WR;
    mylatch WRLatch ( WRLatch_Out, ~( decoder[98] | decoder[100] | T5 | STOR | T6 | PC_DB), PHI2 );
    assign WR = ~ ( _ready | DORES | WRLatch_Out );
    mylatch RWLatch ( RWLatch_Out, WR, PHI1 );
    assign RW = ~RWLatch_Out;
    assign RD = (PHI1 | ~RWLatch_Out);

    // Short Cycle Counter (T0-T1)
    wire TRESXLatch_Out, TWOCYCLELatch_Out, TRES1Latch_Out, T0Latch_Out, T1Latch_Out;
    mylatch TRESXLatch ( TRESXLatch_Out, TRESX, PHI1 );
    mylatch TWOCYCLELatch ( TWOCYCLELatch_Out, _TWOCYCLE, PHI1 );
    mylatch TRES1Latch ( TRES1Latch_Out, TRES1, PHI1 );
    assign _T0X = ~( (~(TRESXLatch_Out&TWOCYCLELatch_Out) & ~TRES1Latch_Out) | ~(T0Latch_Out | T1Latch_Out) );
    assign T0 = ~_T0X;
    mylatch T0Latch ( T0Latch_Out, _T0X, PHI2 );
    mylatch T1Latch ( T1Latch_Out, ~(T0Latch_Out | _ready), PHI1 );
    assign _T1X = ~T1Latch_Out;

    // Long Cycle Counter (T2-T5) (Shift Register)
    wire T1InputLatch_Out;
    mylatch T1InputLatch ( T1InputLatch_Out, T1, PHI2 );

    wire LatchIn_T2_Out, LatchOut_T2_Out;
    mylatch LatchIn_T2 ( LatchIn_T2_Out, _ready ? LatchOut_T2_Out : ~T1InputLatch_Out, PHI1 );
    mylatch LatchOut_T2 ( LatchOut_T2_Out, ~(LatchIn_T2_Out | TRES2), PHI2 );
    assign _T2 = (LatchIn_T2_Out | TRES2 );

    wire LatchIn_T3_Out, LatchOut_T3_Out;
    mylatch LatchIn_T3 ( LatchIn_T3_Out, _ready ? LatchOut_T3_Out : ~LatchOut_T2_Out, PHI1 );
    mylatch LatchOut_T3 ( LatchOut_T3_Out, ~(LatchIn_T3_Out | TRES2), PHI2 );
    assign _T3 = (LatchIn_T3_Out | TRES2 );

    wire LatchIn_T4_Out, LatchOut_T4_Out;
    mylatch LatchIn_T4 ( LatchIn_T4_Out, _ready ? LatchOut_T4_Out : ~LatchOut_T3_Out, PHI1 );
    mylatch LatchOut_T4 ( LatchOut_T4_Out, ~(LatchIn_T4_Out | TRES2), PHI2 );
    assign _T4 = (LatchIn_T4_Out | TRES2 );

    wire LatchIn_T5_Out, LatchOut_T5_Out;
    mylatch LatchIn_T5 ( LatchIn_T5_Out, _ready ? LatchOut_T5_Out : ~LatchOut_T4_Out, PHI1 );
    mylatch LatchOut_T5 ( LatchOut_T5_Out, ~(LatchIn_T5_Out | TRES2), PHI2 );
    assign _T5 = (LatchIn_T5_Out | TRES2 );

    // Extra Cycle Counter (T5-T6)
    wire T56Latch_Out, T5Latch1_Out, T2Latch2_Out, T6Latch1_Out, T6Latch2_Out;
    mylatch T56Latch ( T56Latch_Out, ~(_SHIFT | _MemOP | _ready), PHI2 );
    mylatch T5Latch1 ( T5Latch1_Out, ~(T5Latch2_Out & _ready) & ~T56Latch_Out, PHI1 );
    mylatch T5Latch2 ( T5Latch2_Out, ~T5Latch1_Out, PHI2 );
    mylatch T6Latch1 ( T6Latch1_Out, ~(~T5Latch1_Out & ~_ready), PHI2 );
    mylatch T6Latch2 ( T6Latch2_Out, ~T5Latch1_Out, PHI1 );
    assign T5 = ~T5Latch1_Out;
    assign T6 = T6Latch2_Out;

    // Instruction Termination (reset cycle counters)
    wire REST, ENDS, ENDX, TRES2;
    wire ENDS1_Out, ENDS2_Out;
    assign REST = ~(_STORE & _SHIFT);

    mylatch ENDS1 ( ENDS1_Out, _ready ? ~T1 : (~(_BRTAKEN & BR2) & ~T0), PHI2 );
    mylatch ENDS2 ( ENDS2_Out, RESP, PHI2 );
    assign ENDS = ~( ENDS1_Out | ENDS2_Out );

    wire temp;
    assign temp = ~( decoder[100] | decoder[101] | decoder[102] | decoder[103] | decoder[104] | decoder[105]);
    assign ENDX = ~( ~temp | T6 | BR3 | ~(_MemOP | decoder[96] | ~_SHIFT) );

    wire ReadyPhi1_Out, RESP1_Out, RESP2_Out, T1L_Out;
    mylatch ReadyPhi1 ( ReadyPhi1_Out, ~_ready, PHI1 );
    mylatch RESP1 ( RESP1_Out, ~(RESP | ReadyPhi1_Out | RESP2_Out), PHI2 );
    mylatch RESP2 ( RESP2_Out, ~(RESP1_Out | Brfw), PHI1 );
    mylatch T1L ( T1L_Out, ~TRES1, PHI1 );
    assign T1 = ~T1L_Out;
    assign TRES1 = (ENDS | ~(_ready | ~(RESP1_Out | Brfw) ) );
    assign SYNC = T1;

    wire TRESX1_Out, TRESX2_Out;
    mylatch TRESX1 ( TRESX1_Out, ~(decoder[91] | decoder[92]), PHI2);
    mylatch TRESX2 ( TRESX2_Out, ~( RESP | ENDS | ~(_ready | ENDX) ), PHI2 );
    assign TRESX = ~(BRK6E | ~(_ready | ACRL1 | REST | TRESX1_Out) | ~TRESX2_Out);

    wire TRES2Latch_Out;
    mylatch TRES2Latch ( TRES2Latch_Out, TRESX, PHI1 );
    assign TRES2 = ~TRES2Latch_Out;

    // ACR Latch
    wire ACRL1, ACRL2;
    wire ACRL1Latch_Out, ACRL2Latch_Out;
    assign ACRL2 = ~(~ACR & ~ReadyDelay) & (~ReadyDelay | ~ACRL1Latch_Out);
    mylatch ACRL1Latch ( ACRL1Latch_Out, ~ACRL2Latch_Out, PHI2 );
    mylatch ACRL2Latch ( ACRL2Latch_Out, ACRL2, PHI1 );
    assign ACRL1 = ~ACRL1Latch_Out;

    // Program Counter Increment Control
    wire ReadyDelay, Brfw;

    wire DelayLatch1_Out, DelayLatch2_Out;
    mylatch DelayLatch1 ( DelayLatch1_Out, _ready, PHI1 );
    mylatch DelayLatch2 ( DelayLatch2_Out, ~DelayLatch1_Out, PHI2 );
    assign ReadyDelay = ~DelayLatch2_Out;

    wire BRFWLatch_Out;
    mylatch BRFWLatch ( BRFWLatch_Out, ~(~BR3 | ReadyDelay), PHI2 );
    assign Brfw = ~((BRFW ^ ~ACR) | ~BRFWLatch_Out);

    wire RouteCLatch_Out, a_out, b_out, c_out;
    mylatch RouteCLatch ( RouteCLatch_Out, ~(BR2 & _BRTAKEN) & (_ADL_PCL | BR2 | BR3), PHI2 );
    mylatch c_latch ( c_out, ~(RouteCLatch_Out | _ready | ~_IMPLIED), PHI1 );
    mylatch a_latch ( a_out, B_OUT, PHI1 );
    mylatch b_latch ( b_out, Brfw, PHI1 );
    assign _IPC = ~(a_out & (b_out | c_out));

    // Fetch Control
    wire FetchLatch_Out;
    mylatch FetchLatch ( FetchLatch_Out, T1, PHI2 );
    assign FETCH = ~( _ready | ~FetchLatch_Out );
    assign Z_IR = ~( B_OUT & FETCH );

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

// Program Counter using inverted carry chain.

module ProgramCounter (
    // Inputs
    PHI0,
    _IPC, PCL_PCL, PCL_ADL, ADL_PCL, PCL_DB, PCH_PCH, PCH_ADH, ADH_PCH, PCH_DB,
    // Buses
    DB, ADL, ADH
);

    input PHI0, _IPC, PCL_PCL, PCL_ADL, ADL_PCL, PCL_DB, PCH_PCH, PCH_ADH, ADH_PCH, PCH_DB;

    inout [7:0] DB, ADL, ADH;
    wire [7:0] DB, ADL, ADH;

    reg [7:0] PCL = 8'b00000000, PCLS, PCH = 8'b00000000, PCHS;

    // Clocks
    wire PHI1, PHI2;
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    assign DB[0] = PCL_DB ? PCL[0] : 1'bz;
    assign DB[1] = PCL_DB ? ~PCL[1] : 1'bz;
    assign DB[2] = PCL_DB ? PCL[2] : 1'bz;
    assign DB[3] = PCL_DB ? ~PCL[3] : 1'bz;
    assign DB[4] = PCL_DB ? PCL[4] : 1'bz;
    assign DB[5] = PCL_DB ? ~PCL[5] : 1'bz;
    assign DB[6] = PCL_DB ? PCL[6] : 1'bz;
    assign DB[7] = PCL_DB ? ~PCL[7] : 1'bz;

    assign ADL[0] = PCL_ADL ? PCL[0] : 1'bz;
    assign ADL[1] = PCL_ADL ? ~PCL[1] : 1'bz;
    assign ADL[2] = PCL_ADL ? PCL[2] : 1'bz;
    assign ADL[3] = PCL_ADL ? ~PCL[3] : 1'bz;
    assign ADL[4] = PCL_ADL ? PCL[4] : 1'bz;
    assign ADL[5] = PCL_ADL ? ~PCL[5] : 1'bz;
    assign ADL[6] = PCL_ADL ? PCL[6] : 1'bz;
    assign ADL[7] = PCL_ADL ? ~PCL[7] : 1'bz;

    assign DB[0] = PCH_DB ? ~PCH[0] : 1'bz;
    assign DB[1] = PCH_DB ? PCH[1] : 1'bz;
    assign DB[2] = PCH_DB ? ~PCH[2] : 1'bz;
    assign DB[3] = PCH_DB ? PCH[3] : 1'bz;
    assign DB[4] = PCH_DB ? ~PCH[4] : 1'bz;
    assign DB[5] = PCH_DB ? PCH[5] : 1'bz;
    assign DB[6] = PCH_DB ? ~PCH[6] : 1'bz;
    assign DB[7] = PCH_DB ? PCH[7] : 1'bz;

    assign ADH[0] = PCH_ADH ? ~PCH[0] : 1'bz;
    assign ADH[1] = PCH_ADH ? PCH[1] : 1'bz;
    assign ADH[2] = PCH_ADH ? ~PCH[2] : 1'bz;
    assign ADH[3] = PCH_ADH ? PCH[3] : 1'bz;
    assign ADH[4] = PCH_ADH ? ~PCH[4] : 1'bz;
    assign ADH[5] = PCH_ADH ? PCH[5] : 1'bz;
    assign ADH[6] = PCH_ADH ? ~PCH[6] : 1'bz;
    assign ADH[7] = PCH_ADH ? PCH[7] : 1'bz;

    reg carry_out, old_carry;
    integer n;

    wire PCLC, PCHC;

    assign PCLC = ~( _IPC | ~PCLS[0] | ~PCLS[1] | ~PCLS[2] | ~PCLS[3] | ~PCLS[4] | ~PCLS[5] | ~PCLS[6] | ~PCLS[7] );
    assign PCHC = ~( ~PCLC | ~PCHS[0] | ~PCHS[1] | ~PCHS[2] | ~PCHS[3]);

always @(posedge PHI2) begin

    carry_out = _IPC;

    for (n=0; n<8; n=n+1) begin         // PCL 0...7
        if ( n & 1) begin
            old_carry = carry_out;
            carry_out = ~(carry_out & PCLS[n]);
            PCL[n] = ~(old_carry | PCLS[n]) | ~carry_out;
        end
        else begin
            old_carry = carry_out;
            carry_out = ~(carry_out | ~PCLS[n]);
            PCL[n] = ~(old_carry & ~PCLS[n]) & ~carry_out;
        end
    end

    carry_out = PCLC;

    for (n=0; n<4; n=n+1) begin         // PCH 0...3
        if ( n & 1) begin
            old_carry = carry_out;
            carry_out = ~(carry_out | ~PCHS[n]);
            PCH[n] = ~(old_carry & ~PCHS[n]) & ~carry_out;            
        end
        else begin
            old_carry = carry_out;
            carry_out = ~(carry_out & PCHS[n]);
            PCH[n] = ~(old_carry | PCHS[n]) | ~carry_out;
        end
    end

    carry_out = PCHC;

    for (n=4; n<8; n=n+1) begin         // PCH 4...7
        if ( n & 1) begin
            old_carry = carry_out;
            carry_out = ~(carry_out | ~PCHS[n]);
            PCH[n] = ~(old_carry & ~PCHS[n]) & ~carry_out;            
        end
        else begin
            old_carry = carry_out;
            carry_out = ~(carry_out & PCHS[n]);
            PCH[n] = ~(old_carry | PCHS[n]) | ~carry_out;
        end
    end

end

always @(*) begin
    for (n=0; n<8; n=n+1) begin
        if (n & 1) begin 
            if (PCL_PCL) PCLS[n] = ~PCL[n];
            if (ADL_PCL) PCLS[n] = ADL[n];
        end
        else begin
            if (PCL_PCL) PCLS[n] = PCL[n];
            if (ADL_PCL) PCLS[n] = ADL[n];
        end
    end

    for (n=0; n<8; n=n+1) begin
        if (n & 1) begin 
            if (PCH_PCH) PCHS[n] = PCH[n];
            if (ADH_PCH) PCHS[n] = ADH[n];
        end
        else begin
            if (PCH_PCH) PCHS[n] = ~PCH[n];
            if (ADH_PCH) PCHS[n] = ADH[n];
        end
    end
end 

endmodule   // ProgramCounter

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
    
    // Clock Generator.
    assign PHI1 = ~PHI0;
    assign PHI2 = PHI0;

    // Internal wires
    
    wire DORES, RESP, BRK6E, B_OUT;
    
    wire _ready, T0, T1, T5, T6, BR2, BRK5, _ADL_PCL, PC_DB, ACRL2;

    wire BRFW, _BRTAKEN;

    wire _C_OUT, _V_OUT, _N_OUT, _Z_OUT, _D_OUT, _I_OUT;

    wire ACR, AVR;
    wire Z_ADD, SB_ADD, DB_ADD, NDB_ADD, ADL_ADD, SB_AC;
    wire ORS, ANDS, EORS, SUMS, SRS;
    wire ADD_SB06, ADD_SB7, ADD_ADL, AC_SB, AC_DB;
    wire _ADDC, _DAA, _DSA;

    wire P_DB, DB_P, DBZ_Z, DB_N, IR5_C, ACR_C, DB_C, IR5_D, IR5_I, AVR_V, DB_V, ZERO_V, ONE_V;

    wire Y_SB, SB_Y, X_SB, SB_X, S_SB, S_ADL, S_S, SB_S;

    wire Z_ADL0, Z_ADL1, Z_ADL2, ADL_ABL, ADH_ABH, SB_DB, SB_ADH, Z_ADH0, Z_ADH17, DL_ADL, DL_ADH, DL_DB, RD;

    wire _IPC, PCL_PCL, PCL_ADL, ADL_PCL, PCL_DB, PCH_PCH, PCH_ADH, ADH_PCH, PCH_DB;

    wire [7:0] IR;
    wire [7:0] PD;
    wire [5:0] _T;
    wire [129:0] decoder;

    wire FETCH, Z_IR, _IMPLIED, _TWOCYCLE;

    // Internal buses
    wire [7:0]  DB, SB, ADH, ADL;

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
        ~IR[5], ACR, AVR, B_OUT, BRK6E, 
        DB
    );

    Dispatcher dispatch (
        _ready, _IPC, _T[0], _T[1], T0, T1, _T[2], _T[3], _T[4], _T[5], T5, T6, RD, Z_IR, FETCH, RW, SYNC, ACRL2, 
        PHI0, RDY,
        DORES, RESP, B_OUT, BRK6E, BRFW, _BRTAKEN, ACR, _ADL_PCL, PC_DB, _IMPLIED, _TWOCYCLE, 
        decoder );

    RandomLogic random (
        BRK5, BR2, _ADL_PCL, PC_DB, 
        ADH_ABH, ADL_ABL, Y_SB, X_SB, SB_Y, SB_X, S_SB, S_ADL, SB_S, S_S, 
        NDB_ADD, DB_ADD, Z_ADD, SB_ADD, ADL_ADD, ANDS, EORS, ORS, _ADDC, SRS, SUMS, _DAA, ADD_SB7, ADD_SB06, ADD_ADL, _DSA,
        Z_ADH0, SB_DB, SB_AC, SB_ADH, Z_ADH17, AC_SB, AC_DB, 
        ADH_PCH, PCH_PCH, PCH_DB, PCL_DB, PCH_ADH, PCL_PCL, PCL_ADL, ADL_PCL, DL_ADL, DL_ADH, DL_DB,
        P_DB, ACR_C, AVR_V, DBZ_Z, DB_N, DB_P, DB_C, DB_V, IR5_C, IR5_I, IR5_D, ZERO_V, ONE_V,
        PHI0, BRK6E, Z_ADL0, SO, RDY, BRFW, ACRL2, _C_OUT, _D_OUT, _ready, T0, T1, T5, T6,
        decoder );

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

    ProgramCounter pc (
        PHI0,
        _IPC, PCL_PCL, PCL_ADL, ADL_PCL, PCL_DB, PCH_PCH, PCH_ADH, ADH_PCH, PCH_DB,
        DB, ADL, ADH );

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