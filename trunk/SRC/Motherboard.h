
typedef struct ContextBoard {
    int ResetCapacitor;

    ContextM6502 cpu;
    ContextPPU   ppu;
} ContextBoard;

void    StepBoard (ContextBoard *board);
