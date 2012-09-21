// 6502 assembler.
// There is NO experssion evaluation, I'm lazy to it )
#include <stdio.h>

/*
    Assembler syntax:

    [LABEL:]  COMMAND  [OPERAND1, OPERAND2, OPERAND3]       ; Comments

    Commands can be any 6502 instruction or one of reserved directives:
        ORG, DEFINE, BYTE, WORD
*/

typedef struct oplink {
    char    *name;
    void    (*handler) (char *cmd, char *ops);
} oplink;

typedef struct line {
    char    label[256];
    char    cmd[256];
    char    op[256];
} line;

typedef struct label_s {
    char    name[128];
    long    orig;
    int     line;
} label_s;

typedef struct patch_s {
    label_s *label;
    long    orig;
    int     branch;     // 1: relative branch, 0: absoulte jmp
} patch_s;

typedef struct define_s {
    char    name[256];
    char    replace[256];
} define_s;

static unsigned char *PRG;
static long org;        // current emit offset
static int linenum;
#define UNDEF   0xbabadaba  // undefined offset
#define KEYWORD 0xd0d0d0d0  // keyword
static long stop;

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
        if (!stricmp (label->name, name)) return label;
    }
    return NULL;
}

static label_s *add_label (char *name, long orig)
{
    label_s * label;
    label = label_lookup (name);
    if ( label == NULL ) {
        labels = (label_s *)realloc (labels, sizeof(label_s) * (labels_num+1) );
        label = &labels[labels_num];
        labels_num++;
        strcpy (label->name, name);
        label->orig = orig;
        label->line = linenum;
    }
    else {
        if ( label->orig == KEYWORD ) printf ("ERROR(%i): Reserved keyword \'%s\'\n", linenum, name);
        else if (orig != UNDEF && label->orig != UNDEF ) printf ("ERROR(%i): label \'%s\' already defined in line %i\n", linenum, name, label->line);
        else label->orig = orig;
    }
    return label;
}

static void dump_labels (void)
{
    int i;
    label_s * label;
    printf ("\nLABELS:\n");
    for (i=0; i<labels_num; i++) {
        label = &labels[i];
        if (label->orig == KEYWORD) continue;
        printf ("%i: $%08X = %s\n", i+1, label->orig, label->name);
    }
}

// Patch management.
//

// Defines management.
//

static define_s * define_lookup (char *name)
{
    int i;
    define_s * def;
    for (i=0; i<define_num; i++) {
        def = &defines[i];
        if (!stricmp (def->name, name)) return def;
    }
    return NULL;
}

static define_s *add_define (char *name, char *replace)
{
    define_s * def;
    def = define_lookup (name);
    if ( def ) {
        strcpy (def->replace, replace);
    }
    else {
        defines = (define_s *)realloc ( sizeof(define_s) * (define_num+1) );
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
    printf ("\nDEFINES:\n");
    for (i=0; i<define_num; i++) {
        def = &defines[i];
        printf ("%i: %s = %s\n", i+1, def->name, def->replace);
    }
}

// ****************************************************************
// Evaluate expression

#define EVAL_WTF        0
#define EVAL_NUMBER     1       // #$12
#define EVAL_ADDRESS    2       // $aabb
#define EVAL_LABEL      3       // BEGIN
#define EVAL_STRING     4       // "Hello", 'Hello'

typedef struct eval_t {
    int     type;
    long    number;
    long    address;
    char    string[256];
    label_s *label;
} eval_t;

static int eval (char *text, eval_t *result)
{
    char buf[1024], *p = buf, c, quot;
    int type = EVAL_WTF;
    define_s * def;
    label_s * label;

    if ( text[0] == '#' ) {         // Number
        text++;
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
            printf ("ADDRESS: $%08X\n", eval->address);
            break;
        case EVAL_LABEL:
            printf ("LABEL: %s (%08X)\n", eval->label->name, eval->label->orig);
            break;
        case EVAL_STRING:
            printf ("STRING: %s\n", eval->string);
            break;
    }
}

// ****************************************************************

// Parser.

typedef struct param_t {
    char    string[1024];
} param_t;

static  param_t *params;
static  int     param_num;

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

static void split_param (char *op)
{
    char param[1024];
    char c, *ptr = param;

    memset (param, 0, sizeof(param));

    if ( params ) {         // Cleanup
        free (params);
        params = NULL;
    }
    param_num = 0;

    while (1) {
        c = *op++;
        if ( c == 0 ) break;
        else if (c==',') {
            *ptr++ = 0;
            add_param (param);
            ptr = param;
        }
        else *ptr++ = c;
    }
    *ptr++ = 0;
    add_param (param);
}

static line *parse_line (char **text)
{
    line ln;
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

    //printf ("%s\n", linebuf);

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
    return &ln;
}

// ****************************************************************

static void emit (unsigned char b)
{
    PRG[org++] = b;
}

#include "ASMOPS.c"

static oplink optab[] = {

    // CPU Instructions
    { "BRK", opBRK },
    { "RTI", opRTI },
    { "RTS", opRTS },

    { "PHP", opPHP },
    { "CLC", opCLC },
    { "PLP", opPLP },
    { "SEC", opSEC },
    { "PHA", opPHA },
    { "CLI", opCLI },
    { "PLA", opPLA },
    { "SEI", opSEI },
    { "DEY", opDEY },
    { "TYA", opTYA },
    { "TAY", opTAY },
    { "CLV", opCLV },
    { "INY", opINY },
    { "CLD", opCLD },
    { "INX", opINX },
    { "SED", opSED },

    { "TXA", opTXA },
    { "TXS", opTXS },
    { "TAX", opTAX },
    { "TSX", opTSX },
    { "DEX", opDEX },
    { "NOP", opNOP },

    { "LDX", opLDX },

    // Directives
    { "END", opEND },

    { NULL, NULL }
};

static void cleanup (void)
{
    if ( labels ) {         // Clear labels
        free (labels);
        labels = NULL;
    }
    labels_num = 0;

    if ( patchs ) {         // Clear patch table
        free (patchs);
        patchs = NULL;
    }
    patch_num = 0;

    if ( defines ) {        // Clear defines
        free (defines);
        defines = NULL;
    }
    define_num = 0;
}

void assemble (char *text, unsigned char *prg)
{
    line *l;
    oplink *opl;
    PRG = prg;
    org = 0;
    linenum = 1;
    stop = 0;

    cleanup ();

    // Add keywords
    add_label ("A", KEYWORD);
    add_label ("X", KEYWORD);
    add_label ("Y", KEYWORD);
    opl = optab;
    while (1) {
        if ( opl->name == NULL ) break;
        else add_label (opl->name, KEYWORD);
        opl++;
    }

    while (1) {
        if (*text == 0) break;
        l = parse_line (&text);
        if ( strlen (l->cmd) > 1 ) {
            opl = optab;
            while (1) {
                if ( opl->name == NULL ) {
                    printf ("ERROR(%i): Unknown command %s\n", linenum, l->cmd);
                    break;
                }
                else if ( !stricmp (opl->name, l->cmd) ) {
                    strupr (l->cmd);
                    opl->handler (l->cmd, l->op);
                    break;
                }
                opl++;
            }
            if (stop) break;

            //printf ( "%i: %s: %s %s\n", linenum, l->label, l->cmd, l->op );
        }
        linenum++;
    }

    dump_labels ();
    dump_defines ();
}
