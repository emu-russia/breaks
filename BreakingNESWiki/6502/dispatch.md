# Логика управления (dispatch)

Логика управления (исполнения) -- это ключевой механизм 6502, который "дирижирует" выполнением инструкций.

<img src="/BreakingNESWiki/imgstore/dispatch.jpg" width="600px">

## Цикл записи и RDY

Во время цикла записи (WR=1) внутренняя линия /ready принудительно устанавливается в 0, тем самым процессор будет "готов", даже если внешний сигнал RDY = 0.

<img src="/BreakingNESWiki/imgstore/rdy_wr.jpg" width="200px"> <img src="/BreakingNESWiki/imgstore/rdy_wr_flow.jpg" width="200px">

## Verilog

```verilog
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
    assign WR = ~ ( _ready | REST | WRLatch_Out );
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
    assign REST = ~(_STORE & _SHIFT) & DORES;

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
    assign Brfw = ~(BRFW ^ ACR) & BRFWLatch_Out;

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
```
