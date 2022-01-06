#pragma once

namespace M6502Core
{
	enum class ProgramCounter_Input
	{
		PHI2 = 0,
		ADL_PCL,
		PCL_PCL,
		PCL_ADL,
		PCL_DB,
		ADH_PCH,
		PCH_PCH,
		PCH_ADH,
		PCH_DB,
		n_1PC,
		Max,
	};

	class ProgramCounter
	{
		BaseLogic::DLatch PCL[8];
		BaseLogic::DLatch PCLS[8];
		BaseLogic::DLatch PCH[8];
		BaseLogic::DLatch PCHS[8];

	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState DB[], BaseLogic::TriState ADL[], BaseLogic::TriState ADH[]);
	};
}
