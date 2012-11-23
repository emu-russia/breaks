
// Pads.
enum {
    M6502_PAD_nNMI,
    M6502_PAD_nIRQ,
    M6502_PAD_PHI1,
    M6502_PAD_RDY,
    M6502_PAD_nRES,
    M6502_PAD_PHI2,
    M6502_PAD_SO,
    M6502_PAD_PHI0,
    M6502_PAD_RW,
    M6502_PAD_DATA,
    M6502_PAD_ADDR,
    M6502_PAD_SYNC,
    M6502_PAD_MAX,
};

// ------------------------------------------------------------------------
// Control lines

enum {
    M6502_CTRL_NMI, M6502_CTRL_IRQ, M6502_CTRL_RES, // from pads
    M6502_CTRL_nBRDY,       // branch not ready
    M6502_CTRL_IR01,        // IR0 | IR1 to PLA
    M6502_CTRL_nT0, M6502_CTRL_nT1, // primary cycle counter
    M6502_CTRL_nT2, M6502_CTRL_nT3, M6502_CTRL_nT4, M6502_CTRL_nT5,     // secondary cycle counter (shift register)
    M6502_CTRL_nTWOCYCLE,   // Predecode logic results
    M6502_CTRL_nIMPLIED,
        // random logic
    M6502_CTRL_CLEARIR, M6502_CTRL_FETCH,  // execution controls
    M6502_CTRL_POUT, M6502_CTRL_PDB, M6502_CTRL_DBZ,     // flags in/out
    M6502_CTRL_RWLATCH,     // R/W output to data latch
    M6502_CTRL_nREADY,      // /ready internal line
    M6502_CTRL_T1,          // internal T1 line from cycle counter.
    M6502_CTRL_I_IN, M6502_CTRL_I_OUT, M6502_CTRL_N_IN, M6502_CTRL_N_OUT, M6502_CTRL_V_IN, M6502_CTRL_V_OUT, M6502_CTRL_D_IN, 
    M6502_CTRL_D_OUT, M6502_CTRL_B_OUT, M6502_CTRL_C_IN, M6502_CTRL_C_OUT, M6502_CTRL_Z_IN, M6502_CTRL_Z_OUT, // flags in/out
    M6502_CTRL_BRTAKEN,     // branch taken

    M6502_CTRL_MAX,
};

// ------------------------------------------------------------------------
// Individual static and dynamic latches (flip/flops)

enum {
    M6502_LATCH_RWOUT,      // output R/W latch
    M6502_FF_NMI, M6502_FF_IRQ, M6502_FF_RES,   // input NMI/IRQ/RES flip-flops
    M6502_LATCH_IRQ, M6502_LATCH_RES,       // IRQ/RES latches
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
    M6502_LATCH_FCTRL_0P, M6502_LATCH_FCTRL_CC, M6502_LATCH_FCTRL_NC, M6502_LATCH_FCTRL_VC1, M6502_LATCH_FCTRL_VC2, M6502_LATCH_FCTRL_DC, M6502_LATCH_FCTRL_IC, 
    M6502_LATCH_FCTRL_BRIN, M6502_LATCH_FCTRL_BROUT, M6502_LATCH_FCTRL_ICIN, M6502_LATCH_FCTRL_ICOUT,   // flag set/clear latches.
    M6502_LATCH_IFLAG_IN, M6502_LATCH_IFLAG_OUT, M6502_LATCH_CFLAG_IN, M6502_LATCH_CFLAG_OUT,
    M6502_LATCH_DFLAG_IN, M6502_LATCH_DFLAG_OUT,
    M6502_LATCH_VFLAG_IN, M6502_LATCH_VFLAG_OUT,M6502_LATCH_VFLAG_V, M6502_LATCH_VFLAG_SO,
    M6502_LATCH_ZFLAG_IN, M6502_LATCH_ZFLAG_OUT,
    M6502_LATCH_NFLAG_IN, M6502_LATCH_NFLAG_OUT,

    M6502_FF_MAX,
};

// ------------------------------------------------------------------------
// Registers

enum {
    M6502_REG_IR,       // instruction register
    M6502_REG_PD,       // predecode register
    M6502_REG_RANDOM_LATCH, // output random logic latches
    M6502_REG_RANDOM_FF,    // output random logic flip/flops
    M6502_REG_TRIN, M6502_REG_TROUT,    // secondary cycle counter i/o latches

    M6502_REG_MAX,
};

// ------------------------------------------------------------------------
// Buses (internal)

enum {
    M6502_BUS_PLA,      // PLA outputs
    M6502_BUS_SB, M6502_BUS_DB,
    M6502_BUS_RANDOM,   // random logic outputs
    
    M6502_BUS_MAX,
};

// ------------------------------------------------------------------------
// Debug

enum {
    M6502_DEBUG_CLKCOUNT,

    M6502_DEBUG_MAX,
};

// ------------------------------------------------------------------------
// Context.

typedef struct ContextM6502
{
    unsigned long pad[M6502_PAD_MAX];   // I/O pads and external buses
    char    latch[M6502_FF_MAX];       // individual latches
    int     ctrl[M6502_CTRL_MAX];      // control lines
    char    reg[M6502_REG_MAX][64];  // registers
    char    bus[M6502_BUS_MAX][130];  // internal buses
    int     debug[M6502_DEBUG_MAX];    // debug variables
} ContextM6502;

// Emulate single half-clock.
void M6502Step (ContextM6502 *cpu);
