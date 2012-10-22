// Ricoh 2A03 simulator.

typedef struct Context2A03 {

    int     REGSEL[12];     // register select PLA result
} Context2A03;

void Step2A03 ( Context2A03 * apu );
void Debug2A03 ( Context2A03 * apu, char *cmd );
