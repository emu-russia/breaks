#pragma once

namespace M6502Core
{
	class ExtraCounter
	{
		BaseLogic::DLatch t1_latch;
		BaseLogic::DLatch t2_latch1;
		BaseLogic::DLatch t2_latch2;
		BaseLogic::DLatch t3_latch1;
		BaseLogic::DLatch t3_latch2;
		BaseLogic::DLatch t4_latch1;
		BaseLogic::DLatch t4_latch2;
		BaseLogic::DLatch t5_latch1;
		BaseLogic::DLatch t5_latch2;

		M6502* core = nullptr;

		// HLE
		uint8_t latch1 = 0;
		uint8_t latch2 = 0;

	public:

		ExtraCounter(M6502* parent) { core = parent; }

		void sim();

		void sim_HLE();
	};
}
