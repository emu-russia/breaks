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
		BaseLogic::DLatch S_in[8];
		BaseLogic::DLatch S_out[8];

	public:

		void sim_LoadSB(BaseLogic::TriState inputs[], BaseLogic::TriState SB[]);

		void sim_StoreSB(BaseLogic::TriState inputs[], BaseLogic::TriState SB[], bool SB_Dirty[8]);

		void sim_StoreADL(BaseLogic::TriState inputs[], BaseLogic::TriState ADL[], bool ADL_Dirty[8]);

		uint8_t getY();
		uint8_t getX();
		uint8_t getS();
	};
}
