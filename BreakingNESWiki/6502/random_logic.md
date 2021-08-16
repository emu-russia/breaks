# Рандомная логика

"Рандомная логика" - это попытка перевести англ. название random logic.

Эта логика является мыслительным органом процессора и полностью определяет его поведение при обработке и выполнении инструкций.

С аппаратной точки зрения рандомная логика - это "хенд-мэйд" продукт инженеров [MOS](../MOS.md). Глядя на схему топологии кристалла, где содержится эта логика, становится дурно неподготовленному человеку :smiley:

<img src="/BreakingNESWiki/imgstore/random_logic_preview_topo.jpg" width="600px">

## Транзисторная схема

Восстановление только одной транзисторной схемы проходило в несколько этапов (удаление лишних линий, разделение схемы на составные части, оптимизация, определение контрольных линий).

В архивах я нашёл первые попытки получения транзисторной схемы:

<img src="/BreakingNESWiki/imgstore/random_logic_early.jpg" width="600px">

Как видно, на схеме присутствуют многочисленные межсоединения, да и назначение контрольных линий было не совсем понятно. Но со временем схема была разобрана на кусочки и достаточно хорошо изучена.

Полноразмерную транзисторную схему приводить тут нет необходимости, по причине того что проще будет осваивать её по составным частям. Составные части кстати тоже разношерстная команда: тут и разнообразные защелки и флаги и прочая вспомогательная логика.

Ниже вы можете ознакомиться со всеми функциональными блоками рандомной логики:
- [Управление регистрами](regs_control.md)
- [Управление АЛУ](alu_control.md)
- [Управление program counter-ом](pc_control.md)
- [Управление шинами](bus_control.md)
- [Логика исполнения (dispatch)](dispatch.md)
- [Логика установки флагов](flags_control.md)
- [Флаги](flags.md)
- [Логика условных переходов](branch_logic.md)

## Принцип работы

В целом работа логики довольно комплексная (вы думали я скажу - простая? :smiley:):
- Логика исполнения (dispatch) дирижирует работой всего процессора. Она определяет когда нужно закончить выполнение инструкции, а также управляет инкрементом PC и счетчиков тактов. Дополнительно она включает в себя схему готовности процессора (RDY), которая управляется контактом RDY.
- После того, как логика исполнения начала выполнение следующей инструкции - код этой инструкции, а также текущий такт подаются на декодер
- В зависимости от результатов декодирования схемы управления: регистрами, АЛУ, PC и шинами выдают наружу в нижнюю часть специальные [управляющие команды](context_control.md)
- Дополнительно на поведение процессора влияют его флаги, а также логика обработки прерываний. А на флаги также влияют исполняемые инструкции.

Всё это в тесной упряжке управляет нижней частью процессора, где находится его контекст (регистры), АЛУ и связь с внешним миром посредством шин.

## Verilog

```verilog
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
```
