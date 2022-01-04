#include "pch.h"

int main()
{
    Breaknes::Famicom* fami = new Breaknes::Famicom;

    size_t maxHalfcycles = 10000;         // DEBUG

    for (size_t n = 0; n < maxHalfcycles; n++)
    {
        fami->sim();
    }

    delete fami;

    printf("Done!\n");
}
