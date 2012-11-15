// Private.

#include "RP2C02.h"

#include "BUS.h"
#include "COUNTERS.h"
#include "DATAREAD.h"
#include "HV.h"
#include "HV_LOGIC.h"
#include "MUX.h"
#include "OAM.h"
#include "OAM_EVAL.h"
#include "OAM_FIFO.h"
#include "PALETTE.h"
#include "PPU_CLOCK.h"
#include "REGSELECT.h"
#include "VIDOUT.h"

#define BIT(n)     ( (n) & 1 )

unsigned long packreg ( char *reg, int bits );
void unpackreg (char *reg, unsigned char val, int bits);

int NAND(int a, int b);
int NOR(int a, int b);
