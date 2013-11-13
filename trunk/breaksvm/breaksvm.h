#pragma once

typedef unsigned char    u8;
typedef unsigned short   u16;
typedef unsigned long    u32;

int     breaksvm_init (void);
void    breaksvm_shutdown (void);
int     breaksvm_load (char *filename);
void    breaksvm_input_real (char *input_name, void (*callback)(float *real));
void    breaksvm_input_reg (char *input_name, void (*callback)(unsigned char *reg));
void    breaksvm_output_real (char *output_name, void (*callback)(float *real));
void    breaksvm_output_reg (char *output_name, void (*callback)(unsigned char *reg));
void    breaksvm_run (int timeout);
int     breaksvm_status (void);

