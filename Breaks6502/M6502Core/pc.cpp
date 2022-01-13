#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void ProgramCounter::sim_EvenBit(
		TriState PHI2, TriState ADx_PCx, TriState PCx_PCx, TriState PCx_ADx, TriState PCx_DB, TriState DB[], TriState ADx[],
		TriState cin, TriState& cout, TriState& sout, size_t n,
		DLatch PCx[], DLatch PCxS[])
	{
		if (PCx_PCx == TriState::One)
		{
			PCxS[n].set(NOT(PCx[n].nget()), BaseLogic::One);
		}
		if (ADx_PCx == TriState::One)
		{
			PCxS[n].set(ADx[n], BaseLogic::One);
		}

		sout = PCxS[n].nget();
		cout = NOR(cin, sout);

		PCx[n].set(NOR(AND(sout, cin), cout), PHI2);

		TriState out = NOT(PCx[n].nget());

		if (PCx_DB == TriState::One)
		{
			DB[n] = out;
		}
		if (PCx_ADx == TriState::One)
		{
			ADx[n] = out;
		}
	}

	void ProgramCounter::sim_OddBit(
		TriState PHI2, TriState ADx_PCx, TriState PCx_PCx, TriState PCx_ADx, TriState PCx_DB, TriState DB[], TriState ADx[],
		TriState cin, TriState& cout, TriState& sout, size_t n,
		DLatch PCx[], DLatch PCxS[])
	{
		if (PCx_PCx == TriState::One)
		{
			PCxS[n].set(PCx[n].nget(), BaseLogic::One);
		}
		if (ADx_PCx == TriState::One)
		{
			PCxS[n].set(ADx[n], BaseLogic::One);
		}

		sout = PCxS[n].nget();
		cout = NAND(cin, NOT(sout));

		PCx[n].set(NAND(OR(NOT(sout), cin), cout), PHI2);

		TriState out = PCx[n].nget();

		if (PCx_DB == TriState::One)
		{
			DB[n] = out;
		}
		if (PCx_ADx == TriState::One)
		{
			ADx[n] = out;
		}
	}

	void ProgramCounter::sim(TriState inputs[], TriState DB[], TriState ADL[], TriState ADH[])
	{
		TriState PHI2 = inputs[(size_t)ProgramCounter_Input::PHI2];
		TriState ADL_PCL = inputs[(size_t)ProgramCounter_Input::ADL_PCL];
		TriState PCL_PCL = inputs[(size_t)ProgramCounter_Input::PCL_PCL];
		TriState PCL_ADL = inputs[(size_t)ProgramCounter_Input::PCL_ADL];
		TriState PCL_DB = inputs[(size_t)ProgramCounter_Input::PCL_DB];
		TriState ADH_PCH = inputs[(size_t)ProgramCounter_Input::ADH_PCH];
		TriState PCH_PCH = inputs[(size_t)ProgramCounter_Input::PCH_PCH];
		TriState PCH_ADH = inputs[(size_t)ProgramCounter_Input::PCH_ADH];
		TriState PCH_DB = inputs[(size_t)ProgramCounter_Input::PCH_DB];
		TriState n_1PC = inputs[(size_t)ProgramCounter_Input::n_1PC];

		// PCL

		TriState cin = n_1PC;
		TriState souts[8];

		for (size_t n = 0; n < 8; n++)
		{
			if (n & 1)
			{
				sim_OddBit(PHI2, ADL_PCL, PCL_PCL, PCL_ADL, PCL_DB, DB, ADL, cin, cin, souts[n], n, PCL, PCLS);
			}
			else
			{
				sim_EvenBit(PHI2, ADL_PCL, PCL_PCL, PCL_ADL, PCL_DB, DB, ADL, cin, cin, souts[n], n, PCL, PCLS);
			}
		}

		TriState PCLC = NOR8(souts);

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
				sim_EvenBit(PHI2, ADH_PCH, PCH_PCH, PCH_ADH, PCH_DB, DB, ADH, cin, cin, pchc[n + 1], n, PCH, PCHS);
			}
			else
			{
				sim_OddBit(PHI2, ADH_PCH, PCH_PCH, PCH_ADH, PCH_DB, DB, ADH, cin, cin, pchc[n + 1], n, PCH, PCHS);
			}
		}

		TriState PCHC = NOR5(pchc);
		cin = PCHC;
		TriState bogus;

		for (size_t n = 4; n < 8; n++)
		{
			if (n & 1)
			{
				sim_EvenBit(PHI2, ADH_PCH, PCH_PCH, PCH_ADH, PCH_DB, DB, ADH, cin, cin, bogus, n, PCH, PCHS);
			}
			else
			{
				sim_OddBit(PHI2, ADH_PCH, PCH_PCH, PCH_ADH, PCH_DB, DB, ADH, cin, cin, bogus, n, PCH, PCHS);
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
}
