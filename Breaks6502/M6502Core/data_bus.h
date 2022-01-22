#pragma once

namespace M6502Core
{
	class DataBus
	{
		BaseLogic::DLatch rd_latch;
		uint8_t DL;
		uint8_t DOR;

		M6502* core = nullptr;

	public:

		DataBus(M6502* parent) { core = parent; }

		void sim_SetExternalBus(uint8_t* data_bus);

		void sim_GetExternalBus(uint8_t* data_bus);

		uint8_t getDL();
		uint8_t getDOR();
	};
}
