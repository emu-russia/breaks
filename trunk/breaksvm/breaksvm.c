#include "breaksvm.h"
//#include <pthread.h>
#include <stdio.h>

// ------------------------------------------------------------------------------------
// verilog tokenizer

static char * keywords[] = {
    "always",       "for",          "or",           "tri",
    "and",          "if",           "output",       "triand",
    "begin",        "inout",        "parameter",    "trior",
    "buf",          "input",        "posedge",      "trireg",
    "bufif0",       "integer",      "reg",          "vectored",
    "bufif1",       "module",       "scalared",     "wand",
    "case",         "nand",                         "while",
    "casex",        "negedge",                      "wire",
    "casez",        "nor",                          "wor",
    "else",         "not",                          "xnor",
    "end",          "notif0",                       "xor",
    "endcase",      "notif1",
    "endmodule",
};

// ------------------------------------------------------------------------------------
// verilog syntax tree parser

//typedef struct wire_t
//{
//} wire_t;

// ------------------------------------------------------------------------------------
// EDIF 2 0 0 nodelist generator

// ------------------------------------------------------------------------------------
// nodelist JIT-compiler

// ------------------------------------------------------------------------------------
// simulator and standard cells

// ------------------------------------------------------------------------------------
// external API

int breaksvm_init (void)
{
}

void breaksvm_shutdown (void)
{
}

int breaksvm_load (char *filename)
{
}

void breaksvm_input_real (char *input_name, void (*callback)(float *real))
{
}

void breaksvm_input_reg (char *input_name, void (*callback)(unsigned char *reg))
{
}

void breaksvm_output_real (char *output_name, void (*callback)(float *real))
{
}

void breaksvm_output_reg (char *output_name, void (*callback)(unsigned char *reg))
{
}

void breaksvm_run (int timeout)
{
}

int breaksvm_status (void)
{
}

