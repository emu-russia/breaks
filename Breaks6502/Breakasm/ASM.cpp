// 6502 assembler.
// There is NO experssion evaluation, I'm lazy to it )
#include "pch.h"

/*
    Assembler syntax:

    [LABEL:]  COMMAND  [OPERAND1, OPERAND2, OPERAND3]       ; Comments

    Commands can be any 6502 instruction or one of reserved directives:
        ORG, DEFINE, BYTE, WORD, END, PROCESSOR

    Register names and CPU instructions cannot be used as label names.

    You cannot DEFINE, if such label is already defined.
    Redefinition of labels is NOT allowed.
    Redefinition of DEFINEs just replace previous definition.
*/

static unsigned char *PRG;
long org;        // current emit offset
int linenum;
long stop;
long errors;

static  label_s *labels;    // name labels
static  int labels_num;

static  patch_s *patchs;    // patch history
static  int patch_num;

static  define_s *defines;  // definitions
static  int define_num;

// ****************************************************************

// Labels management.
//

static label_s * label_lookup (char *name)
{
    int i;
    label_s * label;
    for (i=0; i<labels_num; i++) {
        label = &labels[i];
        if (!_stricmp (label->name, name)) return label;
    }
    return NULL;
}

label_s *add_label (const char *name, long orig)
{
    char temp_name[0x200] = { 0 };
    strcpy(temp_name, name);

    int len = (int)strlen (temp_name), i;
    label_s * label;
    for (i=len-1; i>=0; i--) {
        if (temp_name[i] <= ' ') temp_name[i] = 0;
    }
    //printf ( "ADD LABEL(%i): \'%s\' = %08X\n", linenum, temp_name, orig);
    label = label_lookup (temp_name);
    if ( label == NULL ) {
        if (labels_num >= MAX_LABELS)
        {
            printf("ERROR: Number of labels exceeded (%d)\n", MAX_LABELS);
            errors++;
            return NULL;
        }
        label = &labels[labels_num];
        labels_num++;
        strcpy (label->name, temp_name);
        label->orig = orig;
        label->line = linenum;
    }
    else {
        if ( label->orig == KEYWORD ) {
            printf ("ERROR(%i): Reserved keyword used as label \'%s\'\n", linenum, temp_name);
            errors++;
        }
        else if (orig != UNDEF && label->orig != UNDEF ) {
            printf ("ERROR(%i): label \'%s\' already defined in line %i\n", linenum, temp_name, label->line);
            errors++;
        }
        else {
            if (orig != UNDEF) {
                label->orig = orig;
                label->line = linenum;
            }
        }
    }
    return label;
}

static void dump_labels (void)
{
    int i;
    label_s * label;
    printf ("\nLABELS (%i):\n", labels_num);
    for (i=0; i<labels_num; i++) {
        label = &labels[i];
        if (label->orig == KEYWORD) continue;
        printf ("%i: $%08X = \'%s\'\n", i+1, label->orig, label->name);
    }
}

// Patch management.
//

void add_patch (label_s *label, long orig, int branch, int line)
{
    if (patch_num >= MAX_PATCH)
    {
        printf("ERROR: Number of patches exceeded (%d)\n", MAX_PATCH);
        errors++;
        return;
    }
    patch_s * patch;
    patch = &patchs[patch_num];
    patch_num++;
    patch->label = label;
    patch->orig = orig;
    patch->branch = branch;
    patch->line = line;
}

static void do_patch (void)
{
    long orig;
    int i, rel;
    patch_s * patch;
    for (i=0; i<patch_num; i++) {
        patch = &patchs[i];
        orig = patch->label->orig;
        if ( orig == UNDEF ) {
            printf ("ERROR(%i): Undefined label \'%s\' (%08X)\n", patch->line, patch->label->name, orig );
            errors++;
        }
        else { 
            if ( patch->branch != 0) {
                org = patch->orig;
                rel = orig - org - 1;
                if (rel > 127 || rel < -128) {
                    printf("ERROR(%i): Branch relative offset to %s out of range\n", patch->line, patch->label->name);
                    errors++;
                }
                else emit(rel & 0xff);
            }
            else {
                org = patch->orig;
                emit ( orig & 0xff );
                emit ( (orig >> 8) & 0xff );
            }    
        }
    }
}

