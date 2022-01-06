#pragma once

namespace M6502Core
{
	enum class DataBus_Input
	{
		PHI1 = 0,
		PHI2,
		WR,
		DL_ADL,
		DL_ADH,
		DL_DB,
		Max,
	};

	class DataBus
	{
	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState DB[], BaseLogic::TriState ADL[], BaseLogic::TriState ADH[], BaseLogic::TriState cpu_inOut[]);
	};
}
