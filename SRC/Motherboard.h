
typedef struct ContextBoard {
    int ResetCapacitor;

    ContextAPU  apu;
    ContextPPU  ppu;
} ContextBoard;

void    StepBoard (ContextBoard *board);
