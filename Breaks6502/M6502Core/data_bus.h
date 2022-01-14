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
		BaseLogic::DLatch rd_latch;
		BaseLogic::DLatch DL[8];
		BaseLogic::DLatch DOR[8];

	public:

		/// <summary>
		/// Buses -> DL/DOR
		/// </summary>
		void sim_Load(BaseLogic::TriState inputs[], BaseLogic::TriState DB[], BaseLogic::TriState cpu_inOut[]);

		/// <summary>
		/// DL/DOR -> Buses
		/// </summary>
		void sim_Store(BaseLogic::TriState inputs[], BaseLogic::TriState DB[], BaseLogic::TriState ADL[], BaseLogic::TriState ADH[], 
			bool DB_Dirty[8], bool ADL_Dirty[8], bool ADH_Dirty[8], BaseLogic::TriState cpu_inOut[]);

		uint8_t getDL();
		uint8_t getDOR();
	};
}
