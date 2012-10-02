
unsigned long packreg ( char *reg, int bits );
void unpackreg (char *reg, unsigned char val, int bits);

extern  int DebugConsoleOpened;

void    OpenDebugConsole (void);
void    CloseDebugConsole (void);
void    DPrintf (char *fmt, ...);

char    *PLAName (int line);

char    *QuickDisa (unsigned char instr);