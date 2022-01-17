#include "APU.h"

// Global quickies.

#define PHI1     (apu->ctrl[APU_CTRL_PHI1])
#define PHI2     (apu->ctrl[APU_CTRL_PHI2])
#define ACLK     (apu->ctrl[APU_CTRL_ACLK])
#define nACLK    (apu->ctrl[APU_CTRL_nACLK])

// Basic logic
int BIT(n)     { return ( (n) & 1 ); }
int NOT(int a) { return (~a & 1); }
int NAND(int a, int b) { return ~((a & 1) & (b & 1)) & 1; }
int NOR(int a, int b) { return ~((a & 1) | (b & 1)) & 1; }

unsigned long packreg ( char *reg, int bits )
{
    unsigned long val = 0, i;
    for (i=0; i<bits; i++) {
        if (reg[i]) val |= (1 << i);
    }
    return val;
} 

void unpackreg (char *reg, unsigned long val, int bits)
{
    int i;
    for (i=0; i<bits; i++) {
        reg[i] = (val >> i) & 1;
    }
}

// ----------------------------------------------------------------------------
//
//               I N T E G R A T E D   6 5 0 2   C O R E
//
// ----------------------------------------------------------------------------

static void CLOCK (ContextAPU *apu)
{
    PHI2 = BIT(apu->ctrl[APU_CTRL_PHI0]);   // read-mode
    PHI1 = NOT(PHI2);       // write-mode
}

// ----------------------------------------------------------------------------
//
//                  A P U   S E C T I O N
//
// ----------------------------------------------------------------------------

static void ACLOCK (ContextAPU *apu)
{
    ACLK = apu->ctrl[APU_CTRL_PHI2];
    nACLK = NOT(ACLK);
}

