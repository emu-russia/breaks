#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void DataBus::sim(TriState inputs[], TriState DB[], TriState ADL[], TriState ADH[], TriState cpu_inOut[])
	{
		TriState PHI1 = inputs[(size_t)DataBus_Input::PHI1];
		TriState PHI2 = inputs[(size_t)DataBus_Input::PHI2];
		TriState WR = inputs[(size_t)DataBus_Input::WR];
		TriState DL_ADL = inputs[(size_t)DataBus_Input::DL_ADL];
		TriState DL_ADH = inputs[(size_t)DataBus_Input::DL_ADH];
		TriState DL_DB = inputs[(size_t)DataBus_Input::DL_DB];

		rd_latch.set(WR, PHI1);
		TriState RD = NOT(NOR(NOT(PHI2), rd_latch.nget()));

		for (size_t n = 0; n < 8; n++)
		{
			TriState Dn = cpu_inOut[(size_t)InOutPad::D0 + n];

			DL[n].set(Dn == TriState::Z ? TriState::One : NOT(Dn), PHI2);

			if (PHI1 == TriState::One)
			{
				if (DL_ADL == TriState::One)
				{
					ADL[n] = DL[n].nget();
				}
				
				if (DL_ADH == TriState::One)
				{
					ADH[n] == DL[n].nget();
				}

				if (DL_DB == TriState::One)
				{
					DB[n] == DL[n].nget();
				}
			}

			DOR[n].set(NOT(DB[n]), PHI1);

			if (RD == TriState::Zero)
			{
				cpu_inOut[(size_t)InOutPad::D0 + n] = DOR[n].nget();
			}
		}
	}
}
