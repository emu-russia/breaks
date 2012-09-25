
typedef struct ContextBoard {

    HMODULE     moduleCPU;
    void        (*Step6502) ( Context6502 * cpu );

    int ResetCapacitor;

    Context6502     cpu;
} ContextBoard;

void    StepBoard (ContextBoard *board);
