# Introduction #

The following common code snippets demonstrates, how to simulate any chip design, down to its transistor level.

# Context #

This is huge structure, holding all internal state of simulated chip.

It has two types of variables: **control lines** and **latches**.

Control lines are just current level of some internal wire or external input/output pad. Analog I/O simulated by floating-point variables.

Latches are representing current state of static (floating base capacity) or dynamic (bistable) latches.

Example 8 KB ROM memory device context:
```
typedef struct ContextROM
{
    unsigned char ROM[8*1024];    // array of latches

    int     CS;     // Chip Select (Active low)

    int     init;   // 0 when first run (load ROM from file)

    // Buses
    char    ADDR[13], DATA[8];
} ContextROM;
```

# Propagation #

To run simulation you simply need to call Step().

Internal Step() procedures will simulate chip blocks one-by-one, according to their propagation delay and internal context.

Example 8 KB ROM simulation.
```
void StepROM ( ContextROM * rom )
{
    unsigned char data = 0;
    unsigned short addr = 0;
    int i;

    if (!rom->init) {
        LoadROM (rom);    // load from file
        rom->init = 1;
    }

    if (rom->CS == 0) {  // Read data when chip selected (active low)
        for (i=0; i<13; i++) addr |= (rom->ADDR[i] << i);
        data = rom->ROM[addr & 0x1fff];
    }

    for (i=0; i<8; i++) {   // put data onto data bus
        rom->DATA[i] = (data >> i) & 1;
    }
}
```