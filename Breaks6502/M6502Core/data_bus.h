#pragma once

namespace M6502Core
{
	class DataBus
	{
		BaseLogic::DLatch rd_latch;
		BaseLogic::DLatch DL[8];
		BaseLogic::DLatch DOR[8];

		M6502* core = nullptr;

	public:

		DataBus(M6502* parent) { core = parent; }

		void sim_SetExternalBus(BaseLogic::TriState cpu_inOut[]);

		void sim_GetExternalBus(BaseLogic::TriState cpu_inOut[]);

		uint8_t getDL();
		uint8_t getDOR();
	};
}
