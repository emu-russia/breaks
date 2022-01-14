#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void Regs::sim_Load(TriState inputs[], TriState SB[])
	{
		TriState PHI2 = inputs[(size_t)Regs_Input::PHI2];
		TriState SB_Y = inputs[(size_t)Regs_Input::SB_Y];
		TriState SB_X = inputs[(size_t)Regs_Input::SB_X];
		TriState SB_S = inputs[(size_t)Regs_Input::SB_S];
		TriState S_S = inputs[(size_t)Regs_Input::S_S];

		for (size_t n = 0; n < 8; n++)
		{
			if (PHI2 == TriState::One)
			{
				// During PHI2 none of the register loading commands are active and the registers are "refreshed".

				Y[n].set(NOT(NOT(Y[n].get())));
				X[n].set(NOT(NOT(X[n].get())));
				S[n].set(NOT(NOT(S[n].get())));
			}
			else
			{
				if (SB_Y == TriState::One)
				{
					Y[n].set(NOT(NOT(SB[n])));
				}

				if (SB_X == TriState::One)
				{
					X[n].set(NOT(NOT(SB[n])));
				}

				// S/S and SB/S are complementary signals.
				// But in the very first half-cycle all commands are set, because the output latches have an undefined state (X, but essentially - no electrons on the gate yet, so the FETs are closed).

				if (S_S == TriState::One)
				{
					S[n].set(NOT(NOT(S[n].get())));
				}

				if (SB_S == TriState::One)
				{
					S[n].set(NOT(NOT(SB[n])));
				}
			}
		}
	}

	void Regs::sim_Store(TriState inputs[], TriState SB[], TriState ADL[], bool SB_Dirty[8], bool ADL_Dirty[8])
	{
		TriState PHI2 = inputs[(size_t)Regs_Input::PHI2];
		TriState Y_SB = inputs[(size_t)Regs_Input::Y_SB];
		TriState X_SB = inputs[(size_t)Regs_Input::X_SB];
		TriState S_ADL = inputs[(size_t)Regs_Input::S_ADL];
		TriState S_SB = inputs[(size_t)Regs_Input::S_SB];

		for (size_t n = 0; n < 8; n++)
		{
			if (S_SB == TriState::One)
			{
				if (SB_Dirty[n])
				{
					SB[n] = AND(SB[n], S[n].get());
				}
				else
				{
					SB[n] = S[n].get();
					SB_Dirty[n] = true;
				}
			}

			if (S_ADL == TriState::One)
			{
				if (ADL_Dirty[n])
				{
					ADL[n] = AND(ADL[n], S[n].get());
				}
				else
				{
					ADL[n] = S[n].get();
					ADL_Dirty[n] = true;
				}
			}

			if (PHI2 == TriState::One)
			{
				// During PHI2 none of the register loading commands are active and the registers are "refreshed".

				Y[n].set(NOT(NOT(Y[n].get())));
				X[n].set(NOT(NOT(X[n].get())));
				S[n].set(NOT(NOT(S[n].get())));
			}
			else
			{
				if (Y_SB == TriState::One)
				{
					if (SB_Dirty[n])
					{
						SB[n] = AND(SB[n], Y[n].get());
					}
					else
					{
						SB[n] = Y[n].get();
						SB_Dirty[n] = true;
					}
				}

				if (X_SB == TriState::One)
				{
					if (SB_Dirty[n])
					{
						SB[n] = AND(SB[n], X[n].get());
					}
					else
					{
						SB[n] = X[n].get();
						SB_Dirty[n] = true;
					}
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
			v[n] = S[n].get();
		}

		return Pack(v);
	}
}
