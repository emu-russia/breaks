#include "pch.h"

#ifdef _WINDOWS
static int GetTimeStamp()
{
	FILETIME ft;
	GetSystemTimeAsFileTime(&ft);
	unsigned long long tt = ft.dwHighDateTime;
	tt <<= 32;
	tt |= ft.dwLowDateTime;
	tt /= 10;
	tt -= 11644473600000000ULL;
	return (int)tt;
}
#endif

int main()
{
	Breaknes::Famicom* fami = new Breaknes::Famicom;

	// Simulate reset

	printf("Before Reset:\n");

	fami->reset();

	// Continue executing the instructions in the usual way.

	printf("After Reset:\n");

	size_t maxHalfcycles = 16;         // DEBUG: Execute several cycles sufficient to execute at least one 6502 instruction.

	int ts1 = GetTimeStamp();

	for (size_t n = 0; n < maxHalfcycles; n++)
	{
		fami->sim();
	}

	int ts2 = GetTimeStamp();

	delete fami;

	printf("Done in %d microseconds!\n", ts2 - ts1);
}
