/*

    Behaviour:
    ----------

    Implied: just emit

    ORG: just set origin in range 0...0xFFFF

    DEFINE: add new define if not exist or replace existing define

    BYTE, WORD:
        - split on parameters, separated by comma
        - determine type of parameter: define -> immediate, string, label
        - emit one by one

    Others are complicated %)
        - split operands on parameters
        - evaluate each parameter and get its type (immediate, address or label)
        - emit opcode variations according to parameter types

    Jumps and branches are emitted with 0 offset, after first pass
    (since not all labels are yet defined)
    Additional pass is need to "patch" jump/branch offsets.

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

void opBRA (char *cmd, char *ops)
{
    label_s * label;
    int type;
    eval_t val;
    split_param (ops);

    if (param_num >= 1) {
        type = eval ( params[0].string, &val );
        if (type == EVAL_LABEL) {
            if ( !stricmp (cmd, "BPL") ) emit (0x10);
            if ( !stricmp (cmd, "BMI") ) emit (0x30);
            if ( !stricmp (cmd, "BVC") ) emit (0x50);
            if ( !stricmp (cmd, "BVS") ) emit (0x70);
            if ( !stricmp (cmd, "BCC") ) emit (0x90);
            if ( !stricmp (cmd, "BCS") ) emit (0xB0);
            if ( !stricmp (cmd, "BNE") ) emit (0xD0);
            if ( !stricmp (cmd, "BEQ") ) emit (0xF0);
            label = add_label (val.label, UNDEF);
            add_patch (label, org, 1, linenum );
            emit (0);
        }
        else WrongParameters (cmd, ops);
    }
    else NotEnoughParameters (cmd);
}

// Jump
// **************************************************************

void opJMP (char *cmd, char *ops)
{
    label_s * label;
    int type;
    eval_t val;
    split_param (ops);

    if (param_num >= 1) {
        type = eval ( params[0].string, &val );
        if (type == EVAL_ADDRESS) {
            if (val.indirect) {
                if ( !stricmp (cmd, "JMP") ) {
                    emit (0x6C);
                    emit ( val.address & 0xff );
                    emit ( (val.address >> 8) & 0xff );
                }
                else WrongParameters (cmd, ops);
            }
            else {
                if ( !stricmp (cmd, "JMP") ) emit (0x4C);
                if ( !stricmp (cmd, "JSR") ) emit (0x20);
                emit ( val.address & 0xff );
                emit ( (val.address >> 8) & 0xff );
            }
        }
        else if (type == EVAL_LABEL) {
            if (val.label->orig != KEYWORD ) {
                if (val.indirect) {
                    if ( !stricmp (cmd, "JMP") ) emit (0x6C);
                    else WrongParameters (cmd, ops);
                }
                else {
                    if ( !stricmp (cmd, "JMP") ) emit (0x4C);
                    if ( !stricmp (cmd, "JSR") ) emit (0x20);
                }
                label = add_label (val.label, UNDEF);
                add_patch (label, org, 0, linenum );
                emit (0); emit (0);
            }
            else WrongParameters (cmd, ops);
        }
        else WrongParameters (cmd, ops);
    }
    else NotEnoughParameters (cmd);
}

// ALU
// **************************************************************

// ORA, AND, EOR, ADC, CMP, SBC
void opALU1 (char *cmd, char *ops)
{
    label_s *label;
    int type[2];
    eval_t val[2];

    split_param (ops);

    if (param_num == 1) {
        type[0] = eval ( params[0].string, &val[0] );
        if ( type[0] == EVAL_ADDRESS ) {
            if ( val[0].address < 0x100 ) {     // Zero page
                if ( !stricmp ( cmd, "ORA" ) ) emit ( 0x05 );
                if ( !stricmp ( cmd, "AND" ) ) emit ( 0x25 );
                if ( !stricmp ( cmd, "EOR" ) ) emit ( 0x45 );
                if ( !stricmp ( cmd, "ADC" ) ) emit ( 0x65 );
                if ( !stricmp ( cmd, "CMP" ) ) emit ( 0xC5 );
                if ( !stricmp ( cmd, "SBC" ) ) emit ( 0xE5 );
                emit ( val[0].address & 0xff );
            }
            else {  // Absolute
                if ( !stricmp ( cmd, "ORA" ) ) emit ( 0x0D );
                if ( !stricmp ( cmd, "AND" ) ) emit ( 0x2D );
                if ( !stricmp ( cmd, "EOR" ) ) emit ( 0x4D );
                if ( !stricmp ( cmd, "ADC" ) ) emit ( 0x6D );
                if ( !stricmp ( cmd, "CMP" ) ) emit ( 0xCD );
                if ( !stricmp ( cmd, "SBC" ) ) emit ( 0xED );
                emit ( val[0].address & 0xff );
                emit ( (val[0].address >> 8) & 0xff );
            }
        }
        else if ( type[0] == EVAL_NUMBER ) {
            if ( !stricmp ( cmd, "ORA" ) ) emit ( 0x09 );
            if ( !stricmp ( cmd, "AND" ) ) emit ( 0x29 );
            if ( !stricmp ( cmd, "EOR" ) ) emit ( 0x49 );
            if ( !stricmp ( cmd, "ADC" ) ) emit ( 0x69 );
            if ( !stricmp ( cmd, "CMP" ) ) emit ( 0xC9 );
            if ( !stricmp ( cmd, "SBC" ) ) emit ( 0xE9 );
            emit ( val[0].number & 0xff );
        }
        else if ( type[0] == EVAL_LABEL ) {     // Absolute by label
            if ( !stricmp ( cmd, "ORA" ) ) emit ( 0x0D );
            if ( !stricmp ( cmd, "AND" ) ) emit ( 0x2D );
            if ( !stricmp ( cmd, "EOR" ) ) emit ( 0x4D );
            if ( !stricmp ( cmd, "ADC" ) ) emit ( 0x6D );
            if ( !stricmp ( cmd, "CMP" ) ) emit ( 0xCD );
            if ( !stricmp ( cmd, "SBC" ) ) emit ( 0xED );
            label = add_label (val[0].label, UNDEF);
            add_patch (label, org, 0, linenum );
            emit (0); emit (0);
        }
        else WrongParameters (cmd, ops);
    }
    else if (param_num == 2) {
        type[0] = eval ( params[0].string, &val[0] );
        type[1] = eval ( params[1].string, &val[1] );

        if ( type[0] == EVAL_LABEL ) {
            if (val[0].label->orig == KEYWORD && !stricmp(val[0].label->name, "X")) {
                if ( type[1] == EVAL_ADDRESS ) {
                    if ( !stricmp ( cmd, "ORA" ) ) emit ( 0x01 );
                    if ( !stricmp ( cmd, "AND" ) ) emit ( 0x21 );
                    if ( !stricmp ( cmd, "EOR" ) ) emit ( 0x41 );
                    if ( !stricmp ( cmd, "ADC" ) ) emit ( 0x61 );
                    if ( !stricmp ( cmd, "CMP" ) ) emit ( 0xC1 );
                    if ( !stricmp ( cmd, "SBC" ) ) emit ( 0xE1 );
                    emit (val[1].address & 0xff);
                }
                else WrongParameters (cmd, ops);
            }
            else if (val[0].label->orig != KEYWORD ) { // Absolute, X/Y
                if (val[1].label->orig == KEYWORD && !stricmp(val[1].label->name, "X")) {
                    if ( !stricmp ( cmd, "ORA" ) ) emit ( 0x1D );
                    if ( !stricmp ( cmd, "AND" ) ) emit ( 0x3D );
                    if ( !stricmp ( cmd, "EOR" ) ) emit ( 0x5D );
                    if ( !stricmp ( cmd, "ADC" ) ) emit ( 0x7D );
                    if ( !stricmp ( cmd, "CMP" ) ) emit ( 0xDD );
                    if ( !stricmp ( cmd, "SBC" ) ) emit ( 0xFD );
                    label = add_label (val[0].label, UNDEF);
                    add_patch (label, org, 0, linenum );
                    emit (0); emit (0);
                }
                else if (val[1].label->orig == KEYWORD && !stricmp(val[1].label->name, "Y")) {
                    if ( !stricmp ( cmd, "ORA" ) ) emit ( 0x19 );
                    if ( !stricmp ( cmd, "AND" ) ) emit ( 0x39 );
                    if ( !stricmp ( cmd, "EOR" ) ) emit ( 0x59 );
                    if ( !stricmp ( cmd, "ADC" ) ) emit ( 0x79 );
                    if ( !stricmp ( cmd, "CMP" ) ) emit ( 0xD9 );
                    if ( !stricmp ( cmd, "SBC" ) ) emit ( 0xF9 );
                    label = add_label (val[0].label, UNDEF);
                    add_patch (label, org, 0, linenum );
                    emit (0); emit (0);
                }
                else WrongParameters (cmd, ops);
            }
            else WrongParameters (cmd, ops);
        }
        else if ( type[0] == EVAL_ADDRESS ) {
            if ( val[0].address < 0x100 ) {     // Zero page, X/Y
                if (val[1].label->orig == KEYWORD && !stricmp(val[1].label->name, "X")) {
                    if ( !stricmp ( cmd, "ORA" ) ) emit ( 0x15 );
                    if ( !stricmp ( cmd, "AND" ) ) emit ( 0x35 );
                    if ( !stricmp ( cmd, "EOR" ) ) emit ( 0x55 );
                    if ( !stricmp ( cmd, "ADC" ) ) emit ( 0x75 );
                    if ( !stricmp ( cmd, "CMP" ) ) emit ( 0xD5 );
                    if ( !stricmp ( cmd, "SBC" ) ) emit ( 0xF5 );
                    emit ( val[0].address & 0xff );
                }
                else if (val[1].label->orig == KEYWORD && !stricmp(val[1].label->name, "Y")) {
                    if ( !stricmp ( cmd, "ORA" ) ) emit ( 0x11 );
                    if ( !stricmp ( cmd, "AND" ) ) emit ( 0x31 );
                    if ( !stricmp ( cmd, "EOR" ) ) emit ( 0x51 );
                    if ( !stricmp ( cmd, "ADC" ) ) emit ( 0x71 );
                    if ( !stricmp ( cmd, "CMP" ) ) emit ( 0xD1 );
                    if ( !stricmp ( cmd, "SBC" ) ) emit ( 0xF1 );
                    emit ( val[0].address & 0xff );
                }
                else WrongParameters (cmd, ops);
            }
            else {      // Absolute, X/Y
                if (val[1].label->orig == KEYWORD && !stricmp(val[1].label->name, "X")) {
                    if ( !stricmp ( cmd, "ORA" ) ) emit ( 0x1D );
                    if ( !stricmp ( cmd, "AND" ) ) emit ( 0x3D );
                    if ( !stricmp ( cmd, "EOR" ) ) emit ( 0x5D );
                    if ( !stricmp ( cmd, "ADC" ) ) emit ( 0x7D );
                    if ( !stricmp ( cmd, "CMP" ) ) emit ( 0xDD );
                    if ( !stricmp ( cmd, "SBC" ) ) emit ( 0xFD );
                    emit ( val[0].address & 0xff );
                    emit ( (val[0].address >> 8) & 0xff );
                }
                else if (val[1].label->orig == KEYWORD && !stricmp(val[1].label->name, "Y")) {
                    if ( !stricmp ( cmd, "ORA" ) ) emit ( 0x1D );
                    if ( !stricmp ( cmd, "AND" ) ) emit ( 0x3D );
                    if ( !stricmp ( cmd, "EOR" ) ) emit ( 0x5D );
                    if ( !stricmp ( cmd, "ADC" ) ) emit ( 0x7D );
                    if ( !stricmp ( cmd, "CMP" ) ) emit ( 0xDD );
                    if ( !stricmp ( cmd, "SBC" ) ) emit ( 0xFD );
                    emit ( val[0].address & 0xff );
                    emit ( (val[0].address >> 8) & 0xff );
                }
                else WrongParameters (cmd, ops);
            }
        }
    }
    else NotEnoughParameters (cmd);
}

// ASL, ROL, LSR, ROR
void opSHIFT (char *cmd, char *ops)
{
}

// BIT
void opBIT (char *cmd, char *ops)
{
    label_s * label;
    int type;
    eval_t val;
    split_param (ops);

    if (param_num >= 1) {
        type = eval ( params[0].string, &val );
        if (type == EVAL_ADDRESS) {
            if ( val.address < 0x100 ) {     // Zero page
                emit (0x24);
                emit ( val.address & 0xff );
            }
            else {      // Absoulte
                emit (0x2C);
                emit ( val.address & 0xff );
                emit ( (val.address >> 8) & 0xff );
            }
        }
        else if (type == EVAL_LABEL) {
            emit (0x2C);
            label = add_label (val.label, UNDEF);
            add_patch (label, org, 0, linenum );
            emit (0); emit (0);
        }
        else WrongParameters (cmd, ops);
    }
    else NotEnoughParameters (cmd);
}

// INC, DEC
void opINCDEC (char *cmd, char *ops)
{
}

// CPX, CPY
void opCPXY (char *cmd, char *ops)
{
}

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
    int i, type, len, c;
    eval_t val;
    split_param (ops);

    for (i=0; i<param_num; i++) {
        type = eval ( params[i].string, &val );
        if ( type == EVAL_LABEL ) printf ( "ERROR(%i): Label cannot be used here\n", linenum );
        else if ( type == EVAL_NUMBER ) {
            emit ( val.number & 0xff );
        }
        else if ( type == EVAL_ADDRESS ) {
            emit ( val.address & 0xff );
        }
        else if ( type == EVAL_STRING ) {
            len = strlen ( val.string );
            for ( c=0; c<len; c++) emit ( val.string[c] );
        }
    }
}

void opWORD (char *cmd, char *ops)
{
    label_s *label;
    int i, type, len, c;
    eval_t val;
    split_param (ops);

    for (i=0; i<param_num; i++) {
        type = eval ( params[i].string, &val );
        if ( type == EVAL_STRING ) printf ( "ERROR(%i): String cannot be used here\n", linenum );
        else if ( type == EVAL_NUMBER ) {
            emit ( val.number & 0xff );
            emit ( (val.number >> 8) & 0xff );
        }
        else if ( type == EVAL_ADDRESS ) {
            emit ( val.address & 0xff );
            emit ( (val.address >> 8) & 0xff );
        }
        else if ( type == EVAL_LABEL ) {
            label = add_label (val.label, UNDEF);
            add_patch (label, org, 0, linenum );
            emit (0); emit (0);
        }
    }
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
        if ( type == EVAL_ADDRESS ) org = val.address & 0xffff;
        else WrongParameters (cmd, ops);
    }
    else NotEnoughParameters (cmd);
}

void opEND (char *cmd, char *ops)
{
    stop = 1;
}

void opDUMMY (char *cmd, char *ops) {}
