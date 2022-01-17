#include "pch.h"
#include "../Breaks6502/M6502Core/alu.h"

using namespace BaseLogic;
using namespace M6502Core;

static void ResetInputs(TriState inputs[], ALU_Input op)
{
	inputs[(size_t)ALU_Input::PHI2] = TriState::Zero;

	inputs[(size_t)ALU_Input::NDB_ADD] = TriState::Zero;
	inputs[(size_t)ALU_Input::DB_ADD] = TriState::Zero;
	inputs[(size_t)ALU_Input::Z_ADD] = TriState::Zero;
	inputs[(size_t)ALU_Input::SB_ADD] = TriState::Zero;
	inputs[(size_t)ALU_Input::ADL_ADD] = TriState::Zero;

	inputs[(size_t)ALU_Input::ADD_SB06] = TriState::Zero;
	inputs[(size_t)ALU_Input::ADD_SB7] = TriState::Zero;
	inputs[(size_t)ALU_Input::ADD_ADL] = TriState::Zero;

	inputs[(size_t)ALU_Input::ANDS] = TriState::Zero;
	inputs[(size_t)ALU_Input::EORS] = TriState::Zero;
	inputs[(size_t)ALU_Input::ORS] = TriState::Zero;
	inputs[(size_t)ALU_Input::SRS] = TriState::Zero;
	inputs[(size_t)ALU_Input::SUMS] = TriState::Zero;

	switch (op)
	{
		case ALU_Input::ANDS:
			inputs[(size_t)ALU_Input::ANDS] = TriState::One;
			break;
		case ALU_Input::EORS:
			inputs[(size_t)ALU_Input::EORS] = TriState::One;
			break;
		case ALU_Input::ORS:
			inputs[(size_t)ALU_Input::ORS] = TriState::One;
			break;
		case ALU_Input::SRS:
			inputs[(size_t)ALU_Input::SRS] = TriState::One;
			break;
		case ALU_Input::SUMS:
			inputs[(size_t)ALU_Input::SUMS] = TriState::One;
			break;
	}

	inputs[(size_t)ALU_Input::SB_AC] = TriState::Zero;
	inputs[(size_t)ALU_Input::AC_SB] = TriState::Zero;
	inputs[(size_t)ALU_Input::AC_DB] = TriState::Zero;
	inputs[(size_t)ALU_Input::SB_DB] = TriState::Zero;
	inputs[(size_t)ALU_Input::SB_ADH] = TriState::Zero;

	inputs[(size_t)ALU_Input::n_ACIN] = TriState::One;
	inputs[(size_t)ALU_Input::n_DAA] = TriState::One;
	inputs[(size_t)ALU_Input::n_DSA] = TriState::One;
}

static int TestCompute(uint8_t a, uint8_t b, uint8_t expected, ALU_Input op, bool bcd, bool carry)
{
	ALU alu;
	TriState inputs[(size_t)ALU_Input::Max];

	// The value a is loaded on the SB bus (SB/ADD) and the value b is loaded on the DB bus (DB/ADD).

	TriState SB[8];
	TriState DB[8];
	TriState ADL[8];
	TriState ADH[8];

	bool SB_Dirty[8];
	bool DB_Dirty[8];
	bool ADL_Dirty[8];
	bool ADH_Dirty[8];

	for (size_t n = 0; n < 8; n++)
	{
		SB[n] = (a & (1 << n)) != 0 ? TriState::One : TriState::Zero;
		DB[n] = (b & (1 << n)) != 0 ? TriState::One : TriState::Zero;
		ADL[n] = TriState::Z;
		ADH[n] = TriState::Z;
		SB_Dirty[n] = false;
		DB_Dirty[n] = false;
		ADL_Dirty[n] = false;
		ADH_Dirty[n] = false;
	}

	// Load

	ResetInputs(inputs, op);
	inputs[(size_t)ALU_Input::SB_ADD] = TriState::One;
	inputs[(size_t)ALU_Input::DB_ADD] = TriState::One;

	alu.sim_Load(inputs, SB, DB, ADL, SB_Dirty);

	uint8_t ai = alu.getAI();
	uint8_t bi = alu.getBI();

	if (ai != a)
	{
		printf("AI != 0x%02X\n", a);
		return -1;
	}

	if (bi != b)
	{
		printf("BI != 0x%02X\n", b);
		return -1;
	}

	// Compute

	ResetInputs(inputs, op);
	inputs[(size_t)ALU_Input::PHI2] = TriState::One;
	inputs[(size_t)ALU_Input::ADD_SB06] = TriState::One;
	inputs[(size_t)ALU_Input::ADD_SB7] = TriState::One;
	inputs[(size_t)ALU_Input::n_ACIN] = carry ? TriState::Zero : TriState::One;
	inputs[(size_t)ALU_Input::n_DAA] = bcd ? TriState::Zero : TriState::One;

	alu.sim(inputs, SB, DB, ADL, ADH, SB_Dirty, DB_Dirty, ADL_Dirty, ADH_Dirty);

	// Store

	ResetInputs(inputs, op);
	inputs[(size_t)ALU_Input::SB_AC] = TriState::One;
	inputs[(size_t)ALU_Input::AC_DB] = TriState::One;

	alu.sim_Store(inputs, SB, DB, ADH, SB_Dirty, DB_Dirty, ADH_Dirty);

	// Check

	uint8_t ac = Pack(DB);

	const char* op_str = "";

	switch (op)
	{
		case ALU_Input::ANDS:
			op_str = "&";
			break;
		case ALU_Input::EORS:
			op_str = "^";
			break;
		case ALU_Input::ORS:
			op_str = "|";
			break;
		case ALU_Input::SRS:
			op_str = ">>";
			break;
		case ALU_Input::SUMS:
			op_str = "+";
			break;
	}

	bool pass = ac == expected;

	if (!pass)
	{
		printf("Test 0x%02X %s 0x%02X = 0x%02X, ACR: %d, AVR: %d\n", a, op_str, b, ac,
			alu.getACR() == TriState::One ? 1 : 0,
			alu.getAVR() == TriState::One ? 1 : 0);
	}

	return pass ? 0 : -1;
}

void ALU_UnitTest()
{
	// SUMS No carry

	printf("SUMS No carry: ");
	for (size_t a = 0; a < 0x100; a++)
	{
		for (size_t b = 0; b < 0x100; b++)
		{
			int res = TestCompute((uint8_t)a, (uint8_t)b, (uint8_t)(a + b), ALU_Input::SUMS, false, false);
			if (res != 0)
			{
				printf("Failed!\n");
				return;
			}
		}
	}
	printf("OK!\n");

	// SUMS Carry

	printf("SUMS Carry: ");
	for (size_t a = 0; a < 0x100; a++)
	{
		for (size_t b = 0; b < 0x100; b++)
		{
			int res = TestCompute((uint8_t)a, (uint8_t)b, (uint8_t)(a + b + 1), ALU_Input::SUMS, false, true);
			if (res != 0)
			{
				printf("Failed!\n");
				return;
			}
		}
	}
	printf("OK!\n");

	printf("ALU_UnitTest All OK!\n");
}
