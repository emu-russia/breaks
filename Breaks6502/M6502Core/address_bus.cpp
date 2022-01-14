#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void AddressBus::sim_ConstGen(BaseLogic::TriState inputs[], BaseLogic::TriState ADL[], BaseLogic::TriState ADH[], bool ADL_Dirty[8], bool ADH_Dirty[8])
	{
		TriState Z_ADL0 = inputs[(size_t)AddressBus_Input::Z_ADL0];
		TriState Z_ADL1 = inputs[(size_t)AddressBus_Input::Z_ADL1];
		TriState Z_ADL2 = inputs[(size_t)AddressBus_Input::Z_ADL2];
		TriState Z_ADH0 = inputs[(size_t)AddressBus_Input::Z_ADH0];
		TriState Z_ADH17 = inputs[(size_t)AddressBus_Input::Z_ADH17];

		for (size_t n = 0; n < 8; n++)
		{
			if (n == 0 && Z_ADL0 == TriState::One)
			{
				ADL[0] = TriState::Zero;
				ADL_Dirty[0] = true;
			}

			if (n == 1 && Z_ADL1 == TriState::One)
			{
				ADL[1] = TriState::Zero;
				ADL_Dirty[1] = true;
			}

			if (n == 2 && Z_ADL2 == TriState::One)
			{
				ADL[2] = TriState::Zero;
				ADL_Dirty[2] = true;
			}

			if (Z_ADH0 == TriState::One && n == 0)
			{
				ADH[n] = TriState::Zero;
				ADH_Dirty[n] = true;
			}

			if (Z_ADH17 == TriState::One && n != 0)
			{
				ADH[n] = TriState::Zero;
				ADH_Dirty[n] = true;
			}
		}
	}

	void AddressBus::sim_Output(TriState inputs[], TriState ADL[], TriState ADH[], TriState cpu_out[])
	{
		TriState PHI1 = inputs[(size_t)AddressBus_Input::PHI1];
		TriState PHI2 = inputs[(size_t)AddressBus_Input::PHI2];
		TriState ADL_ABL = inputs[(size_t)AddressBus_Input::ADL_ABL];
		TriState ADH_ABH = inputs[(size_t)AddressBus_Input::ADH_ABH];

		for (size_t n = 0; n < 8; n++)
		{
			if (PHI2 == TriState::One)
			{
				ABL[n].set(NOT(NOT(ABL[n].get())));
				ABH[n].set(NOT(NOT(ABH[n].get())));
			}

			if (PHI1 == TriState::One && ADL_ABL == TriState::One)
			{
				ABL[n].set(NOT(NOT(ADL[n])));
			}

			if (PHI1 == TriState::One && ADH_ABH == TriState::One)
			{
				ABH[n].set(NOT(NOT(ADH[n])));
			}

			cpu_out[(size_t)OutputPad::A0 + n] = ABL[n].get();
			cpu_out[(size_t)OutputPad::A8 + n] = ABH[n].get();
		}
	}

	uint8_t AddressBus::getABL()
	{
		TriState a[8];

		for (size_t n = 0; n < 8; n++)
		{
			a[n] = ABL[n].get();
		}

		return Pack(a);
	}

	uint8_t AddressBus::getABH()
	{
		TriState a[8];

		for (size_t n = 0; n < 8; n++)
		{
			a[n] = ABH[n].get();
		}

		return Pack(a);
	}
}
