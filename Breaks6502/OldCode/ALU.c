
int ENOR (int a, int b)
{
    return NAND(NOT(a),b) & (NOT(a)|b) & 1;
}

void DAADSA (int clk, int SBC0)
{
    int ADCSBC0 = 1;
    int Dec = 0;
    int PHI1 = NOT(clk), PHI2 = clk;
    static int DAA_Latch[2] = {0,0}, DSA_Latch[2] = {0,0};
    int DAA, DSA;

    if (PHI2) {
        DAA_Latch[0] = NAND(ADCSBC0,Dec) | SBC0;
        DSA_Latch[0] = NAND(Dec,SBC0);
    }
    if (PHI1) {
        DAA_Latch[1] = NOT(DAA_Latch[0]);
        DSA_Latch[1] = NOT(DSA_Latch[0]);
    }
    DAA = NOT(DAA_Latch[1]);
    DSA = NOT(DSA_Latch[1]);

    printf ( "CLK:%i, SBC:%i, DAA:%i, DSA:%i\n", clk, SBC0, DAA, DSA );
}

void ALU2 (int clk, int ain, int bin, int carry, int adc)
{
    int ALU_0_ADD = 0,
        ALU_SB_ADD = 0,
        ALU_DB_ADD = 0,
        ALU_NDB_ADD = 0,
        ALU_ADL_ADD = 0,
        ALU_SB_AC = 0,
        ALU_ORS = 0,
        ALU_ANDS = 0,
        ALU_EORS = 0,
        ALU_SUMS = 0,
        ALU_SRS = 0,
        ALU_ADD_SB06 = 0,
        ALU_ADD_SB7 = 0,
        ALU_ADD_ADL = 0,
        ALU_AC_SB = 0,
        ALU_AC_DB = 0,
        ALU_SB_DB = 0,

        ALU_IADDC = 0,   // carry in, inverted logic
        ALU_nDAA = 0,
        ALU_nDSA = 0,

        ALU_ACR, ALU_AVR;

    char SB[8], DB[8], ADL[8];
    static char AI[8], BI[8], ADD[8], AC[8];
    static int OverflowLatch=0, BinaryCarry=0, DecimalCarry=0;
    static int LatchDAAL=0, LatchDSAL=0, LatchDAA=0, LatchDSA=0;
    int PHI1 = NOT(clk), PHI2 = clk, a,b,c, DAAL, DSAL, DAAH, DSAH;

    char nand[8], nor[8], enor[8], eor[8], sums[8], n, carry_out;
    char BC0, BC3, BC4, BC6, DC3, DC7;

    // TEST CASE
    if ( adc ) {
        unpackreg (SB, ain, 8);
        unpackreg (DB, bin, 8);
        ALU_SB_ADD = ALU_DB_ADD = 1;    // put input operands
        ALU_ADD_SB06 = ALU_ADD_SB7 = 1;
        ALU_SB_AC = 1;
        ALU_nDAA = 0;
        ALU_nDSA = 1;
    }
    else {
        unpackreg (SB, ain, 8);
        unpackreg (DB, bin, 8);
        ALU_SB_ADD = ALU_NDB_ADD = 1;    // put input operands
        ALU_ADD_SB06 = ALU_ADD_SB7 = 1;
        ALU_SB_AC = 1;
        ALU_nDAA = 1;
        ALU_nDSA = 0;
    }
    ALU_IADDC = NOT(carry);
    ALU_SUMS = 1;       // sum

    if (PHI2) ALU_0_ADD = ALU_SB_ADD = ALU_DB_ADD = ALU_NDB_ADD = ALU_ADL_ADD = 0;

    carry_out = ALU_IADDC;
    for (n=0; n<8; n++)
    {
    // inputs
        if (ALU_0_ADD) AI[n] = 0;
        else if (ALU_SB_ADD) AI[n] = SB[n];
        if (ALU_DB_ADD) BI[n] = DB[n];
        else if (ALU_NDB_ADD) BI[n] = NOT(DB[n]);
        else if (ALU_ADL_ADD) BI[n] = ADL[n];    

    // logic
        nor[n] = NOR(AI[n],BI[n]);
        nand[n] = NAND(AI[n],BI[n]);

    // arithmetic + carry chain + decimal carry lookahead
        if (n&1) {
            eor[n] = NOR (NOT(nand[n]), nor[n]);
            sums[n] = NAND(eor[n],NOT(carry_out)) & NOT(NOR(eor[n],NOT(carry_out)));
            carry_out = NAND(NOT(nor[n]),carry_out) & nand[n];
        }
        else {
            enor[n] = NAND (NOT(nor[n]), nand[n]);
            sums[n] = NAND(NOT(carry_out),enor[n]) & NOT (NOR(enor[n],NOT(carry_out)));
            carry_out = NAND(carry_out,nand[n]) & NOT(nor[n]);
        }
        if (n==0) BC0 = carry_out;
        else if (n==4) BC4 = carry_out;
        else if (n==6) BC6 = carry_out;
        if (n == 3) {   // decimal half-carry look-ahead
            if ( NOT(ALU_nDAA) ) {
                a = NOR( NAND(NOT(nand[1]), BC0), nor[2] );
                b = NOR(eor[3], NOT(nand[2]));
                c = NOR(eor[1], NOT(nand[1])) & NOT(BC0) & (NOT(nand[2]) | nor[2]);
                DC3 = a | NOR (b, c);
            } else DC3 = 0;
            BC3 = carry_out & NOT(DC3);
        }
        if (n == 7) {   // decimal carry look-ahead
            if ( NOT(ALU_nDAA) ) {
                a = NOR( NAND(NOT(nand[5]), BC4), enor[6]);
                b = NOR(NOT(nand[6]), eor[7]);
                c = NOR(NOT(nand[5]), eor[5]) & NOR(BC4, NOT(enor[6]));
                DC7 = a | NOR (b, c);
            } else DC7 = 0;
        }

    // adder hold
        if ( PHI2 ) {
            if (ALU_ORS) ADD[n] = nor[n];
            else if (ALU_ANDS) ADD[n] = nand[n];
            else if (ALU_EORS) {
                if (n&1) ADD[n] = NOT(eor[n]);
                else ADD[n] = enor[n];
            }
            else if (ALU_SRS && n) ADD[n-1] = nand[n];
            else if (ALU_SUMS) ADD[n] = sums[n];
        }
    }

    // carry out + overflow
    if (PHI2) {
        ALU_SB_AC = ALU_AC_SB = ALU_AC_DB = 0;  // sync output result
        BinaryCarry = NOT(carry_out);
        DecimalCarry = DC7;
        OverflowLatch = NAND(nor[7],BC6) & NOT(NOR(nand[7]),BC6);

        LatchDAA = NOT(ALU_nDAA);
        LatchDSA = NOT(ALU_nDSA);
        LatchDAAL = NAND(NOT(BC3), LatchDAA);
        LatchDSAL = NOR(NOT(BC3), NOT(LatchDSA));
    }
    ALU_ACR = BinaryCarry | DecimalCarry;
    ALU_AVR = NOT(OverflowLatch);
    DAAL = NOT(LatchDAAL);
    DSAL = LatchDSAL;
    DAAH = NOR(NOT(ALU_ACR), NOT(LatchDAA));
    DSAH = NOR(ALU_ACR, NOT(LatchDSA));

    // decimal adjustment + output result to accumulator
    for (n=0; n<8; n++) {
    // adder hold output
        if (ALU_ADD_SB06 && n!=7) SB[n] = NOT(ADD[n]);
        if (ALU_ADD_SB7 && n==7) SB[n] = NOT(ADD[n]);
        if (ALU_ADD_ADL) ADL[n] = NOT(ADD[n]);

    if ( ALU_SB_AC ) {
        if(n==0) AC[0] = SB[0];
        if(n==1) AC[1] = ENOR(SB[1], NOR(DSAL,DAAL) );
        if(n==2) AC[2] = ENOR(SB[2], NAND(NOT(ADD[1]),DSAL) & NAND(ADD[1],DAAL) );
        if(n==3) AC[3] = ENOR(SB[3], NAND(ADD[1]|ADD[2],DSAL) & NAND(NAND(ADD[1],ADD[2]),DAAL) );

        if(n==4) AC[4] = SB[4];
        if(n==5) AC[5] = ENOR(SB[5], NOR(DSAH,DAAH));
        if(n==6) AC[6] = ENOR(SB[6], NAND(DSAH,NOT(ADD[5])) & NAND(ADD[5],DAAH) );
        if(n==7) AC[7] = ENOR(SB[7], NAND(ADD[5]|ADD[6],DSAH) & NAND(NAND(ADD[5],ADD[6]),DAAH) );
    }

    // accumulator output
        if (ALU_AC_SB) SB[n] = AC[n];
        if (ALU_AC_DB) DB[n] = AC[n];
        else if (ALU_SB_DB) DB[n] = SB[n];
    }

    // Output result.
    if (PHI1) {
        if (adc) printf ( "%02X + %02X + %i = %02X, V:%i, C:%i\n", packreg(AI,8) & 0xFF, packreg(BI,8) & 0xFF, NOT(ALU_IADDC), packreg(AC,8) & 0xFF, ALU_AVR, ALU_ACR );
        else printf ( "%02X - %02X + %i = %02X, V:%i, C:%i\n", packreg(AI,8) & 0xFF, ~packreg(BI,8) & 0xFF, NOT(ALU_IADDC), packreg(AC,8) & 0xFF, ALU_AVR, ALU_ACR );
    }
}