static void LFO (ContextAPU *apu)
{
    int i, n, f1, f2, z1, z2, c13, c14, ff, bit, out;
    char *mask[6]  = {
        "011110011111011",      // 28574
        "001111111001001",      // 18940
        "001101001100101",      // 21292
        "000001111010111",      // 30176
        "010111100111000",      // 3706
        "111111111111111",      // 32767
    }, *str;
    int dec[6] = {1,1,1,1,1,1};

    // decoder
    for (i=0; i<15; i++) {
        for (n=0; n<6; n++) {
            str = mask[n];
            bit = ( (str[i] == '1') ? 1 : 0 );
            if ( BIT(apu->reg[APU_REG_LFO_OUT][i]) != bit ) dec[n] = 0;
        }
    }
/*
    // ugly version
    #define C(n)  (apu->reg[APU_REG_LFO_OUT][n])
    #define NC(n) (NOT(apu->reg[APU_REG_LFO_OUT][n]))
    dec[0] = NOT ( C(0) | NC(1) | NC(2) | NC(3) | NC(4) | C(5) | C(6) | NC(7) | NC(8) | NC(9) | NC(10) | NC(11) | C(12) | NC(13) | NC(14) );
    dec[1] = NOT ( C(0) | C(1) | NC(2) | NC(3) | NC(4) | NC(5) | NC(6) | NC(7) | NC(8) | C(9) | C(10) | NC(11) | C(12) | C(13) | NC(14) );
    dec[2] = NOT ( C(0) | C(1) | NC(2) | NC(3) | C(4) | NC(5) | C(6) | C(7) | NC(8) | NC(9) | C(10) | C(11) | NC(12) | C(13) | NC(14) );
    dec[3] = NOT ( C(0) | C(1) | C(2) | C(3) | C(4) | NC(5) | NC(6) | NC(7) | NC(8) | C(9) | NC(10) | C(11) | NC(12) | NC(13) | NC(14) );
    dec[4] = NOT ( C(0) | NC(1) | C(2) | NC(3) | NC(4) | NC(5) | NC(6) | C(7) | C(8) | NC(9) | NC(10) | NC(11) | C(12) | C(13) | C(14) );
    dec[5] = NOT ( NC(0) | NC(1) | NC(2) | NC(3) | NC(4) | NC(5) | NC(6) | NC(7) | NC(8) | NC(9) | NC(10) | NC(11) | NC(12) | NC(13) | NC(14) );
*/
    c13 = NOT(apu->reg[APU_REG_LFO_OUT][13]);
    c14 = NOT(apu->reg[APU_REG_LFO_OUT][14]);
    out = NAND(c13,c14) & NOT( NOT(c13 | dec[5] | c14));

    // control logic
    ff = NOT(apu->reg[APU_REG_4017][7]);
    if (nACLK) {
        apu->latch[APU_LFO_RATE_LATCH] = ff;
        apu->reg[APU_REG_4017][7] = NOT(ff);
    }
    if (apu->ctrl[APU_CTRL_W4017]) apu->reg[APU_REG_4017][7] = apu->bus[APU_BUS_DB][7];
    ff = NOT(apu->reg[APU_REG_4017][6]);
    if (nACLK) apu->reg[APU_REG_4017][6] = NOT(ff);
    if (apu->ctrl[APU_CTRL_W4017]) apu->reg[APU_REG_4017][6] = apu->bus[APU_BUS_DB][6];

    // LFO reset    
    ff = NOT(apu->latch[APU_LFO_RESET_FF]) & NOT(apu->ctrl[APU_CTRL_W4017] | apu->ctrl[APU_CTRL_RES]);
    if (nACLK) apu->latch[APU_LFO_RESET_LATCH] = ff;
    apu->latch[APU_LFO_RESET_FF] = NOR ( NOR(ACLK, apu->latch[APU_LFO_RESET_LATCH]), ff );
    z1 = NOT(apu->latch[APU_LFO_RESET_LATCH]);
    z2 = NOR(apu->latch[APU_LFO_RATE_LATCH], apu->latch[APU_LFO_RESET_LATCH]);

    // update counter from f1/f2 control lines
    f1 = NOR ( NOT (dec[3] | dec[4] | z1), ACLK);
    f2 = NOR ( (dec[3] | dec[4] | z1), ACLK);
    for(i=0; i<15; i++) {
        if (f1) apu->reg[APU_REG_LFO_IN][i] = 1;
        if (f2) apu->reg[APU_REG_LFO_IN][i] = out;
        out = NOT(apu->reg[APU_REG_LFO_OUT][i]);
        if (nACLK) apu->reg[APU_REG_LFO_OUT][i] = NOT(apu->reg[APU_REG_LFO_IN][i]);
    }

    // interrupt logic
    ff = NOT (apu->reg[APU_REG_4015][6]);
    if ( NOT( apu->ctrl[APU_CTRL_RES] | apu->reg[APU_REG_4017][6] | NOR(PHI1,apu->ctrl[APU_CTRL_nR4015])) ) ff = 0;
    apu->ctrl[APU_CTRL_INT] = apu->ctrl[APU_CTRL_DMCINT] | ff;
    apu->reg[APU_REG_4015][6] = NAND( NOT(apu->reg[APU_REG_4017][7]), dec[3] ) & NOT(ff);
    if (nACLK) apu->latch[APU_LFO_IRQ_LATCH] = apu->reg[APU_REG_4015][6];
    if ( apu->ctrl[APU_CTRL_nR4015] ) apu->bus[APU_BUS_DB][6] = NOT(apu->latch[APU_LFO_IRQ_LATCH]);

    // outputs
    apu->ctrl[APU_CTRL_LFO1] = NOT (z2 | dec[0] | dec[1] | dec[2] | dec[3] | dec[4] ) | ACLK;
    apu->ctrl[APU_CTRL_LFO2] = NOT (z2 | dec[1] | dec[3] | dec[4]) | ACLK;
}

void APUStep (ContextAPU *apu)
{
    CLOCK (apu);

    ACLOCK (apu);
    LFO (apu);
}
