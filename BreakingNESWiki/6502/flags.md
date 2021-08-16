# Флаги

<img src="/BreakingNESWiki/imgstore/flags_trans.jpg" width="1000px">

## Verilog

```verilog
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
```
