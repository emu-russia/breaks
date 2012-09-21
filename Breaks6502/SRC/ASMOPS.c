
// Implied
// **************************************************************

void opBRK (char *ops) { emit (0x00); }
void opRTI (char *ops) { emit (0x40); }
void opRTS (char *ops) { emit (0x60); }

void opPHP (char *ops) { emit (0x08); }
void opCLC (char *ops) { emit (0x18); }
void opPLP (char *ops) { emit (0x28); }
void opSEC (char *ops) { emit (0x38); }
void opPHA (char *ops) { emit (0x48); }
void opCLI (char *ops) { emit (0x58); }
void opPLA (char *ops) { emit (0x68); }
void opSEI (char *ops) { emit (0x78); }
void opDEY (char *ops) { emit (0x88); }
void opTYA (char *ops) { emit (0x98); }
void opTAY (char *ops) { emit (0xA8); }
void opCLV (char *ops) { emit (0xB8); }
void opINY (char *ops) { emit (0xC8); }
void opCLD (char *ops) { emit (0xD8); }
void opINX (char *ops) { emit (0xE8); }
void opSED (char *ops) { emit (0xF8); }

void opTXA (char *ops) { emit (0x8A); }
void opTXS (char *ops) { emit (0x9A); }
void opTAX (char *ops) { emit (0xAA); }
void opTSX (char *ops) { emit (0xBA); }
void opDEX (char *ops) { emit (0xCA); }
void opNOP (char *ops) { emit (0xEA); }

// Load/Store
// **************************************************************

void opLDX (char *ops)
{
    printf ("LDX: ");
}

// Branches
// **************************************************************

// Jump
// **************************************************************

// ALU
// **************************************************************

// DEFINE
// **************************************************************

// BYTE, WORD
// **************************************************************

// Misc.
// **************************************************************
