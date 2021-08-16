FIXME Красивая транзисторная схема

FIXME Подробное описание работы всех узлов

FIXME Логическая схема

{{:6502:intr.jpg?900}}

====== Verilog ======

```verilog
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
```
