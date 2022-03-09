#include "pch.h"
#include "../../Breaks6502/M6502Core/pc.h"

using namespace BaseLogic;
using namespace M6502Core;

namespace M6502CoreUnitTest
{
	UnitTest::UnitTest()
	{
		core = new M6502(false, false);
	}

	UnitTest::~UnitTest()
	{
		delete core;
	}

	void UnitTest::ResetPcInputs()
	{
		core->wire.PHI2 = TriState::Zero;

		core->cmd.ADL_PCL = 0;
		core->cmd.PCL_PCL = 0;
		core->cmd.PCL_ADL = 0;
		core->cmd.PCL_DB = 0;
		core->cmd.ADH_PCH = 0;
		core->cmd.PCH_PCH = 0;
		core->cmd.PCH_ADH = 0;
		core->cmd.PCH_DB = 0;

		core->wire.n_1PC = TriState::One;
	}

	void UnitTest::PC_Test(uint16_t initial_pc, uint16_t expected_pc, bool inc, const char* test_name)
	{
		core->DB = 0;
		core->ADL = 0;
		core->ADH = 0;
		core->DB_Dirty = false;
		core->ADL_Dirty = false;
		core->ADH_Dirty = false;

		// Load

		core->ADL = (uint8_t)(initial_pc & 0xff);
		core->ADH = (uint8_t)(initial_pc >> 8);

		ResetPcInputs();
		core->cmd.ADL_PCL = 1;
		core->cmd.ADH_PCH = 1;
		core->pc->sim_Load();

		ResetPcInputs();
		core->pc->sim_Load();

		// Increment?

		ResetPcInputs();
		core->wire.PHI2 = TriState::Zero;
		core->cmd.PCL_PCL = 1;
		core->cmd.PCH_PCH = 1;
		if (inc)
		{
			core->wire.n_1PC = TriState::Zero;
		}
		core->pc->sim();

		ResetPcInputs();
		core->wire.PHI2 = TriState::One;
		if (inc)
		{
			core->wire.n_1PC = TriState::Zero;
		}
		core->pc->sim();

		// Store

		ResetPcInputs();
		core->cmd.PCL_PCL = 1;
		core->cmd.PCH_PCH = 1;
		core->pc->sim_Store();

		ResetPcInputs();
		core->cmd.PCL_ADL = 1;
		core->cmd.PCH_ADH = 1;
		core->pc->sim_Store();

		// Check bus value

		uint8_t pcl_from_bus = core->ADL;
		uint8_t pch_from_bus = core->ADH;
		uint16_t pc_from_bus = ((uint16_t)pch_from_bus << 8) | pcl_from_bus;

		if (pc_from_bus != expected_pc)
		{
			printf("`%s` test failed! PC from bus (0x%04X) != Expected PC (0x%04X)\n", test_name, pc_from_bus, expected_pc);
			return;
		}

		// Check direct values

		uint8_t PCH = core->pc->getPCH();
		uint8_t PCL = core->pc->getPCL();
		uint16_t PC = ((uint16_t)PCH << 8) | PCL;

		if (PC != expected_pc)
		{
			printf("`%s` test failed! PC (0x%04X) != Expected PC (0x%04X)\n", test_name, PC, expected_pc);
			return;
		}

		printf("`%s` test pass!\n", test_name);
	}

	void UnitTest::PC_UnitTest()
	{
		PC_Test(0x0000, 0x0000, false, "PC = 0x0000");
		PC_Test(0xA5A5, 0xA5A5, false, "PC = 0xA5A5");
		PC_Test(0x5A5A, 0x5A5A, false, "PC = 0x5A5A");
		PC_Test(0xFFFE, 0xFFFE, false, "PC = 0xFFFE");
		PC_Test(0xFFFF, 0xFFFF, false, "PC = 0xFFFF");
		PC_Test(0x0000, 0x0001, true, "PC = 0x0000 -> Increment -> Check PC = 0x0001");
		PC_Test(0xA5A5, 0xA5A6, true, "PC = 0xA5A5 -> Increment -> Check PC = 0xA5A6");
		PC_Test(0x5A5A, 0x5A5B, true, "PC = 0x5A5A -> Increment -> Check PC = 0x5A5B");
		PC_Test(0xFFFE, 0xFFFF, true, "PC = 0xFFFE -> Increment -> Check PC = 0xFFFF");
		PC_Test(0xFFFF, 0x0000, true, "PC = 0xFFFF -> Increment -> Check PC = 0x0000");
	}

	void UnitTest::ResetALUInputs(ALU_Operation op)
	{
		core->wire.PHI2 = TriState::Zero;

		core->cmd.NDB_ADD = 0;
		core->cmd.DB_ADD = 0;
		core->cmd.Z_ADD = 0;
		core->cmd.SB_ADD = 0;
		core->cmd.ADL_ADD = 0;

		core->cmd.ADD_SB06 = 0;
		core->cmd.ADD_SB7 = 0;
		core->cmd.ADD_ADL = 0;

		core->cmd.ANDS = 0;
		core->cmd.EORS = 0;
		core->cmd.ORS = 0;
		core->cmd.SRS = 0;
		core->cmd.SUMS = 0;

		switch (op)
		{
			case ALU_Operation::ANDS:
				core->cmd.ANDS = 1;
				break;
			case ALU_Operation::EORS:
				core->cmd.EORS = 1;
				break;
			case ALU_Operation::ORS:
				core->cmd.ORS = 1;
				break;
			case ALU_Operation::SRS:
				core->cmd.SRS = 1;
				break;
			case ALU_Operation::SUMS:
				core->cmd.SUMS = 1;
				break;
		}

		core->cmd.SB_AC = 1;
		core->cmd.AC_SB = 1;
		core->cmd.AC_DB = 1;
		core->cmd.SB_DB = 1;
		core->cmd.SB_ADH = 1;

		core->cmd.n_ACIN = 1;
		core->cmd.n_DAA = 1;
		core->cmd.n_DSA = 1;
	}

