#pragma once

typedef unsigned char    u8;
typedef unsigned short   u16;
typedef unsigned long    u32;

typedef struct number_t
{
    u32     value;
    u32     xmask;
    u32     zmask;
    int     lsb, msb, len;
} number_t;

typedef struct symbol_t
{
    char    rawstring[256];
    number_t    num;
    u32     hash;
    int     type;
} symbol_t;

typedef struct token_t
{
    int     type;
    char    rawstring[256];
    symbol_t * sym;
    number_t num;
    int     op;         // operation
} token_t;

typedef struct node_struct_t
{
    struct node_struct_t  *lvalue;
    struct node_struct_t  *rvalue;
    token_t token;
    int     depth;
} node_t;

int     breaksvm_init (void);
void    breaksvm_shutdown (void);
int     breaksvm_load (char *filename);
void    breaksvm_input_reg (char *input_name, void (*callback)(unsigned char *reg));
void    breaksvm_output_reg (char *output_name, void (*callback)(unsigned char *reg));
void    breaksvm_run (int timeout);
int     breaksvm_status (void);

