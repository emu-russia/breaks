// 8 KB ROM.

typedef struct Context2364
{
    unsigned char ROM[8*1024];

    int     CS;     // Active low

    int     init;   // 0 when first run (load ROM)

    // Buses
    char    ADDR[13], DATA[8];
} Context2364;

void Step2364 ( Context2364 * rom );