#include <stdio.h>
#include "Breaks6502.h"
#include "Breaks6502Private.h"

#include "ROM2364.h"
#include "ASM.h"

Context6502 cpu;

// Timing register
// Imitate behaviour of long CPU instruction.
void TimeRegTest (void)
{
    int r = 20, TR;
    int sync = 2;

    while (r--)
    {
        cpu.PHI1 = BIT(~cpu.PHI0);
        cpu.PHI2 = BIT(cpu.PHI0);
        TR = TcountRegister (&cpu, sync > 0, 1, 0);
        printf ( "%02X ", TR );
        cpu.PHI0 ^= 1;
        sync--;
    }

    // Output should be like: 0F 0F 0E 0E 0D 0D 0B 0B 07 07 0F 0F 0F 0F 0F 0F 0F 0F 0F 0F
}

// http://visual6502.org/wiki/index.php?title=6502DecimalMode
void ALUTest (void)
{
}

void GeneralExecutionTest (i)
{
    // Execute given amount of clock iterations
    while (i--) {
        Step6502 ( &cpu );
        cpu.PHI0 ^= 1;
    }
}

// Execute some clocks to reset 6502
void Reset (void)
{
    int r = 100;
    while (r--) {
        Step6502 ( &cpu );
        cpu.PHI0 ^= 1;
    }
}

void *FileLoad(char *filename, long *size, char *mode)
{
    FILE*   f;
    char*   buffer;
    long     filesize;

    if(size) *size = 0;

    f = fopen(filename, mode);
    if(f == NULL) return NULL;

    fseek(f, 0, SEEK_END);
    filesize = ftell(f);
    fseek(f, 0, SEEK_SET);

    buffer = (char*)malloc(filesize + 1);
    if(buffer == NULL)
    {
        fclose(f);
        return NULL;
    }
    memset(buffer, 0, filesize + 1);

    fread(buffer, 1, filesize, f);
    fclose(f);
    if(size) *size = filesize;    
    return buffer;
}

int FileSave (char *filename, void *data, long size, char *mode)
{
    FILE *f = fopen(filename, mode);
    if(f == NULL) return 0;

    fwrite(data, size, 1, f);
    fclose(f);
    return 1;
}

main ()
{
/*
    // Initial conditions
    memset (&cpu, 0, sizeof(cpu));

    TimeRegTest ();
    //ALUTest ();
    //GeneralExecutionTest ( 10000 );
*/

    unsigned char prg[16*1024], *text;
    memset (prg, 0, sizeof(prg));
    text = FileLoad ("Test.asm", NULL, "rt" );
    assemble ( text, prg );
    FileSave ("prg.bin", prg, sizeof(prg), "wb");
}