static void dump_patches (void)
{
    int i;
    patch_s * patch;
    printf ("\nPATCHS (%i):\n", patch_num);
    for (i=0; i<patch_num; i++) {
        patch = &patchs[i];
        printf ("LINE %i: $%08X = \'%s\'", patch->line, patch->orig, patch->label->name);
        if (patch->branch ) printf (" (REL)\n");
        else printf (" (ABS)\n");
    }
}

// Defines management.
//

static define_s * define_lookup (char *name)
{
    int i;
    define_s * def;
    for (i=0; i<define_num; i++) {
        def = &defines[i];
        if (!_stricmp (def->name, name)) return def;
    }
    return NULL;
}

define_s *add_define (char *name, char *replace)
{
    label_s * label;
    define_s * def;

    if ( label = label_lookup (name) ) {
        printf ("ERROR(%i): Already defined as label in line %i\n", linenum, label->line );
        errors++;
        return NULL;
    }

    def = define_lookup (name);
    if ( def ) {
        strcpy (def->replace, replace);
    }
    else {
        if (define_num >= MAX_DEFINE)
        {
            printf("ERROR: Number of macros exceeded (%d)\n", MAX_DEFINE);
            errors++;
            return NULL;
        }
        def = &defines[define_num];
        define_num++;
        strcpy (def->name, name);
        strcpy (def->replace, replace);
    }
    return def;
}

static void dump_defines (void)
{
    int i;
    define_s * def;
    printf ("\nDEFINES (%i):\n", define_num);
    for (i=0; i<define_num; i++) {
        def = &defines[i];
        printf ("%i: %s = %s\n", i+1, def->name, def->replace);
    }
}

// ****************************************************************
// Evaluate expression

// Evaluation code can be replaced by more complicated version (with macro-operations etc.)

int eval (char *text, eval_t *result)
{
    char buf[1024], *p = buf, c, quot = 0, *ptr;
    int type = EVAL_WTF, i, len;
    define_s * def;
    label_s * label;

    // Indirect test
    result->indirect = 0;
    len = (int)strlen (text);
    for (i=0; i<len; i++) {
        c = text[i];
        if ( (c == '(' || c == ')') && quot == 0 ) {
            text[i] = ' ';
            result->indirect = 1;
        }
        else if ( c == '\"' || c == '\'' ) {
            if ( c == quot ) quot = 0;
            else quot = c;
        }
    }
    for (i=len-1; i>=0; i--) {
        if ( text[i] <= ' ' ) text[i] = 0;
        else break;
    }
    ptr = text;
    while (*ptr <= ' ' && *ptr) ptr++;      // Skip whitespaces
    text = ptr;

    if ( text[0] == '#' || isdigit(text[0]) ) {      // Number
        if (!isdigit(text[0])) text++;
        while (1) {
            c = *text++;
            if (c == 0) break;
            if (c == '$') {
                *p++ = '0';
                *p++ = 'x';
            }
            else *p++ = c;
        }
        *p++ = 0;
        type = EVAL_NUMBER;
    }
    else if ( text[0] == '$' ) {    // Address
        text++;
        *p++ = '0';
        *p++ = 'x';
        while (1) {
            c = *text++;
            if (c == 0) break;
            else *p++ = c;
        }
        *p++ = 0;
        type = EVAL_ADDRESS;
    }
    else if ( text[0] == '\'' || text[0] == '\"' ) {    // String
        quot = text[0];
        text++;
        while (1) {
            c = *text++;
            if (c == 0 || c == quot) break;
            else *p++ = c;
        }
        *p++ = 0;
        type = EVAL_STRING;
    }
    else {          // Label azAZ09_
        while (1) {
            c = *text++;
            if (c == 0) break;
            if (c >= 'a' && c <= 'z') *p++ = c;
            else if (c >= 'A' && c <= 'Z') *p++ = c;
            else if (c >= '0' && c <= '9') *p++ = c;
            else if (c == '_' ) *p++ = c;
            else *p++ = c;
        }
        *p++ = 0;
        type = EVAL_LABEL;
    }

    switch (type) {
        case EVAL_NUMBER:
            result->number = strtoul ( buf, NULL, 0);
            break;
        case EVAL_ADDRESS:
            result->address = strtoul ( buf, NULL, 0);
            break;
        case EVAL_LABEL:
            def = define_lookup (buf);
            if (def) return eval (def->replace, result);
            else {
                label = label_lookup (buf);
                if (label) result->label = label;
                else result->label = add_label (buf, UNDEF);
            }
            break;
        case EVAL_STRING:
            strncpy (result->string, buf, 255);
            break;
    }

    return result->type = type;
}

