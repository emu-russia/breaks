
typedef struct ContextBoard {

    HMODULE     moduleCPU;
    void        (*Step6502) ( Context6502 * cpu );
    void        (*Debug6502) ( Context6502 * cpu, char * cmd);

    int ResetCapacitor;

    Context6502     cpu;
} ContextBoard;

void    StepBoard (ContextBoard *board);
