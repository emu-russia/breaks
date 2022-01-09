#pragma once

namespace M6502Core
{
	enum class PreDecode_Input
	{
		PHI2 = 0,
		Z_IR,

		Max,
	};

	enum class PreDecode_Output
	{
		n_IMPLIED = 0,
		n_TWOCYCLE,

		Max,
	};

	class PreDecode
	{
		BaseLogic::DLatch pd_latch[8];

	public:

		BaseLogic::TriState PD[8];

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState d[8], BaseLogic::TriState outputs[], BaseLogic::TriState n_PD[8]);
	};
}
