// 6502 assembler.
#include <stdio.h>

typedef struct oplink {
    char    *name;
    void    (*handler) (char *ops);
} oplink;

typedef struct line {
    char    label[256];
    char    cmd[256];
    char    op[256];
} line;

typedef struct label_s {
    char    name[128];
    long    orig;
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

static  label_s *labels;    // name labels
static  int labels_num;

static  patch_s *patchs;    // patch history
static  int patch_num;

static  define_s *defines;  // definitions
static  int define_num;

// ****************************************************************

// Labels management.
//

// Patch management.
//

// Defines management.
//

// ****************************************************************

// Parsers.

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

static void emit (unsigned char b)
{
    PRG[org++] = b;
}

#include "ASMOPS.c"

static oplink optab[] = {

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
    int linenum = 0;
    line *l;
    oplink *opl;
    PRG = prg;
    org = 0;

    cleanup ();

    while (1) {
        if (*text == 0) break;
        l = parse_line (&text);
        if ( strlen (l->cmd) > 1 ) {
            opl = optab;
            while (1) {
                if ( opl->name == NULL ) {
                    printf ("ERROR(%i): Unknown command %s\n", linenum+1, l->cmd);
                    break;
                }
                else if ( !stricmp (opl->name, l->cmd) ) {
                    opl->handler (l->op);
                    break;
                }
                opl++;
            }

            //printf ( "%i: %s: %s %s\n", linenum+1, l->label, l->cmd, l->op );
        }
        linenum++;
    }
}
