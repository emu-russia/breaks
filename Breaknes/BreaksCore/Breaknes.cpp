#include "pch.h"

using namespace BaseLogic;

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

void PackUnpackTest()
{
	uint8_t val = 0xa5;
	TriState n[8];

	Unpack(val, n);
	//Dump(n, "n");

	uint8_t val2 = Pack(n);
	if (val != val2)
	{
		throw "Pack/Unpack failed!";
	}
}

int main()
{
	//PackUnpackTest();
	//DumpDecoderStates();

	M6502CoreUnitTest::UnitTest unit_test;

	unit_test.PC_UnitTest();
	unit_test.ALU_UnitTest();
	return 0;

	Breaknes::Famicom* fami = new Breaknes::Famicom;

	// Simulate reset

	printf("Before Reset:\n");

	fami->reset();

	// Continue executing the instructions in the usual way.

	printf("After Reset:\n");

	size_t maxHalfcycles = 100;         // DEBUG

	int ts1 = GetTimeStamp();

	for (size_t n = 0; n < maxHalfcycles; n++)
	{
		fami->sim();
	}

	int ts2 = GetTimeStamp();

	delete fami;

	printf("Done in %d microseconds!\n", ts2 - ts1);
}
