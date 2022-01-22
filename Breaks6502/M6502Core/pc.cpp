#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void ProgramCounter::sim_EvenBit(TriState PHI2, TriState cin, TriState& cout, TriState& sout, size_t n, DLatch PCx[], DLatch PCxS[])
	{
		sout = PCxS[n].nget();
		cout = NOR(cin, sout);
		PCx[n].set(NOR(AND(sout, cin), cout), PHI2);
	}

	void ProgramCounter::sim_OddBit(TriState PHI2, TriState cin, TriState& cout, TriState& sout, size_t n, DLatch PCx[], DLatch PCxS[])
	{
		sout = PCxS[n].nget();
		cout = NAND(cin, NOT(sout));
		PCx[n].set(NAND(OR(NOT(sout), cin), cout), PHI2);
	}

	void ProgramCounter::sim()
	{
		if (HLE)
		{
			sim_HLE();
			return;
		}

		TriState PHI2 = core->wire.PHI2;
		TriState n_1PC = core->wire.n_1PC;

		if (PHI2 != TriState::One)
		{
			// The quick way out. Nothing is saved anywhere during PHI1.

			return;
		}

		// PCL

		TriState cin = n_1PC;
		TriState souts[9];
		souts[0] = n_1PC;

		for (size_t n = 0; n < 8; n++)
		{
			if (n & 1)
			{
				sim_OddBit(PHI2, cin, cin, souts[n + 1], n, PCL, PCLS);
			}
			else
			{
				sim_EvenBit(PHI2, cin, cin, souts[n + 1], n, PCL, PCLS);
			}
		}

		TriState PCLC = NOR9(souts);

		// PCH

		// The circuits for the even bits (0, 2, ...) of the PCH repeat the circuits for the odd bits (1, 3, ...) of the PCL.
		// Similarly, circuits for odd bits (1, 3, ...) of PCH repeat circuits for even bits (0, 2, ...) of PCL.

		cin = PCLC;
		TriState pchc[5];
		pchc[0] = NOT(PCLC);

		for (size_t n = 0; n < 4; n++)
		{
			if (n & 1)
			{
				sim_EvenBit(PHI2, cin, cin, pchc[n + 1], n, PCH, PCHS);
			}
			else
			{
				sim_OddBit(PHI2, cin, cin, pchc[n + 1], n, PCH, PCHS);
			}
		}

		TriState PCHC = NOR5(pchc);
		cin = PCHC;
		TriState bogus;

		for (size_t n = 4; n < 8; n++)
		{
			if (n & 1)
			{
				sim_EvenBit(PHI2, cin, cin, bogus, n, PCH, PCHS);
			}
			else
			{
				sim_OddBit(PHI2, cin, cin, bogus, n, PCH, PCHS);
			}
		}
	}

	void ProgramCounter::sim_HLE()
	{
		TriState PHI2 = core->wire.PHI2;
		TriState n_1PC = core->wire.n_1PC;

		if (PHI2 == TriState::One)
		{
			uint16_t pc = ((uint16_t)PackedPCHS << 8) | PackedPCLS;

			if (n_1PC == TriState::Zero)
			{
				pc++;
			}

			PackedPCL = pc & 0xff;
			PackedPCH = pc >> 8;
		}
	}

	void ProgramCounter::sim_Load()
	{
		if (HLE)
		{
			sim_LoadHLE();
			return;
		}

		TriState ADL_PCL = core->cmd.ADL_PCL ? TriState::One : TriState::Zero;
		TriState PCL_PCL = core->cmd.PCL_PCL ? TriState::One : TriState::Zero;
		TriState ADH_PCH = core->cmd.ADH_PCH ? TriState::One : TriState::Zero;
		TriState PCH_PCH = core->cmd.PCH_PCH ? TriState::One : TriState::Zero;

		if (PCL_PCL || PCH_PCH)
		{
			for (size_t n = 0; n < 8; n++)
			{
				if (n & 1)
				{
					PCLS[n].set(PCL[n].nget(), PCL_PCL);
					PCHS[n].set(NOT(PCH[n].nget()), PCH_PCH);
				}
				else
				{
					PCLS[n].set(NOT(PCL[n].nget()), PCL_PCL);
					PCHS[n].set(PCH[n].nget(), PCH_PCH);
				}
			}
		}

		if (ADL_PCL || ADH_PCH)
		{
			for (size_t n = 0; n < 8; n++)
			{
				PCLS[n].set(core->ADL & (1 << n) ? TriState::One : TriState::Zero, ADL_PCL);
				PCHS[n].set(core->ADH & (1 << n) ? TriState::One : TriState::Zero, ADH_PCH);
			}
		}
	}

	void ProgramCounter::sim_Store()
	{
		if (HLE)
		{
			sim_StoreHLE();
			return;
		}

		bool PCL_ADL = core->cmd.PCL_ADL;
		bool PCL_DB = core->cmd.PCL_DB;
		bool PCH_ADH = core->cmd.PCH_ADH;
		bool PCH_DB = core->cmd.PCH_DB;

		if (PCL_DB || PCL_ADL)
		{
			uint8_t out = 0;

			for (size_t n = 0; n < 8; n++)
			{
				if (n & 1)
				{
					out |= PCL[n].nget() << n;
				}
				else
				{
					out |= NOT(PCL[n].nget()) << n;
				}
			}

			if (PCL_DB)
			{
				if (core->DB_Dirty)
				{
					core->DB = core->DB & out;
				}
				else
				{
					core->DB = out;
					core->DB_Dirty = true;
				}
			}

			if (PCL_ADL)
			{
				if (core->ADL_Dirty)
				{
					core->ADL = core->ADL & out;
				}
				else
				{
					core->ADL = out;
					core->ADL_Dirty = true;
				}
			}
		}

		if (PCH_DB || PCH_ADH)
		{
			uint8_t out = 0;

			for (size_t n = 0; n < 8; n++)
			{
				if (n & 1)
				{
					out |= NOT(PCH[n].nget()) << n;
				}
				else
				{
					out |= PCH[n].nget() << n;
				}
			}

			if (PCH_DB)
			{
				if (core->DB_Dirty)
				{
					core->DB = core->DB & out;
				}
				else
				{
					core->DB = out;
					core->DB_Dirty = true;
				}
			}

			if (PCH_ADH)
			{
				if (core->ADH_Dirty)
				{
					core->ADH = core->ADH & out;
				}
				else
				{
					core->ADH = out;
					core->ADH_Dirty = true;
				}
			}
		}
	}

	void ProgramCounter::sim_LoadHLE()
	{
		bool ADL_PCL = core->cmd.ADL_PCL;
		bool PCL_PCL = core->cmd.PCL_PCL;
		bool ADH_PCH = core->cmd.ADH_PCH;
		bool PCH_PCH = core->cmd.PCH_PCH;

		if (PCL_PCL)
		{
			PackedPCLS = PackedPCL;
		}

		if (PCH_PCH)
		{
			PackedPCHS = PackedPCH;
		}

		if (ADL_PCL)
		{
			PackedPCLS = core->ADL;
		}

		if (ADH_PCH)
		{
			PackedPCHS = core->ADH;
		}
	}

	void ProgramCounter::sim_StoreHLE()
	{
		bool PCL_ADL = core->cmd.PCL_ADL;
		bool PCL_DB = core->cmd.PCL_DB;
		bool PCH_ADH = core->cmd.PCH_ADH;
		bool PCH_DB = core->cmd.PCH_DB;

		if (PCL_DB)
		{
			if (core->DB_Dirty)
			{
				core->DB = core->DB & PackedPCL;
			}
			else
			{
				core->DB = PackedPCL;
				core->DB_Dirty = true;
			}
		}

		if (PCL_ADL)
		{
			if (core->ADL_Dirty)
			{
				core->ADL = core->ADL & PackedPCL;
			}
			else
			{
				core->ADL = PackedPCL;
				core->ADL_Dirty = true;
			}
		}

		if (PCH_DB)
		{
			if (core->DB_Dirty)
			{
				core->DB = core->DB & PackedPCH;
			}
			else
			{
				core->DB = PackedPCH;
				core->DB_Dirty = true;
			}
		}

		if (PCH_ADH)
		{
			if (core->ADH_Dirty)
			{
				core->ADH = core->ADH & PackedPCH;
			}
			else
			{
				core->ADH = PackedPCH;
				core->ADH_Dirty = true;
			}
		}
	}

	uint8_t ProgramCounter::getPCL()
	{
		if (HLE)
			return PackedPCL;

		TriState v[8];

		// The value stored in PCL alternates between inversion, because of the inverted carry chain.

		for (size_t n = 0; n < 8; n++)
		{
			if (n & 1)
			{
				v[n] = PCL[n].nget();
			}
			else
			{
				v[n] = NOT(PCL[n].nget());
			}
		}

		return Pack(v);
	}

	uint8_t ProgramCounter::getPCH()
	{
		if (HLE)
			return PackedPCH;

		TriState v[8];

		// The value stored in PCH alternates between inversion, because of the inverted carry chain.
		// The storage inversion is different from the storage inversion of the PCL register (because of the alteration of the PCL and PCH bit circuits).

		for (size_t n = 0; n < 8; n++)
		{
			if (n & 1)
			{
				v[n] = NOT(PCH[n].nget());
			}
			else
			{
				v[n] = PCH[n].nget();
			}
		}

		return Pack(v);
	}

	uint8_t ProgramCounter::getPCLS()
	{
		if (HLE)
			return PackedPCLS;

		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = PCLS[n].get();
		}

		return Pack(v);
	}

	uint8_t ProgramCounter::getPCHS()
	{
		if (HLE)
			return PackedPCHS;

		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = PCHS[n].get();
		}

		return Pack(v);
	}
}
