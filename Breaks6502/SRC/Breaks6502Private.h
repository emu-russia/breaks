
// Top part components

#include "MISC.h"
#include "INTERRUPT.h"
#include "TIME_REG.h"
#include "IR.h"
#include "PREDECODE.h"
#include "PLA.h"
#include "RANDOM_LOGIC.h"

// Bottrom part components

#include "ADDR_BUS.h"
#include "DATA_BUS.h"
#include "REGS.h"
#include "ALU.h"
#include "PROGRAM_COUNTER.h"


#define BIT(n)     ( (n) & 1 )

unsigned long packreg ( char *reg, int bits );
void unpackreg (char *reg, unsigned char val, int bits);
