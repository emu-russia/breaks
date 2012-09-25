#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

void    Report(char *fmt, ...);

#include "../Breaks6502/SRC/Breaks6502.h"

#include "Motherboard.h"
#include "Cart.h"
#include "Joypads.h"
#include "TVOut.h"
#include "Debug.h"
