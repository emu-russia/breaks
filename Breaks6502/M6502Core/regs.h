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
		BaseLogic::FF Y[8];
		BaseLogic::FF X[8];
		BaseLogic::FF S[8];

		void sim_Bit(BaseLogic::TriState inputs[], BaseLogic::TriState SB[], BaseLogic::TriState ADL[], size_t n);

	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState SB[], BaseLogic::TriState ADL[]);

		uint8_t getY();
		uint8_t getX();
		uint8_t getS();
	};
}
