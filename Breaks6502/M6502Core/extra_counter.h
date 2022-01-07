#pragma once

namespace M6502Core
{
	enum class ExtraCounter_Input
	{
		PHI1 = 0,
		PHI2,
		TRES2,
		n_ready,
		T1,
		Max,
	};

	enum class ExtraCounter_Output
	{
		n_T2 = 0,
		n_T3,
		n_T4,
		n_T5,
		Max,
	};

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

	public:

		void sim(BaseLogic::TriState inputs[], BaseLogic::TriState outputs[]);
	};
}
