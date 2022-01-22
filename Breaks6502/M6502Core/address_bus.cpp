#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void AddressBus::sim_ConstGen()
	{
		bool Z_ADL0 = core->cmd.Z_ADL0;
		bool Z_ADL1 = core->cmd.Z_ADL1;
		bool Z_ADL2 = core->cmd.Z_ADL2;
		bool Z_ADH0 = core->cmd.Z_ADH0;
		bool Z_ADH17 = core->cmd.Z_ADH17;

		if (Z_ADL0 || Z_ADL1 || Z_ADL2 || Z_ADH0 || Z_ADH17)
		{
			for (size_t n = 0; n < 8; n++)
			{
				if (n == 0 && Z_ADL0)
				{
					core->ADL[0] = TriState::Zero;
					core->ADL_Dirty[0] = true;
				}

				if (n == 1 && Z_ADL1)
				{
					core->ADL[1] = TriState::Zero;
					core->ADL_Dirty[1] = true;
				}

				if (n == 2 && Z_ADL2)
				{
					core->ADL[2] = TriState::Zero;
					core->ADL_Dirty[2] = true;
				}

				if (Z_ADH0 && n == 0)
				{
					core->ADH[n] = TriState::Zero;
					core->ADH_Dirty[n] = true;
				}

				if (Z_ADH17 && n != 0)
				{
					core->ADH[n] = TriState::Zero;
					core->ADH_Dirty[n] = true;
				}
			}
		}
	}

	void AddressBus::sim_Output(TriState cpu_out[])
	{
		TriState PHI1 = core->wire.PHI1;
		TriState PHI2 = core->wire.PHI2;
		bool ADL_ABL = core->cmd.ADL_ABL;
		bool ADH_ABH = core->cmd.ADH_ABH;

		// The address bus is set during PHI1 only

		for (size_t n = 0; n < 8; n++)
		{
			//if (PHI2 == TriState::One)
			//{
			//	ABL[n].set(NOT(NOT(ABL[n].get())));
			//	ABH[n].set(NOT(NOT(ABH[n].get())));
			//}

			if (PHI1 == TriState::One && ADL_ABL)
			{
				ABL[n].set(NOT(NOT(core->ADL[n])));
			}

			if (PHI1 == TriState::One && ADH_ABH)
			{
				ABH[n].set(NOT(NOT(core->ADH[n])));
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
