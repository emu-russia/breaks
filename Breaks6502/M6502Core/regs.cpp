#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void Regs::sim_LoadSB()
	{
		TriState PHI2 = core->wire.PHI2;
		bool SB_Y = core->cmd.SB_Y;
		bool SB_X = core->cmd.SB_X;
		TriState SB_S = core->cmd.SB_S ? TriState::One : TriState::Zero;
		TriState S_S = core->cmd.S_S ? TriState::One : TriState::Zero;

		if (PHI2 == TriState::One)
		{
			for (size_t n = 0; n < 8; n++)
			{
				// During PHI2 none of the register loading commands are active and the registers are "refreshed".

				//Y[n].set(NOT(NOT(Y[n].get())));
				//X[n].set(NOT(NOT(X[n].get())));

				S_out[n].set(S_in[n].nget(), TriState::One);
			}
		}
		else
		{
			if (SB_Y || SB_X || S_S || SB_S)
			{
				for (size_t n = 0; n < 8; n++)
				{
					if (SB_Y)
					{
						Y[n].set(NOT(NOT(core->SB[n])));
					}

					if (SB_X)
					{
						X[n].set(NOT(NOT(core->SB[n])));
					}

					// S/S and SB/S are complementary signals.

					S_in[n].set(S_out[n].nget(), S_S);
					S_in[n].set(core->SB[n], SB_S);
				}
			}
		}
	}

	void Regs::sim_StoreSB()
	{
		TriState PHI2 = core->wire.PHI2;
		bool Y_SB = core->cmd.Y_SB;
		bool X_SB = core->cmd.X_SB;
		bool S_SB = core->cmd.S_SB;

		if (Y_SB || X_SB || S_SB)
		{
			for (size_t n = 0; n < 8; n++)
			{
				S_out[n].set(S_in[n].nget(), PHI2);

				if (S_SB)
				{
					if (core->SB_Dirty[n])
					{
						core->SB[n] = AND(core->SB[n], S_out[n].nget());
					}
					else
					{
						core->SB[n] = S_out[n].nget();
						core->SB_Dirty[n] = true;
					}
				}

				if (Y_SB)
				{
					if (core->SB_Dirty[n])
					{
						core->SB[n] = AND(core->SB[n], Y[n].get());
					}
					else
					{
						core->SB[n] = Y[n].get();
						core->SB_Dirty[n] = true;
					}
				}

				if (X_SB)
				{
					if (core->SB_Dirty[n])
					{
						core->SB[n] = AND(core->SB[n], X[n].get());
					}
					else
					{
						core->SB[n] = X[n].get();
						core->SB_Dirty[n] = true;
					}
				}
			}
		}
	}

	void Regs::sim_StoreOldS()
	{
		bool S_ADL = core->cmd.S_ADL;

		if (!S_ADL)
		{
			return;
		}

		for (size_t n = 0; n < 8; n++)
		{
			if (S_ADL)
			{
				if (core->ADL_Dirty[n])
				{
					core->ADL[n] = AND(core->ADL[n], S_out[n].nget());
				}
				else
				{
					core->ADL[n] = S_out[n].nget();
					core->ADL_Dirty[n] = true;
				}
			}
		}
	}

	uint8_t Regs::getY()
	{
		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = Y[n].get();
		}

		return Pack(v);
	}

	uint8_t Regs::getX()
	{
		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = X[n].get();
		}

		return Pack(v);
	}

	uint8_t Regs::getS()
	{
		TriState v[8];

		for (size_t n = 0; n < 8; n++)
		{
			v[n] = S_out[n].nget();
		}

		return Pack(v);
	}
}
