#include "pch.h"

using namespace BaseLogic;

namespace M6502Core
{
	void Regs::sim_Bit(TriState inputs[], TriState SB[], TriState ADL[], size_t n)
	{
		TriState PHI2 = inputs[(size_t)Regs_Input::PHI2];
		TriState Y_SB = inputs[(size_t)Regs_Input::Y_SB];
		TriState SB_Y = inputs[(size_t)Regs_Input::SB_Y];
		TriState X_SB = inputs[(size_t)Regs_Input::X_SB];
		TriState SB_X = inputs[(size_t)Regs_Input::SB_X];
		TriState S_ADL = inputs[(size_t)Regs_Input::S_ADL];
		TriState S_SB = inputs[(size_t)Regs_Input::S_SB];
		TriState SB_S = inputs[(size_t)Regs_Input::SB_S];
		TriState S_S = inputs[(size_t)Regs_Input::S_S];

		bool sb_dirty = false;		// It is used to resolve a conflict when several registers push their values onto the bus at once.

		if (S_SB == TriState::One)
		{
			SB[n] = S[n].get();
			sb_dirty = true;
		}

		if (S_ADL == TriState::One)
		{
			ADL[n] = S[n].get();
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
				if (sb_dirty)
				{
					SB[n] = AND(SB[n], Y[n].get());
				}
				else
				{
					SB[n] = Y[n].get();
					sb_dirty = true;
				}
			}

			if (X_SB == TriState::One)
			{
				if (sb_dirty)
				{
					SB[n] = AND(SB[n], X[n].get());
				}
				else
				{
					SB[n] = X[n].get();
					sb_dirty = true;
				}
			}

			if (SB_Y == TriState::One)
			{
				Y[n].set(NOT(NOT(SB[n])));
			}

			if (SB_X == TriState::One)
			{
				X[n].set(NOT(NOT(SB[n])));
			}

			// S/S and SB/S are complementary signals.

#if _DEBUG
			//if (S_S == SB_S)
			//{
			//	throw "Something scary happened in the random logic, making S/S = SB/S.";
			//}
#endif

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

	void Regs::sim(TriState inputs[], TriState SB[], TriState ADL[])
	{
		for (size_t n = 0; n < 8; n++)
		{
			sim_Bit(inputs, SB, ADL, n);
		}
	}
}
