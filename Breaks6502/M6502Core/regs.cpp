#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void Regs::sim_LoadSB()
	{
		TriState PHI2 = core->wire.PHI2;
		bool SB_Y = core->cmd.SB_Y;
		bool SB_X = core->cmd.SB_X;
		bool SB_S = core->cmd.SB_S;
		bool S_S = core->cmd.S_S;

		if (PHI2 == TriState::One)
		{
			S_out = ~S_in;
		}
		else
		{
			if (SB_Y)
			{
				Y = core->SB;
			}

			if (SB_X)
			{
				X = core->SB;
			}

			if (S_S)
			{
				S_in = ~S_out;
			}

			if (SB_S)
			{
				S_in = core->SB;
			}
		}
	}

	void Regs::sim_StoreSB()
	{
		TriState PHI2 = core->wire.PHI2;
		bool Y_SB = core->cmd.Y_SB;
		bool X_SB = core->cmd.X_SB;
		bool S_SB = core->cmd.S_SB;

		if (PHI2)
		{
			S_out = ~S_in;
		}

		if (S_SB)
		{
			if (core->SB_Dirty)
			{
				core->SB = core->SB & (~S_out);
			}
			else
			{
				core->SB = ~S_out;
				core->SB_Dirty = true;
			}
		}

		if (Y_SB)
		{
			if (core->SB_Dirty)
			{
				core->SB = core->SB & Y;
			}
			else
			{
				core->SB = Y;
				core->SB_Dirty = true;
			}
		}

		if (X_SB)
		{
			if (core->SB_Dirty)
			{
				core->SB = core->SB & X;
			}
			else
			{
				core->SB = X;
				core->SB_Dirty = true;
			}
		}
	}

	void Regs::sim_StoreOldS()
	{
		bool S_ADL = core->cmd.S_ADL;

		if (S_ADL)
		{
			if (core->ADL_Dirty)
			{
				core->ADL = core->ADL & ~S_out;
			}
			else
			{
				core->ADL = ~S_out;
				core->ADL_Dirty = true;
			}
		}
	}

	uint8_t Regs::getY()
	{
		return Y;
	}

	uint8_t Regs::getX()
	{
		return X;
	}

	uint8_t Regs::getS()
	{
		return ~S_out;
	}
}
