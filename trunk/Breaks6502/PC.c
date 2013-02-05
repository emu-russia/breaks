
void PC (int clk)
{
    static unsigned char PCL[8], PCLS[8], PCH[8], PCHS[8];
    int n, carry_in, carry_out;
    int PHI1 = NOT(clk), PHI2 = clk;

    carry_in = 0;
    for (n=0; n<8; n++) {
        if (n&1) {
            PCLS[n] = NOT(PCL[n]);
            carry_out = NAND(PCLS[n], carry_in);
            if (PHI2) PCL[n] = NOR(PCLS[n], carry_in) | NOT(carry_out);
        }
        else {
            PCLS[n] = PCL[n];
            carry_out = NOR(NOT(PCLS[n]), carry_in);
            if (PHI2) PCL[n] = NAND(NOT(PCLS[n]), carry_in) & NOT(carry_out);
        }
        carry_in = carry_out;
    }

    printf ("PCLS=%02X\n", packreg(PCLS,8) & 0xFF);
}
