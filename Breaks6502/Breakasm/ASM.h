
#pragma once

#define MAX_LABELS  1024
#define MAX_PATCH   1024
#define MAX_DEFINE  1024

#define UNDEF   0xbabadaba  // undefined offset
#define KEYWORD 0xd0d0d0d0  // keyword

typedef struct oplink {
    const char* name;
    void    (*handler) (char* cmd, char* ops);
} oplink;

typedef struct line {
    char    label[256];
    char    cmd[256];
    char    op[1024];
} line;

typedef struct label_s {
    char    name[128];
    long    orig;
    int     line;
} label_s;

typedef struct patch_s {
    label_s* label;
    long    orig;
    int     branch;     // 1: relative branch, 0: absolute jmp
    int     line;
} patch_s;

typedef struct define_s {
    char    name[256];
    char    replace[256];
} define_s;


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
    label_s* label;
    int     indirect;
} eval_t;

typedef struct param_t {
    char    string[1024];
} param_t;

extern long org;        // current emit offset
extern int linenum;
extern long stop;
extern long errors;

extern param_t* params;
extern int param_num;

label_s* add_label(const char* name, long orig);
void add_patch(label_s* label, long orig, int branch, int line);
define_s* add_define(char* name, char* replace);
int eval(char* text, eval_t* result);
void split_param(char* op);
void emit(unsigned char b);

int assemble (char *text, unsigned char *prg);
