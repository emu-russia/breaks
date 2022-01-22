#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void DataBus::sim_SetExternalBus(TriState cpu_inOut[])
	{
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState WR = core->wire.WR;

		rd_latch.set(WR, PHI1);
		TriState RD = NOT(NOR(NOT(PHI2), rd_latch.nget()));

		for (size_t n = 0; n < 8; n++)
		{
			DOR[n].set(NOT(core->DB[n]), PHI1);

			if (RD == TriState::Zero)
			{
				cpu_inOut[(size_t)InOutPad::D0 + n] = DOR[n].nget();
			}
		}
	}

	void DataBus::sim_GetExternalBus(TriState cpu_inOut[])
	{
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState WR = core->wire.WR;
		bool DL_ADL = core->cmd.DL_ADL;
		bool DL_ADH = core->cmd.DL_ADH;
		bool DL_DB = core->cmd.DL_DB;

		rd_latch.set(WR, PHI1);
		TriState RD = NOT(NOR(NOT(PHI2), rd_latch.nget()));

		for (size_t n = 0; n < 8; n++)
		{
			TriState Dn = cpu_inOut[(size_t)InOutPad::D0 + n];

			DL[n].set(Dn == TriState::Z ? TriState::One : NOT(Dn), PHI2);
		}

		if ((DL_ADL || DL_ADH || DL_DB) && (PHI1 == TriState::One))
		{
			for (size_t n = 0; n < 8; n++)
			{
				if (DL_ADL)
				{
					if (core->ADL_Dirty[n])
					{
						core->ADL[n] = AND(core->ADL[n], DL[n].nget());
					}
					else
					{
						core->ADL[n] = DL[n].nget();
						core->ADL_Dirty[n] = true;
					}
				}

				if (DL_ADH)
				{
					if (core->ADH_Dirty[n])
					{
						core->ADH[n] = AND(core->ADH[n], DL[n].nget());
					}
					else
					{
						core->ADH[n] = DL[n].nget();
						core->ADH_Dirty[n] = true;
					}
				}

				if (DL_DB)
				{
					if (core->DB_Dirty[n])
					{
						core->DB[n] = AND(core->DB[n], DL[n].nget());
					}
					else
					{
						core->DB[n] = DL[n].nget();
						core->DB_Dirty[n] = true;
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
