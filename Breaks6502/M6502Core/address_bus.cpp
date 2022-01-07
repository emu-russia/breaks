#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void AddressBus::sim(TriState inputs[], TriState ADL[], TriState ADH[], TriState cpu_out[])
	{
		TriState PHI1 = inputs[(size_t)AddressBus_Input::PHI1];
		TriState PHI2 = inputs[(size_t)AddressBus_Input::PHI2];
		TriState Z_ADL0 = inputs[(size_t)AddressBus_Input::Z_ADL0];
		TriState Z_ADL1 = inputs[(size_t)AddressBus_Input::Z_ADL1];
		TriState Z_ADL2 = inputs[(size_t)AddressBus_Input::Z_ADL2];
		TriState ADL_ABL = inputs[(size_t)AddressBus_Input::ADL_ABL];
		TriState ADH_ABH = inputs[(size_t)AddressBus_Input::ADH_ABH];

		for (size_t n = 0; n < 8; n++)
		{
			if (PHI2 == TriState::One)
			{
				ABL[n].set(NOT(NOT(ABL[n].get())));
				ABH[n].set(NOT(NOT(ABL[n].get())));
			}

			if (n == 0 && Z_ADL0 == TriState::One)
			{
				ADL[0] = TriState::Zero;
			}

			if (n == 1 && Z_ADL1 == TriState::One)
			{
				ADL[1] = TriState::Zero;
			}

			if (n == 2 && Z_ADL2 == TriState::One)
			{
				ADL[2] = TriState::Zero;
			}

			if (PHI1 == TriState::One && ADL_ABL == TriState::One)
			{
				ABL[n].set(NOT(NOT(ADL[n])));
			}

			if (PHI1 == TriState::One && ADH_ABH == TriState::One)
			{
				ABH[n].set(NOT(NOT(ADH[n])));
			}
		}

		cpu_out[(size_t)OutputPad::A0] = ABL[0].get();
		cpu_out[(size_t)OutputPad::A1] = ABL[1].get();
		cpu_out[(size_t)OutputPad::A2] = ABL[2].get();
		cpu_out[(size_t)OutputPad::A3] = ABL[3].get();
		cpu_out[(size_t)OutputPad::A4] = ABL[4].get();
		cpu_out[(size_t)OutputPad::A5] = ABL[5].get();
		cpu_out[(size_t)OutputPad::A6] = ABL[6].get();
		cpu_out[(size_t)OutputPad::A7] = ABL[7].get();

		cpu_out[(size_t)OutputPad::A8] = ABH[0].get();
		cpu_out[(size_t)OutputPad::A9] = ABH[1].get();
		cpu_out[(size_t)OutputPad::A10] = ABH[2].get();
		cpu_out[(size_t)OutputPad::A11] = ABH[3].get();
		cpu_out[(size_t)OutputPad::A12] = ABH[4].get();
		cpu_out[(size_t)OutputPad::A13] = ABH[5].get();
		cpu_out[(size_t)OutputPad::A14] = ABH[6].get();
		cpu_out[(size_t)OutputPad::A15] = ABH[7].get();
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
