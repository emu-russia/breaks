#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

void    Error(char *fmt, ...);
void    Report(char *fmt, ...);

#include "../Breaks6502/SRC/Breaks6502.h"
#include "../BreaksRP2A03/SRC/RP2A03.h"
#include "../BreaksRP2C02/SRC/RP2C02.h"

#include "Motherboard.h"
#include "Cart.h"
#include "Joypads.h"
#include "TVOut.h"
#include "Debug.h"
