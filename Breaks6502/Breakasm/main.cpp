// The main file with the entry point.

#include "pch.h"

#define PRG_SIZE 0x10000

void Usage()
{
	printf("Use: Breakasm <source.asm> <output.prg>\n");
	printf("Example: Breakasm Test.asm Test.prg\n");
}

int main(int argc, char** argv)
{
	FILE* f;

	if (argc < 3)
	{
		Usage();
		return -1;
	}

	uint8_t* prg = new uint8_t[PRG_SIZE];
	memset(prg, 0, PRG_SIZE);

	// Load Source

	f = fopen(argv[1], "rt");
	if (!f)
	{
		delete[] prg;
		printf("ERROR: Unable to read the source code.\n");
		return -100;
	}

	// One more byte of memory is allocated to complete the text with the null character (END).

	fseek(f, 0, SEEK_END);
	long size = ftell(f) + 1;
	fseek(f, 0, SEEK_SET);

	char* text = new char[size];
	memset(text, 0, size);

	size_t readSize = fread(text, 1, size, f);
	fclose(f);
	if (readSize >= size)
	{
		delete[] text;
		delete[] prg;
		printf("ERROR: Error loading the source file.\n");
		return -101;
	}

	// Assemble

	int err_count = assemble(text, prg);
	if (err_count != 0)
	{
		delete[] text;
		delete[] prg;
		return -200;
	}

	// Save PRG

	f = fopen(argv[2], "wb");
	if (!f)
	{
		delete[] text;
		delete[] prg;
		printf("ERROR: Failed to save the PRG.\n");
		return -300;
	}

	fwrite(prg, 1, PRG_SIZE, f);
	
	delete[] text;
	delete[] prg;

	fclose(f);

	return 0;
}
