/*

    Behaviour:
    ----------

    Implied: just emit

    ORG: just set origin in range 0...0xFFFF

    DEFINE: add new define if not exist or replace existing define

    BYTE, WORD:
        - split on parameters, separated by comma
        - determine type of parameter: define -> immediate, string, label

    Others are complicated %)

*/

// Typical errors

static void NotEnoughParameters (char *cmd)
{
    printf ( "ERROR(%i): %s not enough parameters\n", linenum, cmd);
}

static void WrongParameters (char *cmd, char *op)
{
    printf ( "ERROR(%i): %s wrong parameters: %s\n", linenum, cmd, op);
}


// Implied
// **************************************************************

void opBRK (char *cmd, char *ops) { emit (0x00); }
void opRTI (char *cmd, char *ops) { emit (0x40); }
void opRTS (char *cmd, char *ops) { emit (0x60); }

void opPHP (char *cmd, char *ops) { emit (0x08); }
void opCLC (char *cmd, char *ops) { emit (0x18); }
void opPLP (char *cmd, char *ops) { emit (0x28); }
void opSEC (char *cmd, char *ops) { emit (0x38); }
void opPHA (char *cmd, char *ops) { emit (0x48); }
void opCLI (char *cmd, char *ops) { emit (0x58); }
void opPLA (char *cmd, char *ops) { emit (0x68); }
void opSEI (char *cmd, char *ops) { emit (0x78); }
void opDEY (char *cmd, char *ops) { emit (0x88); }
void opTYA (char *cmd, char *ops) { emit (0x98); }
void opTAY (char *cmd, char *ops) { emit (0xA8); }
void opCLV (char *cmd, char *ops) { emit (0xB8); }
void opINY (char *cmd, char *ops) { emit (0xC8); }
void opCLD (char *cmd, char *ops) { emit (0xD8); }
void opINX (char *cmd, char *ops) { emit (0xE8); }
void opSED (char *cmd, char *ops) { emit (0xF8); }

void opTXA (char *cmd, char *ops) { emit (0x8A); }
void opTXS (char *cmd, char *ops) { emit (0x9A); }
void opTAX (char *cmd, char *ops) { emit (0xAA); }
void opTSX (char *cmd, char *ops) { emit (0xBA); }
void opDEX (char *cmd, char *ops) { emit (0xCA); }
void opNOP (char *cmd, char *ops) { emit (0xEA); }

// Load/Store
// **************************************************************

void opLDX (char *cmd, char *ops)
{
    int type[2];
    eval_t val[2];

    split_param (ops);

    if (param_num == 1) {
        type[0] = eval ( params[0].string, &val[0] );
        if ( type[0] == EVAL_NUMBER ) {     // Immediate
            emit (0xA2);
            emit (val[0].number & 0xff);
        }
        else if ( type[0] == EVAL_ADDRESS ) {
            if ( val[0].address >= 0x100 ) {    // Absolute
                emit (0xAE);
                emit (val[0].address & 0xff);
                emit ((val[0].address >> 8) & 0xff);
            }
            else {  // Zero page
                emit (0xA6);
                emit (val[0].address & 0xff);
            }
        }
        else WrongParameters (cmd, ops);
    }
    else if (param_num == 2) {
        type[0] = eval ( params[0].string, &val[0] );
        type[1] = eval ( params[1].string, &val[1] );

        if ( type[0] == EVAL_ADDRESS && type[1] == EVAL_LABEL ) {
            if (val[1].label->orig == KEYWORD && !stricmp(val[1].label->name, "Y")) {
                if ( val[0].address >= 0x100 ) {    // Absolute
                    emit (0xBE);
                    emit (val[0].address & 0xff);
                    emit ((val[0].address >> 8) & 0xff);
                }
                else {  // Zero page
                    emit (0xB6);
                    emit (val[0].address & 0xff);
                }
            }
            else WrongParameters (cmd, ops);
        }
        else WrongParameters (cmd, ops);
    }
    else NotEnoughParameters (cmd);
}

void opLDY (char *cmd, char *ops)
{
    int type[2];
    eval_t val[2];

    split_param (ops);

    if (param_num == 1) {
        type[0] = eval ( params[0].string, &val[0] );
        if ( type[0] == EVAL_NUMBER ) {     // Immediate
            emit (0xA0);
            emit (val[0].number & 0xff);
        }
        else if ( type[0] == EVAL_ADDRESS ) {
            if ( val[0].address >= 0x100 ) {    // Absolute
                emit (0xAC);
                emit (val[0].address & 0xff);
                emit ((val[0].address >> 8) & 0xff);
            }
            else {  // Zero page
                emit (0xA4);
                emit (val[0].address & 0xff);
            }
        }
        else WrongParameters (cmd, ops);
    }
    else if (param_num == 2) {
        type[0] = eval ( params[0].string, &val[0] );
        type[1] = eval ( params[1].string, &val[1] );

        if ( type[0] == EVAL_ADDRESS && type[1] == EVAL_LABEL ) {
            if (val[1].label->orig == KEYWORD && !stricmp(val[1].label->name, "X")) {
                if ( val[0].address >= 0x100 ) {    // Absolute
                    emit (0xBC);
                    emit (val[0].address & 0xff);
                    emit ((val[0].address >> 8) & 0xff);
                }
                else {  // Zero page
                    emit (0xB4);
                    emit (val[0].address & 0xff);
                }
            }
            else WrongParameters (cmd, ops);
        }
        else WrongParameters (cmd, ops);
    }
    else NotEnoughParameters (cmd);
}

// Branches
// **************************************************************

// Jump
// **************************************************************

// ALU
// **************************************************************

// DEFINE
// **************************************************************

void opDEFINE (char *cmd, char *ops)
{
    char name[256], *p = name;
    while (*ops > ' ' && *ops ) *p++ = *ops++;
    *p++ = 0;
    while (*ops <= ' ' && *ops ) ops++;
    add_define (name, ops);
}

// BYTE, WORD
// **************************************************************

void opBYTE (char *cmd, char *ops)
{
}

void opWORD (char *cmd, char *ops)
{
}

// Misc.
// **************************************************************

void opORG (char *cmd, char *ops)
{
    int type;
    eval_t val;

    split_param (ops);

    if (param_num == 1) {
        type = eval ( params[0].string, &val );
        if ( type == EVAL_ADDRESS ) org = val.address;
        else WrongParameters (cmd, ops);
    }
    else NotEnoughParameters (cmd);
}

void opEND (char *cmd, char *ops)
{
    stop = 1;
}

void opDUMMY (char *cmd, char *ops) {}
