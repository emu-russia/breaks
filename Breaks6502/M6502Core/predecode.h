#pragma once

namespace M6502Core
{
	enum class PreDecode_Input
	{
		PHI2 = 0,
		Z_IR,

		Max,
	};

	class PreDecode
	{
		BaseLogic::DLatch pd_latch[8];

	public:

		BaseLogic::TriState PD[8];

		BaseLogic::TriState n_IMPLIED = BaseLogic::TriState::One;
		BaseLogic::TriState n_TWOCYCLE = BaseLogic::TriState::One;

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState d[8], BaseLogic::TriState n_PD[8]);
	};
}
