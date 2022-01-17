
// Pads.
enum {
    APU_SND1,   // sqare 1/2
    APU_SND2,   // others
    APU_nRES,
    APU_nNMI,
    APU_nIRQ,
    APU_RW,
    APU_PHI2,
    APU_DEBUG,  // enable debug read-out
    APU_CLK,
    APU_ADDR,
    APU_DATA,
    APU_IN0, APU_IN1,   // I/O port
    APU_OUT0, APU_OUT1, APU_OUT2, 
    APU_PAD_MAX,
};

// ------------------------------------------------------------------------
// Control lines

enum {
    M6502_CTRL_NMI, M6502_CTRL_IRQ, M6502_CTRL_RES, // from pads
    M6502_CTRL_nBRDY,       // branch not ready
    M6502_CTRL_nT0, M6502_CTRL_nT1, // primary cycle counter
    M6502_CTRL_nT2, M6502_CTRL_nT3, M6502_CTRL_nT4, M6502_CTRL_nT5,     // secondary cycle counter (shift register)
    M6502_CTRL_nTWOCYCLE,   // Predecode logic results
    M6502_CTRL_nIMPLIED,
    M6502_CTRL_BRKDONE, M6502_CTRL_VEC, M6502_CTRL_NMIG, // interrupt detection logic output
    // Random logic
    M6502_CTRL_CLEARIR, M6502_CTRL_FETCH,  // execution controls
    M6502_CTRL_POUT, M6502_CTRL_PDB, M6502_CTRL_DBZ,     // flags in/out
    M6502_CTRL_RWLATCH,     // R/W output to data latch
    M6502_CTRL_nREADY,      // /ready internal line
    M6502_CTRL_T1,          // internal T1 line from cycle counter.
    M6502_CTRL_I_IN, M6502_CTRL_I_OUT, M6502_CTRL_N_IN, M6502_CTRL_N_OUT, M6502_CTRL_V_IN, M6502_CTRL_V_OUT, M6502_CTRL_D_IN, 
    M6502_CTRL_D_OUT, M6502_CTRL_B_OUT, M6502_CTRL_C_IN, M6502_CTRL_C_OUT, M6502_CTRL_Z_IN, M6502_CTRL_Z_OUT, M6502_CTRL_IE, // flags in/out
    M6502_CTRL_NC, M6502_CTRL_CC, M6502_CTRL_0P, M6502_CTRL_VC1, M6502_CTRL_VC2, M6502_CTRL_DC, M6502_CTRL_I_C, M6502_CTRL_ZC,  // flag set/clear control outputs
    M6502_CTRL_BRTAKEN,     // branch taken
    M6502_CTRL_ARIT,        // arithmetic operations
    M6502_CTRL_nSHIFT, M6502_CTRL_ASRL, M6502_CTRL_SH_R,    // shift/rotate logic outputs

    APU_CTRL_PHI0, APU_CTRL_PHI1, APU_CTRL_PHI2,
    APU_CTRL_ACLK, APU_CTRL_nACLK,
    APU_CTRL_RES, APU_CTRL_INT,
    // Register select
    APU_CTRL_nR4015,
    APU_CTRL_W4017,
    // LFO (frame counter)
    APU_CTRL_LFO1, APU_CTRL_LFO2,
    // DMC
    APU_CTRL_DMCINT,

    APU_CTRL_MAX,
};

// ------------------------------------------------------------------------
// Individual static and dynamic latches (flip/flops)

enum {
    M6502_LATCH_RWOUT,      // output R/W latch
    M6502_FF_NMI, M6502_FF_IRQ, M6502_FF_RES,   // input NMI/IRQ/RES flip-flops
    M6502_LATCH_IRQ, M6502_LATCH_RES,       // IRQ/RES latches
    M6502_LATCH_NMI_IN, M6502_LATCH_NMIG, M6502_LATCH_NMIG_OUT, M6502_LATCH_BRKE_IN, M6502_LATCH_BRKE_OUT,  // interrupt control latches
    M6502_LATCH_BRKDONE_IN, M6502_LATCH_BRKDONE_OUT, M6502_LATCH_BRKDONE, M6502_LATCH_INTDELAY1, M6502_LATCH_INTDELAY2, M6502_LATCH_VEC_OUT,
    M6502_LATCH_PDB,        // flag in/out enable latch
    M6502_FLAG_B, M6502_FLAG_I, M6502_FLAG_C, M6502_FLAG_D, M6502_FLAG_V, M6502_FLAG_Z, M6502_FLAG_N,
    M6502_LATCH_SYNCTOIR,   // SYNC latch to execution control
    M6502_LATCH_TRES,       // secondary cycle counter reset
    M6502_LATCH_BRDY_IN, M6502_LATCH_BRDY_OUT,  // branch ready latches
    M6502_LATCH_nRDY,        // not-ready latch
    M6502_LATCH_RWRDY,      // R/W for ready control
    M6502_LATCH_SYNC,       // sync latch in increment PC logic
    M6502_LATCH_TQ, M6502_LATCH_TR, M6502_LATCH_nTWOCYCLE, M6502_LATCH_TIN, M6502_LATCH_TOUT, M6502_FF_T, // cycle counter 0/1 control latches
    M6502_LATCH_SYNCTR,     // sync latch in secondary cycle counter
    M6502_LATCH_FCTRL_0P, M6502_LATCH_FCTRL_CC, M6502_LATCH_FCTRL_ZC, M6502_LATCH_FCTRL_NC, M6502_LATCH_FCTRL_VC1, M6502_LATCH_FCTRL_VC2, M6502_LATCH_FCTRL_DC, 
    M6502_LATCH_FCTRL_BR, M6502_LATCH_FCTRL_ICIN, M6502_LATCH_FCTRL_ICOUT,   // flag set/clear latches.
    M6502_LATCH_IFLAG_IN, M6502_LATCH_IFLAG_OUT, M6502_LATCH_CFLAG_IN, M6502_LATCH_CFLAG_OUT,   // flag latches
    M6502_LATCH_DFLAG_IN, M6502_LATCH_DFLAG_OUT, M6502_LATCH_VFLAG_IN, M6502_LATCH_VFLAG_OUT, M6502_LATCH_VFLAG_V, M6502_LATCH_VFLAG_SO,
    M6502_LATCH_ZFLAG_IN, M6502_LATCH_ZFLAG_OUT, M6502_LATCH_NFLAG_IN, M6502_LATCH_NFLAG_OUT, M6502_LATCH_BFLAG_IN, M6502_LATCH_BFLAG_OUT,
    M6502_LATCH_SHIFT_IN, M6502_LATCH_SHR_IN, M6502_LATCH_SHR_OUT, M6502_LATCH_ASRL_IN, M6502_LATCH_ASRL_OUT,   // shift/rotate logic latches
    M6502_LATCH_INTR_RESET, M6502_LATCH_INTR, M6502_LATCH_INTR_NMIG,        // interrupt handling
    M6502_LATCH_PCHDB, M6502_LATCH_PCREADY, M6502_LATCH_PCLDB,      // PC setup latches
    // Bottom part (ALU)
    M6502_LATCH_DAA, M6502_LATCH_DSA, M6502_LATCH_BCARRY, M6502_LATCH_DCARRY, M6502_LATCH_AVR,
    M6502_LATCH_HALF, M6502_LATCH_DSAL,

