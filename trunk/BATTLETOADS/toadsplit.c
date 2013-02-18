/* Split BTOADS.NES to NESHDR.BIN + ROMBANK0...n.BIN */
#include <stdio.h>

int main (int argc, char **argv)
{
    int i;
    char *ines, rom[256];
    FILE *f;

    /* Load NES image into memory mapped buffer. */
    ines = (char *)malloc (256*1024+16);
    f = fopen ("BTOADS.NES", "rb");
    fread (ines, 1, 256*1024+16, f);
    fclose (f);

    /* Save NES header */
    f = fopen ("NESHDR.BIN", "wb");
    fwrite (ines, 1, 16, f);
    fclose (f);
    ines += 16; /* Adjust pointer to ROM banks. */

    for (i=0; i<8; i++, ines+=32768)
    {
        sprintf (rom, "ROMBANK%i.BIN", i);
        f = fopen (rom, "wb");
        fwrite (ines, 1, 32768, f);
        fclose (f);
    }
}
