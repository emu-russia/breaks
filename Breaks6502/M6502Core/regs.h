#pragma once

namespace M6502Core
{
	enum class Regs_Input
	{
		PHI2 = 0,
		Y_SB,
		SB_Y,
		X_SB,
		SB_X,
		S_ADL,
		S_SB,
		SB_S,
		S_S,
		Max,
	};

	class Regs
	{
	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState SB[], BaseLogic::TriState ADL[]);
	};
}
