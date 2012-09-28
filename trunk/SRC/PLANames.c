#include <stdio.h>

char * PLAName (int line)
{
    static char def[32];

    switch (line) {
        case 0: return "0";

        default:
            sprintf (def, "%i", line);
            return def;
    }
}
