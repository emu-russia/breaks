#pragma once

namespace M6502Core
{
	enum class RegsControl_Input
	{
		PHI1 = 0, 
		PHI2,
		STOR,
		n_ready,

		Max,
	};

	enum class RegsControl_Output
	{
		STXY = 0,
		SBXY,
		STKOP,

		Y_SB,
		X_SB,
		S_SB,
		SB_X,
		SB_Y,
		SB_S,
		S_S,
		S_ADL,

		Max,
	};

	class RegsControl
	{
		BaseLogic::DLatch nready_latch;

		BaseLogic::DLatch ysb_latch;
		BaseLogic::DLatch xsb_latch;
		BaseLogic::DLatch ssb_latch;
		BaseLogic::DLatch sbx_latch;
		BaseLogic::DLatch sby_latch;
		BaseLogic::DLatch sbs_latch;
		BaseLogic::DLatch ss_latch;
		BaseLogic::DLatch sadl_latch;

	public:

		void sim (BaseLogic::TriState inputs[], BaseLogic::TriState d[], BaseLogic::TriState outputs[]);
	};
}
