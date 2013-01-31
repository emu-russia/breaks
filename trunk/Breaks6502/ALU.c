// Test : 66 + AA + 0/1 = 0x110 / 0x111.

void ALU2 (void)
{
    int ALU_0_ADD = 0,
        ALU_SB_ADD = 1,
        ALU_DB_ADD = 1,
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

        ALU_IADDC = 1,
        ALU_DAA = 0,
        ALU_DSA = 0;

    char SB[8], DB[8], ADL[8];
    char AI[8], BI[8], ADD[8], AC[8];
    int OverflowLatch, BinaryCarry, DecimalCarry;
    int PHI1 = 0, PHI2 = 1;

    char nand[8], nor[8], enor[8], eor[8], sums[8], n, carry_out;

    // TEST CASE
    unpackreg (SB, 0x66, 8);
    unpackreg (DB, 0xAA, 8);
    ALU_SUMS = 1;

    carry_out = ALU_IADDC;
    for (n=0; n<8; n++)
    {
    // inputs
        if (ALU_0_ADD) AI[n] = 0;
        if (ALU_SB_ADD) AI[n] = SB[n];
        if (ALU_DB_ADD) BI[n] = DB[n];
        if (ALU_NDB_ADD) BI[n] = NOT(DB[n]);
        if (ALU_ADL_ADD) BI[n] = ADL[n];    

    // logic
        nor[n] = NOR(AI[n],BI[n]);
        nand[n] = NAND(AI[n],BI[n]);
        if (n&1) eor[n] = NOR (NOT(nand[n]), nor[n]);
        else enor[n] = NAND (NOT(nor[n]), nand[n]);

    // arithmetic + carry chain + decimal carry lookahead
        if (n&1) {
            sums[n] = NAND(eor[n],NOT(carry_out)) & NOT(NOR(eor[n],NOT(carry_out)));
            carry_out = NAND(NOT(nor[n]),carry_out) & nand[n];
        }
        else {
            sums[n] = NAND(NOT(carry_out),enor[n]) & NOT (NOR(enor[n],NOT(carry_out)));
            carry_out = NAND(carry_out,nand[n]) & NOT(nor[n]);
        }

    // carry out + overflow

    // adder hold
        if ( PHI2 ) {
            if (ALU_ORS) ADD[n] = nor[n];
            if (ALU_ANDS) ADD[n] = nand[n];
            if (ALU_EORS) {
                if (n&1) ADD[n] = NOT(eor[n]);
                else ADD[n] = enor[n];
            }
            if (ALU_SRS && n) ADD[n-1] = nand[n];
            if (ALU_SUMS) ADD[n] = sums[n];
        }

    }

    // Output result.
    printf ( "ADD: %02X\n", ~packreg(ADD,8) & 0xFF );
}