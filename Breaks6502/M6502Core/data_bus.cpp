#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void DataBus::sim_SetExternalBus(uint8_t* data_bus)
	{
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState WR = core->wire.WR;

		rd_latch.set(WR, PHI1);
		TriState RD = NOT(NOR(NOT(PHI2), rd_latch.nget()));

		if (PHI1)
		{
			DOR = ~(core->DB);
		}

		if (RD == TriState::Zero)
		{
			*data_bus = ~DOR;
		}
	}

	void DataBus::sim_GetExternalBus(uint8_t* data_bus)
	{
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		TriState WR = core->wire.WR;
		bool DL_ADL = core->cmd.DL_ADL;
		bool DL_ADH = core->cmd.DL_ADH;
		bool DL_DB = core->cmd.DL_DB;

		rd_latch.set(WR, PHI1);
		TriState RD = NOT(NOR(NOT(PHI2), rd_latch.nget()));

		if (PHI2 == TriState::One)
		{
			DL = ~(*data_bus);
		}

		if (PHI1 == TriState::One)
		{
			if (DL_ADL)
			{
				if (core->ADL_Dirty)
				{
					core->ADL = core->ADL & ~DL;
				}
				else
				{
					core->ADL = ~DL;
					core->ADL_Dirty = true;
				}
			}

			if (DL_ADH)
			{
				if (core->ADH_Dirty)
				{
					core->ADH = core->ADH & ~DL;
				}
				else
				{
					core->ADH = ~DL;
					core->ADH_Dirty = true;
				}
			}

			if (DL_DB)
			{
				if (core->DB_Dirty)
				{
					core->DB = core->DB & ~DL;
				}
				else
				{
					core->DB = ~DL;
					core->DB_Dirty = true;
				}
			}
		}
	}

	uint8_t DataBus::getDL()
	{
		return ~DL;
	}

	uint8_t DataBus::getDOR()
	{
		return ~DOR;
	}
}
