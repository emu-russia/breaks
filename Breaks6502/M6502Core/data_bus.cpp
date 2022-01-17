#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void DataBus::sim_SetExternalBus(TriState inputs[], TriState DB[], TriState cpu_inOut[])
	{
		TriState PHI1 = inputs[(size_t)DataBus_Input::PHI1];
		TriState PHI2 = inputs[(size_t)DataBus_Input::PHI2];
		TriState WR = inputs[(size_t)DataBus_Input::WR];

		rd_latch.set(WR, PHI1);
		TriState RD = NOT(NOR(NOT(PHI2), rd_latch.nget()));

		for (size_t n = 0; n < 8; n++)
		{
			DOR[n].set(NOT(DB[n]), PHI1);

			if (RD == TriState::Zero)
			{
				cpu_inOut[(size_t)InOutPad::D0 + n] = DOR[n].nget();
			}
		}
	}

	void DataBus::sim_GetExternalBus(TriState inputs[], TriState DB[], TriState ADL[], TriState ADH[], bool DB_Dirty[8], bool ADL_Dirty[8], bool ADH_Dirty[8], TriState cpu_inOut[])
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
					if (ADL_Dirty[n])
					{
						ADL[n] = AND(ADL[n], DL[n].nget());
					}
					else
					{
						ADL[n] = DL[n].nget();
						ADL_Dirty[n] = true;
					}
				}
				
				if (DL_ADH == TriState::One)
				{
					if (ADH_Dirty[n])
					{
						ADH[n] = AND(ADH[n], DL[n].nget());
					}
					else
					{
						ADH[n] = DL[n].nget();
						ADH_Dirty[n] = true;
					}
				}

				if (DL_DB == TriState::One)
				{
					if (DB_Dirty[n])
					{
						DB[n] = AND(DB[n], DL[n].nget());
					}
					else
					{
						DB[n] = DL[n].nget();
						DB_Dirty[n] = true;
					}
				}
			}
		}
	}

	uint8_t DataBus::getDL()
	{
		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = DL[n].nget();
		}

		return Pack(v);
	}

	uint8_t DataBus::getDOR()
	{
		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = DOR[n].nget();
		}

		return Pack(v);
	}
}
