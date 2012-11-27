#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

void    Error(char *fmt, ...);
void    Report(char *fmt, ...);

#include "../Breaks6502/6502.h"
#include "../BreaksAPU/APU.h"
#include "../BreaksPPU/PPU.h"

#include "Motherboard.h"
#include "Cart.h"
#include "Joypads.h"
#include "TVOut.h"
#include "Debug.h"