	size_t UnitTest::BCD_Add(size_t a, size_t b, bool carry_in)
	{
		// BCD addition looks something like this. 

		size_t low = (a & 0xf) + (b & 0xf);
		if (carry_in) low++;
		bool low_carry = low > 9;
		if (low_carry) low += 6;
		size_t hi = ((a >> 4) & 0xf) + ((b >> 4) & 0xf);
		if (low_carry) hi++;
		bool hi_carry = hi > 9;
		if (hi_carry) hi += 6;
		size_t bcd_res = (low & 0xf) | (hi << 4);

		return bcd_res;
	}

	int UnitTest::TestCompute(uint8_t a, uint8_t b, uint8_t expected, ALU_Operation op, bool bcd, bool carry)
	{
		// The value a is loaded on the SB bus (SB/ADD) and the value b is loaded on the DB bus (DB/ADD).

		core->SB = a;
		core->DB = b;
		core->SB_Dirty = false;
		core->DB_Dirty = false;

		// Load

		ResetALUInputs(op);
		core->cmd.SB_ADD = 1;
		core->cmd.DB_ADD = 1;
		core->alu->sim_Load();

		uint8_t ai = core->alu->getAI();
		uint8_t bi = core->alu->getBI();

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

		ResetALUInputs(op);
		core->wire.PHI2 = TriState::One;
		core->cmd.n_ACIN = carry ? 0 : 1;
		core->cmd.n_DAA = bcd ? 0 : 1;
		core->alu->sim();

		ResetALUInputs(op);
		core->cmd.ADD_SB06 = 1;
		core->cmd.ADD_SB7 = 1;
		core->SB_Dirty = false;
		core->alu->sim_StoreADD();

		ResetALUInputs(op);
		core->wire.PHI2 = TriState::Zero;
		core->cmd.SB_AC = 1;
		core->cmd.n_ACIN = carry ? 0 : 1;
		core->cmd.n_DAA = bcd ? 0 : 1;
		core->alu->sim();

		// Store

		ResetALUInputs(op);
		core->cmd.AC_DB = 1;
		core->alu->sim_StoreAC();

		// Check

		uint8_t ac = core->DB;

		const char* op_str = "";

		switch (op)
		{
			case ALU_Operation::ANDS:
				op_str = "&";
				break;
			case ALU_Operation::EORS:
				op_str = "^";
				break;
			case ALU_Operation::ORS:
				op_str = "|";
				break;
			case ALU_Operation::SRS:
				op_str = ">>";
				break;
			case ALU_Operation::SUMS:
				op_str = "+";
				break;
		}

		bool pass = ac == expected;

		if (!pass)
		{
			printf("Test 0x%02X %s 0x%02X = 0x%02X, ACR: %d, AVR: %d\n", a, op_str, b, ac,
				core->alu->getACR() == TriState::One ? 1 : 0,
				core->alu->getAVR() == TriState::One ? 1 : 0);
		}

		return pass ? 0 : -1;
	}

	void UnitTest::ALU_UnitTest()
	{
		// SUMS No carry

		printf("SUMS No carry: ");
		for (size_t a = 0; a < 0x100; a++)
		{
			for (size_t b = 0; b < 0x100; b++)
			{
				int res = TestCompute((uint8_t)a, (uint8_t)b, (uint8_t)(a + b), ALU_Operation::SUMS, false, false);
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
				int res = TestCompute((uint8_t)a, (uint8_t)b, (uint8_t)(a + b + 1), ALU_Operation::SUMS, false, true);
				if (res != 0)
				{
					printf("Failed!\n");
					return;
				}
			}
		}
		printf("OK!\n");

		// BCD Add

		printf("SUMS BCD No Carry: ");
		for (size_t a = 1; a <= 0x99; a++)
		{
			// Skip numbers that are not in the BCD

			if ((a & 0xf) > 9 || (a & 0xf0) > 0x90)
				continue;

			for (size_t b = 1; b <= 0x99; b++)
			{
				if ((b & 0xf) > 9 || (b & 0xf0) > 0x90)
					continue;

				size_t bcd_res = BCD_Add(a, b, false);

				int res = TestCompute((uint8_t)a, (uint8_t)b, (uint8_t)bcd_res, ALU_Operation::SUMS, true, false);
				if (res != 0)
				{
					printf("Failed!\n");
					return;
				}
			}
		}
		printf("OK!\n");

		// BCD Add + Carry

		printf("SUMS BCD Carry: ");
		for (size_t a = 1; a <= 0x99; a++)
		{
			// Skip numbers that are not in the BCD

			if ((a & 0xf) > 9 || (a & 0xf0) > 0x90)
				continue;

			for (size_t b = 1; b <= 0x99; b++)
			{
				if ((b & 0xf) > 9 || (b & 0xf0) > 0x90)
					continue;

				size_t bcd_res = BCD_Add(a, b, true);

				int res = TestCompute((uint8_t)a, (uint8_t)b, (uint8_t)bcd_res, ALU_Operation::SUMS, true, true);
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


}
