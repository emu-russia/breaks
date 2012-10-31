
typedef struct ContextBoard {

    HMODULE     moduleCPU;
    void        (*Step6502) ( Context6502 * cpu );
    void        (*Debug6502) ( Context6502 * cpu, char * cmd);

    HMODULE     moduleAPU;
    void        (*Step2A03) ( Context2A03 * apu );
    void        (*Debug2A03) ( Context2A03 * apu, char * cmd);

    HMODULE     modulePPU;
    void        (*Step2C02) ( Context2C02 * ppu );
    void        (*Debug2C02) ( Context2C02 * ppu, char * cmd);

    int ResetCapacitor;

    Context6502     cpu;
    Context2A03     apu;
    Context2C02     ppu;
} ContextBoard;

void    StepBoard (ContextBoard *board);