static void dump_eval (eval_t *eval)
{
    switch (eval->type)
    {
        case EVAL_NUMBER:
            printf ("NUMBER: %08X\n", eval->number);
            break;
        case EVAL_ADDRESS:
            if (eval->indirect) printf ("ADDRESS: [$%08X]\n", eval->address);
            else printf ("ADDRESS: $%08X\n", eval->address);
            break;
        case EVAL_LABEL:
            if (eval->indirect) printf ("LABEL: [%s] (%08X)\n", eval->label->name, eval->label->orig);
            else printf ("LABEL: %s (%08X)\n", eval->label->name, eval->label->orig);
            break;
        case EVAL_STRING:
            printf ("STRING: %s\n", eval->string);
            break;
    }
}

// ****************************************************************

// Parser.

param_t *params;
int param_num;

static void add_param (char *string)
{
    param_t * param;
    while (*string <= ' ' && *string) string++; // Skip whitespaces
    if (strlen (string) == 0) return;
    params = (param_t *)realloc (params, sizeof(param_t) * (param_num+1) );
    param = &params[param_num];
    strncpy (param->string, string, 1023);
    param_num++;
}

static void dump_param (void)
{
    int i;
    param_t *param;
    for (i=0; i<param_num; i++) {
        param = &params[i];
        printf ("%i: %s\n", i, param->string);
    } 
}

void split_param (char *op)
{
    char param[1024];
    char c, *ptr = param, quot = 0;

    memset (param, 0, sizeof(param));

    if ( params ) {         // Cleanup
        free (params);
        params = NULL;
    }
    param_num = 0;

    while (1) {
        c = *op++;
        if ( c == 0 ) break;
        else if (c==',' && !quot) {
            *ptr++ = 0;
            add_param (param);
            ptr = param;
        }
        else if ( c == '\'' || c== '\"' ) {
            if ( quot == 0 ) quot = c;
            else if (quot == c) quot = 0;
            *ptr++ = c;
        }
        else *ptr++ = c;
    }
    *ptr++ = 0;
    add_param (param);
}

static void parse_line (char **text, line& ln)
{
    int timeout = 10000;
    char c;
    char linebuf[1000], *lp = linebuf;
    char label[1000] = {0}, cmd[1000] = {0}, op[1000] = {0}, *pp;
    int parsing_cmd = 1;

    // Get actual line characters
    while (timeout--) {
        c = **text;
        (*text)++;
        if (c == 0 || c == '\n') break;
        else if (c == ';') {
            while (**text != '\n' ) (*text)++;
        }
        else *lp++ = c;
    }
    *lp++ = 0;

    //printf ("LINE: %s\n", linebuf);

    // Parse line
    lp = linebuf;
    pp = cmd;
    while ( *lp <= ' ' && *lp) lp++;
    while (1) {
        c = *lp++;
        if (c == 0) break;
        if (c == ':') {
            *pp++ = 0;              // complete parsing label
            strcpy (label, cmd);
            pp = cmd;
            parsing_cmd = 1;
            while ( *lp <= ' ' && *lp) lp++;
        }
        else if (c <= ' ' && parsing_cmd) {
            *pp++ = 0;          // complete parsing command
            pp = op;
            parsing_cmd = 0;
            while ( *lp <= ' ' && *lp) lp++;
        }
        else *pp++ = c;
    }
    *pp++ = 0;      // complete parsing operands

    strcpy (ln.label, label);
    strcpy (ln.cmd, cmd);
    strcpy (ln.op, op);
}

// ****************************************************************

void emit (unsigned char b)
{
    PRG[org++] = b;
}

