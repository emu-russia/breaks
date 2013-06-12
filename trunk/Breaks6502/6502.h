typedef struct M6502 {
    char nNMI;
    char nIRQ;
    char PHI1;
    char RDY;
    char nRES;
    char PHI2;
    char SO;
    char PHI0;
    char RW;
    unsigned char DATA;
    unsigned short ADDR;
    char SYNC;
} M6502;

void Step6502 (M6502 *cpu);