    APU_LFO_RATE_LATCH, APU_LFO_IRQ_LATCH, APU_LFO_RESET_LATCH,
    APU_LFO_RESET_FF,

    APU_FF_MAX,
};

// ------------------------------------------------------------------------
// Registers

enum {
    M6502_REG_IR,       // instruction register
    M6502_REG_PD,       // predecode register
    M6502_REG_RANDOM_LATCH, // output random logic latches
    M6502_REG_TRIN, M6502_REG_TROUT,    // secondary cycle counter i/o latches
    M6502_REG_Y, M6502_REG_X, M6502_REG_S,  // X,Y,S
    M6502_REG_AI, M6502_REG_BI, M6502_REG_ADD, M6502_REG_AC,    // ALU regs
    M6502_REG_PCH, M6502_REG_PCHS, M6502_REG_PCL, M6502_REG_PCLS,   // program counter
    M6502_REG_ABH, M6502_REG_ABL,   // address bus output
    M6502_REG_DOR, M6502_REG_DL,    // data output, data latch

    APU_REG_LFO_IN, APU_REG_LFO_OUT, APU_REG_4015, APU_REG_4017,

    APU_REG_MAX,
};

// ------------------------------------------------------------------------
// Buses (internal)

enum {
    M6502_BUS_PLA,      // PLA outputs
    M6502_BUS_RANDOM,   // random logic outputs
    M6502_BUS_SB, M6502_BUS_DB, M6502_BUS_ADH, M6502_BUS_ADL,

    APU_BUS_DB,
    
    APU_BUS_MAX,
};

// random logic outputs
enum {
    M6502_ADH_ABH,
    M6502_ADL_ABL,
    M6502_Y_SB,
    M6502_X_SB,
    M6502_0_ADL0,
    M6502_0_ADL1,
    M6502_0_ADL2 ,
    M6502_SB_Y,
    M6502_SB_X,
    M6502_S_SB ,
    M6502_S_ADL,
    M6502_SB_S ,
    M6502_S_S,
    M6502_nDB_ADD,
    M6502_DB_ADD,
    M6502_0_ADD ,
    M6502_SB_ADD  ,
    M6502_ADL_ADD ,
    M6502_ANDS,
    M6502_EORS ,
    M6502_ORS,
    M6502_I_ADDC,
    M6502_SRS,
    M6502_SUMS,
    M6502_DAA,
    M6502_ADD_SB7,
    M6502_ADD_SB06,
    M6502_ADD_ADL,
    M6502_DSA ,
    M6502_AVR,
    M6502_ACR,
    M6502_0_ADH0 ,
    M6502_SB_DB,
    M6502_SB_AC,
    M6502_SB_ADH,
    M6502_0_ADH17,
    M6502_AC_SB,
    M6502_AC_DB,
    M6502_ADH_PCH,
    M6502_PCH_PCH,
    M6502_PCH_DB,
    M6502_PCL_DB,
    M6502_PCH_ADH,
    M6502_PCL_PCL,
    M6502_PCL_ADL,
    M6502_ADL_PCL,
    M6502_IPC,
    M6502_DL_ADL,
    M6502_DL_ADH,
    M6502_DL_DB ,
    M6502_P_DB,
    M6502_DBZ ,
};

// ------------------------------------------------------------------------
// Debug

enum {
    APU_DEBUG_CLKCOUNT,
    APU_DEBUG_OUT,

    APU_DEBUG_MAX,
};

// ------------------------------------------------------------------------
// Context.

typedef struct ContextAPU
{
    unsigned long pad[APU_PAD_MAX];   // I/O pads and external buses
    char    latch[APU_FF_MAX];       // individual latches
    int     ctrl[APU_CTRL_MAX];      // control lines
    char    reg[APU_REG_MAX][64];  // registers
    char    bus[APU_BUS_MAX][130];  // internal buses
    int     debug[APU_DEBUG_MAX];    // debug variables
} ContextAPU;

// Emulate single half-clock.
void APUStep (ContextAPU *apu);