static oplink optab[] = {

    // CPU Instructions
    { "BRK", opBRK }, { "RTI", opRTI }, { "RTS", opRTS },

    { "PHP", opPHP }, { "CLC", opCLC }, { "PLP", opPLP }, { "SEC", opSEC },
    { "PHA", opPHA }, { "CLI", opCLI }, { "PLA", opPLA }, { "SEI", opSEI },
    { "DEY", opDEY }, { "TYA", opTYA }, { "TAY", opTAY }, { "CLV", opCLV },
    { "INY", opINY }, { "CLD", opCLD }, { "INX", opINX }, { "SED", opSED },

    { "TXA", opTXA }, { "TXS", opTXS }, { "TAX", opTAX }, { "TSX", opTSX },
    { "DEX", opDEX }, { "NOP", opNOP },

    { "BPL", opBRA }, { "BMI", opBRA }, { "BVC", opBRA }, { "BVS", opBRA },
    { "BCC", opBRA }, { "BCS", opBRA }, { "BNE", opBRA }, { "BEQ", opBRA },

    { "JSR", opJMP }, { "JMP", opJMP }, 

    { "ORA", opALU1 }, { "AND", opALU1 }, { "EOR", opALU1 }, { "ADC", opALU1 }, 
    { "CMP", opALU1 }, { "SBC", opALU1 }, 
    { "CPX", opCPXY }, { "CPY", opCPXY }, 
    { "INC", opINCDEC }, { "DEC", opINCDEC }, 
    { "BIT", opBIT },
    { "ASL", opSHIFT }, { "LSR", opSHIFT }, { "ROL", opSHIFT }, { "ROR", opSHIFT }, 

    { "LDA", opLDST },
    { "LDX", opLDSTX },
    { "LDY", opLDSTY },
    { "STA", opLDST },
    { "STX", opLDSTX },
    { "STY", opLDSTY },

    // Directives
    { "DEFINE", opDEFINE },
    { "BYTE", opBYTE },
    { "WORD", opWORD },
    { "ORG", opORG },
    { "END", opEND },
    { "PROCESSOR", opDUMMY },

    { NULL, NULL }
};

static void cleanup (void)
{
    if ( labels ) {         // Clear labels
        free (labels);
        labels = NULL;
    }
    labels = (label_s *)malloc ( MAX_LABELS * sizeof(label_s) );
    labels_num = 0;

    if ( patchs ) {         // Clear patch table
        free (patchs);
        patchs = NULL;
    }
    patchs = (patch_s *)malloc ( MAX_PATCH * sizeof(patch_s) );
    patch_num = 0;

    if ( defines ) {        // Clear defines
        free (defines);
        defines = NULL;
    }
    defines = (define_s *)malloc ( MAX_DEFINE * sizeof(define_s) );
    define_num = 0;
}

int assemble (char *text, unsigned char *prg)
{
    line l;
    oplink *opl;
    PRG = prg;
    org = 0;
    stop = 0;
    errors = 0;

    cleanup ();

    // Add keywords
    linenum = 0;
    add_label ("A", KEYWORD);
    add_label ("X", KEYWORD);
    add_label ("Y", KEYWORD);
    opl = optab;
    while (1) {
        if ( opl->name == NULL ) break;
        else add_label (opl->name, KEYWORD);
        opl++;
    }
    linenum++;

    while (1) {
        if (*text == 0) break;
        parse_line (&text, l);

        //printf ( "%s: \'%s\' \'%s\'\n", l.label, l.cmd, l.op );

        // Add label
        if ( strlen (l.label) > 1 ) {
            add_label ( l.label, org );
        }

        // Execute command
        if ( strlen (l.cmd) > 1 ) {
            opl = optab;
            while (1) {
                if ( opl->name == NULL ) {
                    printf ("ERROR(%i): Unknown command %s\n", linenum, l.cmd);
                    break;
                }
                else if ( !_stricmp (opl->name, l.cmd) ) {
                    _strupr (l.cmd);
                    opl->handler (l.cmd, l.op);
                    break;
                }
                opl++;
            }
            if (stop) break;
        }
        linenum++;
    }

    // Patch jump/branch offsets.
    do_patch ();

#if 0
    dump_labels ();
    dump_defines ();
    dump_patches ();
#endif

    printf ( "%i error(s)\n", errors );
    return errors;
}
