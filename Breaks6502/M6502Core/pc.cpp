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

	void ProgramCounter::sim(TriState inputs[])
	{
		TriState PHI2 = inputs[(size_t)ProgramCounter_Input::PHI2];
		TriState n_1PC = inputs[(size_t)ProgramCounter_Input::n_1PC];

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

	void ProgramCounter::sim_Load(TriState inputs[], TriState ADL[], TriState ADH[])
	{
		TriState ADL_PCL = inputs[(size_t)ProgramCounter_Input::ADL_PCL];
		TriState PCL_PCL = inputs[(size_t)ProgramCounter_Input::PCL_PCL];
		TriState ADH_PCH = inputs[(size_t)ProgramCounter_Input::ADH_PCH];
		TriState PCH_PCH = inputs[(size_t)ProgramCounter_Input::PCH_PCH];

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

			PCLS[n].set(ADL[n], ADL_PCL);
			PCHS[n].set(ADH[n], ADH_PCH);
		}
	}

	void ProgramCounter::sim_Store(TriState inputs[], TriState DB[], TriState ADL[], TriState ADH[], bool DB_Dirty[8], bool ADL_Dirty[8], bool ADH_Dirty[8])
	{
		TriState PCL_ADL = inputs[(size_t)ProgramCounter_Input::PCL_ADL];
		TriState PCL_DB = inputs[(size_t)ProgramCounter_Input::PCL_DB];
		TriState PCH_ADH = inputs[(size_t)ProgramCounter_Input::PCH_ADH];
		TriState PCH_DB = inputs[(size_t)ProgramCounter_Input::PCH_DB];
		TriState out;

		for (size_t n = 0; n < 8; n++)
		{
			if (n & 1)
			{
				out = PCL[n].nget();
			}
			else
			{
				out = NOT(PCL[n].nget());
			}

			if (PCL_DB == TriState::One)
			{
				if (DB_Dirty[n])
				{
					DB[n] = AND(DB[n], out);
				}
				else
				{
					DB[n] = out;
					DB_Dirty[n] = true;
				}
			}
			if (PCL_ADL == TriState::One)
			{
				if (ADL_Dirty[n])
				{
					ADL[n] = AND(ADL[n], out);
				}
				else
				{
					ADL[n] = out;
					ADL_Dirty[n] = true;
				}
			}
		}

		for (size_t n = 0; n < 8; n++)
		{
			if (n & 1)
			{
				out = NOT(PCH[n].nget());
			}
			else
			{
				out = PCH[n].nget();
			}

			if (PCH_DB == TriState::One)
			{
				if (DB_Dirty[n])
				{
					DB[n] = AND(DB[n], out);
				}
				else
				{
					DB[n] = out;
					DB_Dirty[n] = true;
				}
			}
			if (PCH_ADH == TriState::One)
			{
				if (ADH_Dirty[n])
				{
					ADH[n] = AND(ADH[n], out);
				}
				else
				{
					ADH[n] = out;
					ADH_Dirty[n] = true;
				}
			}
		}
	}

	uint8_t ProgramCounter::getPCL()
	{
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
		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = PCLS[n].get();
		}

		return Pack(v);
	}

	uint8_t ProgramCounter::getPCHS()
	{
		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = PCHS[n].get();
		}

		return Pack(v);
	}
}
